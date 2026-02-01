extends Camera2D
## Camera Shake con sistema de trauma
##
## Sistema de screen shake basado en trauma (0.0 a 1.0)
## Inspirado en GDC talk "Math for Game Programmers: Juicing Your Cameras With Math"

@export var decay_rate: float = 5.0  ## Qué tan rápido se reduce el trauma (muy rápido)
@export var max_offset: float = 4.0  ## Máximo offset en píxeles (muy reducido)
@export var max_rotation: float = 0.0  ## Sin rotación (evita mareo/blur visual)

var trauma: float = 0.0
var trauma_power: float = 2.0  ## Exponente para suavizar la curva

func _process(delta: float) -> void:
	if trauma > 0:
		# Reducir trauma con el tiempo
		trauma = max(trauma - decay_rate * delta, 0.0)

		# Aplicar shake
		_apply_shake()
	else:
		# Sin trauma, resetear offset y rotación
		offset = Vector2.ZERO
		rotation = 0.0

func add_trauma(amount: float) -> void:
	"""Agrega trauma (clamped a 0-1)"""
	trauma = min(trauma + amount, 1.0)

func _apply_shake() -> void:
	"""Aplica el shake basado en el nivel de trauma actual"""
	# Calcular shake amount (con exponente para suavizar)
	var shake_amount = pow(trauma, trauma_power)

	# Offset aleatorio
	offset.x = max_offset * shake_amount * randf_range(-1, 1)
	offset.y = max_offset * shake_amount * randf_range(-1, 1)

	# Rotación aleatoria
	rotation = deg_to_rad(max_rotation * shake_amount * randf_range(-1, 1))
