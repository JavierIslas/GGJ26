extends StaticBody2D
class_name TrueThreatLaser
## Verdadero Enemigo - Torreta Láser (Variante Avanzada)
##
## ENMASCARADO: Estatua gris inofensiva
## REVELADO: Torreta que dispara LÁSER CONTINUO con telegraph

signal died

@export_group("Laser")
@export var laser_interval: float = 4.0      # Tiempo entre disparos
@export var telegraph_time: float = 2.0      # Tiempo de aviso antes de disparar
@export var freeze_time: float = 0.6         # Tiempo de congelación antes de disparar
@export var laser_duration: float = 0.8      # Duración del disparo
@export var laser_damage_rate: float = 0.2   # Tiempo entre daños (5 daños/seg)
@export var laser_damage: int = 1
@export var laser_length: float = 800.0

@export_group("Visual")
@export var telegraph_color: Color = Color(1.0, 0.5, 0.0, 0.3)  # Naranja
@export var laser_color: Color = Color(1.0, 0.1, 0.1, 0.9)      # Rojo brillante

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var telegraph_line: Line2D = $TelegraphLine
@onready var laser_line: Line2D = $LaserLine
@onready var laser_area: Area2D = $LaserArea

var is_revealed: bool = false
var player_ref: Node2D = null
var laser_timer: Timer
var telegraph_timer: Timer
var freeze_timer: Timer
var damage_timer: Timer
var is_telegraphing: bool = false
var is_firing: bool = false
var locked_angle: float = 0.0  # Ángulo bloqueado durante freeze/disparo
var is_angle_locked: bool = false  # Si el ángulo está congelado

enum State { IDLE, TELEGRAPHING, FIRING }
var current_state: State = State.IDLE

# Performance optimization
var update_counter: int = 0
var update_frequency: int = 3  # Update every N frames (lower for laser)
var cached_angle: float = 0.0

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Feedback visual: Estatua
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)

	# Configurar líneas
	_setup_lines()

	# Configurar laser area (para detección de daño)
	_setup_laser_area()

	# Cachear jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

	# Timers
	laser_timer = Timer.new()
	laser_timer.wait_time = laser_interval
	laser_timer.timeout.connect(_start_telegraph)
	add_child(laser_timer)

	telegraph_timer = Timer.new()
	telegraph_timer.wait_time = telegraph_time
	telegraph_timer.one_shot = true
	telegraph_timer.timeout.connect(_fire_laser)
	add_child(telegraph_timer)

	freeze_timer = Timer.new()
	freeze_timer.wait_time = telegraph_time - freeze_time
	freeze_timer.one_shot = true
	freeze_timer.timeout.connect(_freeze_angle)
	add_child(freeze_timer)

	damage_timer = Timer.new()
	damage_timer.wait_time = laser_damage_rate
	damage_timer.timeout.connect(_apply_laser_damage)
	add_child(damage_timer)

func _setup_lines() -> void:
	"""Configura las líneas de telegraph y láser"""
	if not has_node("TelegraphLine"):
		telegraph_line = Line2D.new()
		telegraph_line.name = "TelegraphLine"
		telegraph_line.width = 20.0
		telegraph_line.default_color = telegraph_color
		telegraph_line.add_point(Vector2.ZERO)
		telegraph_line.add_point(Vector2(laser_length, 0))
		telegraph_line.visible = false
		add_child(telegraph_line)

	if not has_node("LaserLine"):
		laser_line = Line2D.new()
		laser_line.name = "LaserLine"
		laser_line.width = 8.0
		laser_line.default_color = laser_color
		laser_line.add_point(Vector2.ZERO)
		laser_line.add_point(Vector2(laser_length, 0))
		laser_line.visible = false
		add_child(laser_line)

func _setup_laser_area() -> void:
	"""Configura el área de colisión del láser"""
	if not has_node("LaserArea"):
		laser_area = Area2D.new()
		laser_area.name = "LaserArea"
		laser_area.collision_layer = 0
		laser_area.collision_mask = 2  # Player layer
		laser_area.monitoring = false
		add_child(laser_area)

		# Crear collision shape (rectángulo largo)
		var shape = RectangleShape2D.new()
		shape.size = Vector2(laser_length, 16)

		var collision = CollisionShape2D.new()
		collision.shape = shape
		collision.position = Vector2(laser_length / 2, 0)
		laser_area.add_child(collision)

func _on_veil_torn() -> void:
	"""Revelado: Se activa como torreta láser"""
	is_revealed = true

	# Cambio visual: Cyan brillante (láser)
	sprite.modulate = Color(0.1, 0.8, 1.0, 1.0)

	# NOTA: VeilComponent ya contó esta verdad automáticamente

	# Comenzar ciclo de disparo
	laser_timer.start()

	print("TrueThreatLaser revealed! Laser charging...")

func _process(_delta: float) -> void:
	if not is_revealed or not player_ref or not is_instance_valid(player_ref):
		return

	# OPTIMIZATION: Only update rotation when not locked (locked angle doesn't change)
	if is_angle_locked:
		return  # No need to update if angle is locked

	# OPTIMIZATION: Update only every N frames
	update_counter += 1
	if update_counter < update_frequency:
		return

	update_counter = 0

	var angle: float

	# Rastrear al jugador mientras no esté congelado
	var direction_to_player = (player_ref.global_position - global_position).normalized()
	angle = direction_to_player.angle()

	# OPTIMIZATION: Only update if angle changed significantly
	if abs(angle - cached_angle) < 0.01:
		return

	cached_angle = angle

	# Rotar líneas
	if telegraph_line:
		telegraph_line.rotation = angle
	if laser_line:
		laser_line.rotation = angle
	if laser_area:
		laser_area.rotation = angle

func _start_telegraph() -> void:
	"""Inicia el telegraph (aviso visual)"""
	current_state = State.TELEGRAPHING
	is_angle_locked = false

	# Mostrar telegraph
	if telegraph_line:
		telegraph_line.visible = true

	# Efecto de pulsación en telegraph
	_animate_telegraph()

	# SFX
	AudioManager.play_sfx("laser_charge", -5.0)

	# Iniciar timer para congelar el ángulo antes de disparar
	freeze_timer.start()

	# Esperar telegraph_time y luego disparar
	telegraph_timer.start()

func _animate_telegraph() -> void:
	"""Anima el telegraph pulsando"""
	if not telegraph_line:
		return

	# OPTIMIZATION: Kill previous tween if exists to avoid accumulation
	if telegraph_line.has_meta("telegraph_tween"):
		var old_tween = telegraph_line.get_meta("telegraph_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(telegraph_line, "modulate:a", 0.6, 0.3)
	tween.tween_property(telegraph_line, "modulate:a", 0.2, 0.3)

	# Guardar tween para poder detenerlo
	telegraph_line.set_meta("telegraph_tween", tween)

func _freeze_angle() -> void:
	"""Congela el ángulo antes de disparar"""
	if player_ref and is_instance_valid(player_ref):
		var direction_to_player = (player_ref.global_position - global_position).normalized()
		locked_angle = direction_to_player.angle()

	is_angle_locked = true

	# SFX más agudo para indicar que está a punto de disparar
	AudioManager.play_sfx("laser_charge", -3.0)

	print("TrueThreatLaser: Angle locked! Firing in %.1f seconds..." % freeze_time)

func _fire_laser() -> void:
	"""Dispara el láser"""
	current_state = State.FIRING

	# Ocultar telegraph
	if telegraph_line:
		telegraph_line.visible = false
		if telegraph_line.has_meta("telegraph_tween"):
			var tween = telegraph_line.get_meta("telegraph_tween")
			if tween and tween.is_valid():
				tween.kill()

	# Mostrar láser
	if laser_line:
		laser_line.visible = true

	# Activar área de daño
	if laser_area:
		laser_area.monitoring = true

	# SFX
	AudioManager.play_sfx("laser_fire", 0.0)

	# Comenzar a aplicar daño
	damage_timer.start()

	# Detener láser después de laser_duration
	await get_tree().create_timer(laser_duration).timeout
	_stop_laser()

func _stop_laser() -> void:
	"""Detiene el disparo láser"""
	current_state = State.IDLE
	is_angle_locked = false

	# Ocultar láser
	if laser_line:
		laser_line.visible = false

	# Desactivar área de daño
	if laser_area:
		laser_area.monitoring = false

	# Detener damage timer
	damage_timer.stop()

func _apply_laser_damage() -> void:
	"""Aplica daño a los jugadores en el área del láser"""
	if not laser_area or not laser_area.monitoring:
		return

	# OPTIMIZATION: Only check player directly instead of all bodies
	if player_ref and is_instance_valid(player_ref):
		if laser_area.overlaps_body(player_ref):
			# Aplicar daño
			GameManager.change_health(-laser_damage)

			# Feedback visual en jugador
			_flash_player(player_ref)

func _flash_player(player: Node2D) -> void:
	"""Efecto de flash en el jugador al recibir daño"""
	if not player.has_node("Sprite2D"):
		return

	var sprite_node = player.get_node("Sprite2D")
	var original_modulate = sprite_node.modulate

	sprite_node.modulate = Color(1.5, 0.5, 0.5, 1.0)

	var tween = create_tween()
	tween.tween_property(sprite_node, "modulate", original_modulate, 0.1)
