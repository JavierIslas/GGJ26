extends StaticBody2D
class_name TruthDoor
## Puerta que se abre al revelar un número específico de verdades
##
## Puede configurarse para:
## - Abrirse tras N revelaciones en el nivel
## - Abrirse tras revelaciones totales del juego
## - Abrirse al revelar entidades específicas (stretch)

@export var truths_required: int = 1
@export var use_level_truths: bool = true  # Si es false, usa total_truths_revealed
@export var door_color: Color = Color(0.6, 0.2, 0.2, 1.0)  # Rojo por defecto
@export var open_color: Color = Color(0.2, 0.6, 0.2, 0.5)  # Verde transparente cuando abierta

@onready var sprite: ColorRect = $ColorRect
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

var is_open: bool = false

func _ready() -> void:
	# Conectar señal de GameManager
	GameManager.truth_revealed.connect(_on_truth_revealed)

	# Setup visual inicial
	sprite.color = door_color
	_update_label()

func _on_truth_revealed(_total: int) -> void:
	"""Verifica si la puerta debe abrirse"""
	if is_open:
		return

	var current_truths = GameManager.current_level_truths if use_level_truths else GameManager.total_truths_revealed

	_update_label()

	if current_truths >= truths_required:
		_open_door()

func _open_door() -> void:
	"""Abre la puerta desactivando colisión y cambiando visual"""
	is_open = true

	# Desactivar colisión
	collision.disabled = true

	# Cambiar color
	sprite.color = open_color

	# Actualizar label
	label.text = "OPEN"
	label.modulate = Color(0.2, 1.0, 0.2, 1.0)

	# SFX de puerta abriendo
	AudioManager.play_sfx("door_open", -5.0)

	# Feedback visual
	_play_open_animation()

	print("TruthDoor opened!")

func _play_open_animation() -> void:
	"""Animación simple de apertura"""
	# Crear tween para hacer fade + scale
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.3).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_IN)

func _update_label() -> void:
	"""Actualiza el texto del label"""
	var current_truths = GameManager.current_level_truths if use_level_truths else GameManager.total_truths_revealed
	label.text = "%d / %d" % [current_truths, truths_required]
