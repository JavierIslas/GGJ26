extends Label
class_name InputHint
## Muestra un hint de input cuando el jugador está cerca
##
## Se usa para mostrar hints como "E", "R", "Shift", etc.
## Aparece/desaparece según la distancia al jugador

@export var show_range: float = 80.0  # Distancia para mostrar el hint
@export var pulse_animation: bool = true  # Animar con pulso

var player: Node2D = null
var parent_entity: Node2D = null
var tween: Tween = null

func _ready() -> void:
	# Empezar invisible
	modulate.a = 0.0

	# Obtener referencia al parent (la entidad)
	parent_entity = get_parent()

	# Buscar al jugador
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if pulse_animation:
		_start_pulse()

func _process(_delta: float) -> void:
	if not player or not parent_entity:
		return

	# Calcular distancia al jugador
	var distance = parent_entity.global_position.distance_to(player.global_position)

	# Mostrar/ocultar según distancia
	if distance <= show_range:
		_show_hint()
	else:
		_hide_hint()

func _show_hint() -> void:
	"""Muestra el hint con fade in"""
	if modulate.a < 0.9:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)

func _hide_hint() -> void:
	"""Oculta el hint con fade out"""
	if modulate.a > 0.1:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)

func _start_pulse() -> void:
	"""Animación de pulso constante"""
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)

func force_hide() -> void:
	"""Oculta el hint inmediatamente (cuando la acción se completa)"""
	if tween:
		tween.kill()
	modulate.a = 0.0
	queue_free()  # Destruir el hint cuando ya no es necesario
