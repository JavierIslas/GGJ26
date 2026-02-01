class_name SyncRevealDoor
extends StaticBody2D
## Puerta que se abre al revelar múltiples enemigos simultáneamente
##
## Requiere que X enemigos específicos sean revelados dentro de una
## ventana de tiempo generosa (coyote time para puzzles).

signal door_opened
signal door_closed
signal progress_changed(revealed_count: int, required_count: int)

@export_group("Requirements")
@export var required_reveals: int = 3  # Cuántos enemigos deben revelarse
@export var time_window: float = 3.5  # Ventana de tiempo GENEROSA (era 2.0)
@export var enemy_group: String = ""  # Grupo de enemigos específicos (opcional)

@export_group("Behavior")
@export var auto_close: bool = false  # Si se cierra tras un tiempo
@export var auto_close_delay: float = 5.0
@export var one_time_only: bool = true  # Solo se puede abrir una vez

@export_group("Visual")
@export var door_color_locked: Color = Color.RED
@export var door_color_unlocked: Color = Color.GREEN
@export var open_direction: Vector2 = Vector2(0, -200)  # Hacia donde se mueve al abrir

# Estado
var is_open: bool = false
var is_locked: bool = false
var revealed_enemies: Array[Node2D] = []
var reveal_times: Array[float] = []
var time_since_last_reveal: float = 0.0

# Referencias
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

var close_timer: Timer = null
var initial_position: Vector2

func _ready() -> void:
	initial_position = global_position

	# Crear timer de cierre automático
	if auto_close:
		close_timer = Timer.new()
		close_timer.name = "CloseTimer"
		close_timer.one_shot = true
		close_timer.wait_time = auto_close_delay
		close_timer.timeout.connect(_on_close_timer_timeout)
		add_child(close_timer)

	# Conectar a señal de revelación global
	if GameManager.has_signal("truth_revealed"):
		GameManager.truth_revealed.connect(_on_truth_revealed)

	_update_visual()

	print("[SyncRevealDoor] %s initialized - requires %d reveals in %.1fs" % [name, required_reveals, time_window])

func _process(delta: float) -> void:
	if is_open or is_locked:
		return

	# Incrementar tiempo desde última revelación
	if revealed_enemies.size() > 0:
		time_since_last_reveal += delta

		# Limpiar revelaciones antiguas fuera de la ventana
		_cleanup_old_reveals()

func _on_truth_revealed(_total: int) -> void:
	if is_open or is_locked:
		return

	# Buscar qué enemigo fue revelado
	var newly_revealed = _find_newly_revealed_enemy()

	if newly_revealed:
		_register_reveal(newly_revealed)

func _find_newly_revealed_enemy() -> Node2D:
	# Buscar enemigos en el grupo especificado o todos los enemigos
	var candidates = []

	if enemy_group != "":
		candidates = get_tree().get_nodes_in_group(enemy_group)
	else:
		candidates = get_tree().get_nodes_in_group("entities")

	for enemy in candidates:
		if not is_instance_valid(enemy):
			continue

		# Verificar si está revelado y no lo habíamos registrado
		if enemy.has_node("VeilComponent"):
			var veil = enemy.get_node("VeilComponent")
			if veil.is_revealed and enemy not in revealed_enemies:
				return enemy

	return null

func _register_reveal(enemy: Node2D) -> void:
	revealed_enemies.append(enemy)
	reveal_times.append(Time.get_ticks_msec() / 1000.0)
	time_since_last_reveal = 0.0

	print("[SyncRevealDoor] Enemy revealed: %s (%d / %d)" % [enemy.name, revealed_enemies.size(), required_reveals])

	progress_changed.emit(revealed_enemies.size(), required_reveals)

	# Verificar si se cumplió la condición
	_check_completion()

func _cleanup_old_reveals() -> void:
	# Limpiar revelaciones fuera de la ventana de tiempo
	var current_time = Time.get_ticks_msec() / 1000.0
	var cleaned = false

	for i in range(revealed_enemies.size() - 1, -1, -1):
		var time_diff = current_time - reveal_times[i]
		if time_diff > time_window:
			print("[SyncRevealDoor] Reveal expired: %s (%.1fs ago)" % [revealed_enemies[i].name, time_diff])
			revealed_enemies.remove_at(i)
			reveal_times.remove_at(i)
			cleaned = true

	if cleaned:
		progress_changed.emit(revealed_enemies.size(), required_reveals)

		# Feedback visual de fallo
		_show_fail_feedback()

func _check_completion() -> void:
	if revealed_enemies.size() >= required_reveals:
		_open_door()

func _open_door() -> void:
	if is_open or (is_locked and one_time_only):
		return

	is_open = true
	print("[SyncRevealDoor] %s OPENED! (%.1fs window)" % [name, time_window])

	# SFX
	AudioManager.play_sfx("door_open", -2.0)

	# Animación de apertura
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", initial_position + open_direction, 1.0)

	# Desactivar colisión
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	_update_visual()
	door_opened.emit()

	# Bloquear si es one-time only
	if one_time_only:
		is_locked = true

	# Iniciar timer de cierre automático
	if auto_close and close_timer:
		close_timer.start()

func _close_door() -> void:
	if not is_open:
		return

	is_open = false
	print("[SyncRevealDoor] %s closed" % name)

	# SFX
	AudioManager.play_sfx("door_close", -2.0)

	# Animación de cierre
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", initial_position, 1.0)

	# Reactivar colisión
	if collision_shape:
		collision_shape.set_deferred("disabled", false)

	_update_visual()
	door_closed.emit()

	# Resetear estado
	revealed_enemies.clear()
	reveal_times.clear()

func _on_close_timer_timeout() -> void:
	_close_door()

func _update_visual() -> void:
	if not sprite:
		return

	if is_open:
		sprite.modulate = door_color_unlocked
	else:
		# Mostrar progreso con color interpolado
		var progress = float(revealed_enemies.size()) / float(required_reveals)
		sprite.modulate = door_color_locked.lerp(door_color_unlocked, progress)

func _show_fail_feedback() -> void:
	"""Feedback visual cuando se pierde progreso"""
	if not sprite:
		return

	# Flash rojo
	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_property(sprite, "modulate", door_color_locked, 0.3)

## Fuerza abrir la puerta (debugging/scripting)
func force_open() -> void:
	_open_door()

## Fuerza cerrar la puerta
func force_close() -> void:
	_close_door()
