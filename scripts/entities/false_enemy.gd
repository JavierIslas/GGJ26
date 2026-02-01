class_name FalseEnemy
extends CharacterBody2D
## FALSE ENEMY - "Las Víctimas" (Tipo 1)
##
## NARRATIVA: Víctimas que adoptaron máscaras agresivas para protegerse.
##           "Parezco peligroso para que me dejen en paz."
##
## ENMASCARADO: Postura amenazante, patrulla defensivamente (50 px/s)
## REVELADO: Encogido, asustado, huye llorando (100 px/s)
##
## PREGUNTA: "¿Cuántos 'enemigos' son realmente víctimas disfrazadas?"

signal died

@export_group("Movement")
@export var patrol_speed: float = 120.0  # Velocidad visible de patrullaje
@export var flee_speed: float = 180.0  # Huida rápida cuando revelado

@export_group("Detection")
@export var player_detection_range: float = 64.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var is_revealed: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Feedback visual: Es atravesable (semi-transparente)
	sprite.modulate.a = 0.7  # 70% opacidad = efecto fantasma

	# Cachear referencia al jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_revealed:
		_behavior_revealed(delta)
	else:
		_behavior_masked(delta)

	move_and_slide()

func _behavior_masked(_delta: float) -> void:
	"""Comportamiento mientras está enmascarado: patrulla"""

	# Patrulla simple (izquierda-derecha)
	velocity.x = direction * patrol_speed

	# Dar vuelta en bordes o paredes
	if is_on_wall() or not _is_floor_ahead():
		_turn_around()

	# Voltear sprite
	sprite.flip_h = direction < 0

func _behavior_revealed(_delta: float) -> void:
	"""Comportamiento revelado: huir del jugador"""

	if not player_ref or not is_instance_valid(player_ref):
		# No hay jugador, quedarse quieto
		velocity.x = move_toward(velocity.x, 0, patrol_speed)
		return

	# Huir en dirección opuesta al jugador
	var player_direction = sign(player_ref.global_position.x - global_position.x)
	var flee_direction = -player_direction

	velocity.x = flee_direction * flee_speed

	# Voltear sprite
	sprite.flip_h = flee_direction < 0

func _is_floor_ahead() -> bool:
	"""Detecta si hay suelo adelante para no caer"""
	# Raycast desde los pies, adelante y hacia abajo
	var feet_offset = 15.0  # Altura aproximada de los pies (mitad del sprite)
	var ahead_distance = 20.0  # Qué tan adelante mirar
	var down_distance = 10.0  # Qué tan abajo buscar suelo

	var from = global_position + Vector2(direction * ahead_distance, feet_offset)
	var to = from + Vector2(0, down_distance)

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 1  # Layer 1 (World)

	var result = space_state.intersect_ray(query)
	return result.size() > 0

func _turn_around() -> void:
	direction *= -1

func _on_veil_torn() -> void:
	"""Llamado cuando se revela el velo"""
	is_revealed = true

	# === POLISH: Partículas de revelación (False Enemy = azul) ===
	ParticleEffects.spawn_reveal_particles_typed(global_position, false)

	# === POLISH: Partículas de transformación ===
	var old_color = Color(0.5, 0.5, 0.5, 0.8)  # Gris enmascarado
	var new_color = Color(0.6, 0.6, 1.0, 1.0)  # Azul revelado
	ParticleEffects.spawn_transform_particles(global_position, old_color, new_color)

	# Cambiar color del sprite (placeholder hasta tener arte real)
	sprite.modulate = new_color

	# Cambiar animación si existe
	if animation_player and animation_player.has_animation("revealed"):
		animation_player.play("revealed")

	print("False Enemy revealed! Now fleeing...")

func stun(duration: float) -> void:
	"""Aturde al False Enemy - huye el doble de rápido (terror extremo)"""
	if not is_revealed:
		return

	print("False Enemy stunned (terrified) for %.1fs" % duration)

	# False Enemies no se paralizan - entran en pánico y huyen más rápido
	var original_flee_speed = flee_speed
	flee_speed = original_flee_speed * 2.0  # El doble de velocidad

	# Feedback visual de terror
	_terror_visual_feedback()

	# Restaurar velocidad después del tiempo
	await get_tree().create_timer(duration).timeout
	flee_speed = original_flee_speed

	print("False Enemy terror ended")

func _terror_visual_feedback() -> void:
	"""Feedback visual de terror (huida acelerada)"""
	# Temblar sprite (más rápido que stun normal)
	var original_pos = sprite.position
	var shake_tween = create_tween()
	shake_tween.set_loops(6)  # Varias sacudidas
	shake_tween.tween_property(sprite, "position", original_pos + Vector2(3, 0), 0.05)
	shake_tween.tween_property(sprite, "position", original_pos + Vector2(-3, 0), 0.05)
	shake_tween.tween_property(sprite, "position", original_pos, 0.05)

	# Partículas de pánico (gotas de sudor)
	var particles = CPUParticles2D.new()

	particles.global_position = global_position + Vector2(0, -16)
	particles.emitting = true
	particles.one_shot = false
	particles.amount = 4
	particles.lifetime = 0.6

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 8.0
	particles.direction = Vector2(0, 1)  # Caen hacia abajo
	particles.spread = 20.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2(0, 200)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(0.6, 0.8, 1.0, 0.7)  # Azul (lágrimas/sudor)

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.7, 0.9, 1.0, 0.8))
	gradient.add_point(1.0, Color(0.5, 0.7, 1.0, 0.0))
	particles.color_ramp = gradient

	add_child(particles)

	# Destruir partículas después de stun
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()
