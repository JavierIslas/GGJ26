extends Node2D
## Indicador visual de rango para entidades revelables
##
## Muestra un aro blanco alrededor de la entidad cuando el jugador está cerca

@export var ring_radius: float = 24.0
@export var ring_width: float = 2.0
@export var ring_color: Color = Color.WHITE

var is_in_range: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	# Buscar al jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

	# El indicador es invisible por defecto
	modulate.a = 0.0

func _process(_delta: float) -> void:
	if not player_ref:
		return

	# Verificar si el jugador está en rango
	var distance = global_position.distance_to(player_ref.global_position)
	var was_in_range = is_in_range
	is_in_range = distance <= 48.0  # Rango de revelación

	# Mostrar/ocultar indicador
	if is_in_range and not was_in_range:
		_show_indicator()
	elif not is_in_range and was_in_range:
		_hide_indicator()

	# Efecto de pulsación cuando está visible
	if is_in_range:
		_pulse_effect(_delta)

	# Redibujar el aro
	queue_redraw()

func _draw() -> void:
	if modulate.a == 0:
		return

	# Dibujar aro circular
	draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 32, ring_color, ring_width, true)

func _show_indicator() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.6, 0.2)

func _hide_indicator() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)

func _pulse_effect(delta: float) -> void:
	# Efecto de pulsación suave
	var pulse = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
	ring_radius = 24.0 + pulse * 4.0
