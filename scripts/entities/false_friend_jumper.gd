extends FalseFriend
class_name FalseFriendJumper
## Falso Amigo Saltarín (Variante de Tipo 2)
##
## ENMASCARADO: Estático, parece inofensivo
## REVELADO: Persigue saltando hacia el jugador

@export var jump_force: float = -350.0
@export var jump_cooldown: float = 1.0

var can_jump: bool = true
var jump_timer: Timer

func _ready() -> void:
	super._ready()

	# Velocidad de persecución reducida (compensa con saltos)
	chase_speed = 80.0

	# Visual: Amarillo más brillante
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 0.3, 1.0)

	# Crear timer para saltos
	jump_timer = Timer.new()
	jump_timer.wait_time = jump_cooldown
	jump_timer.one_shot = true
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	add_child(jump_timer)

func _behavior_revealed(_delta: float) -> void:
	"""Comportamiento revelado: perseguir saltando"""

	# Si está aturdido (knockback), solo aplicar fricción
	if is_stunned:
		velocity.x = move_toward(velocity.x, 0, chase_speed * 2.0)
		return

	if not player_ref or not is_instance_valid(player_ref):
		# No hay jugador, quedarse quieto
		velocity.x = move_toward(velocity.x, 0, chase_speed)
		return

	# Calcular dirección hacia el jugador
	var direction_to_player = sign(player_ref.global_position.x - global_position.x)

	# Perseguir
	velocity.x = direction_to_player * chase_speed

	# Saltar si está en el suelo y puede saltar
	if is_on_floor() and can_jump:
		_perform_jump()

func _perform_jump() -> void:
	"""Ejecuta el salto"""
	velocity.y = jump_force
	can_jump = false
	jump_timer.start()

	# SFX (opcional)
	# AudioManager.play_sfx("enemy_jump", -8.0)

func _on_jump_timer_timeout() -> void:
	"""Permite saltar de nuevo"""
	can_jump = true
