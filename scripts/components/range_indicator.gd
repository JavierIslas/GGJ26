extends Node2D
## Indicador visual de rango para entidades revelables
##
## Muestra un aro blanco alrededor de la entidad cuando el jugador está cerca

@export var ring_radius: float = 24.0
@export var ring_width: float = 2.0
@export var ring_color: Color = Color.WHITE

var is_in_range: bool = false
var reveal_system: Node2D = null
var parent_entity: Node2D = null

# Pulso
var pulse_tween: Tween = null
var base_radius: float = 24.0

func _ready() -> void:
	# Buscar al reveal system del jugador
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("RevealSystem"):
		reveal_system = player.get_node("RevealSystem")

	parent_entity = get_parent()

	# El indicador es invisible por defecto
	modulate.a = 0.0
	base_radius = ring_radius

	# Verificar rango periódicamente en lugar de cada frame
	var timer = Timer.new()
	timer.wait_time = 0.1  # Chequear cada 100ms en lugar de cada frame
	timer.timeout.connect(_check_range)
	add_child(timer)
	timer.start()

func _check_range() -> void:
	"""Verifica si está en rango del jugador (llamado cada 100ms)"""
	if not reveal_system:
		return

	var was_in_range = is_in_range
	var current_target = reveal_system.get_current_target()
	is_in_range = current_target == parent_entity

	# Mostrar/ocultar indicador solo si cambió el estado
	if is_in_range and not was_in_range:
		_show_indicator()
	elif not is_in_range and was_in_range:
		_hide_indicator()

func _draw() -> void:
	if modulate.a == 0:
		return

	# Dibujar aro circular
	draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 32, ring_color, ring_width, true)

func _show_indicator() -> void:
	"""Muestra el indicador con fade in"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.6, 0.2)

	# Iniciar efecto de pulso
	_start_pulse()

func _hide_indicator() -> void:
	"""Oculta el indicador con fade out"""
	# Detener pulso
	_stop_pulse()

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)

func _start_pulse() -> void:
	"""Inicia animación de pulso"""
	if pulse_tween:
		pulse_tween.kill()

	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "ring_radius", base_radius + 4.0, 0.8).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(self, "ring_radius", base_radius, 0.8).set_ease(Tween.EASE_IN_OUT)

	# Redibujar cuando cambie el radio
	pulse_tween.step_finished.connect(func(_idx): queue_redraw())

func _stop_pulse() -> void:
	"""Detiene animación de pulso"""
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null

	ring_radius = base_radius
	queue_redraw()
