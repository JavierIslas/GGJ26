class_name FalseEnemy
extends CharacterBody2D
## Falso Enemigo (Tipo 1)
##
## ENMASCARADO: Parece amenazante, patrulla lentamente
## REVELADO: Es una víctima asustada, huye del jugador

signal died

@export_group("Movement")
@export var patrol_speed: float = 50.0
@export var flee_speed: float = 100.0

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

	# Buscar al jugador si no lo tenemos
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player")

	if not player_ref:
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
	var raycast_distance = 20.0
	var from = global_position + Vector2(direction * 16, 16)
	var to = from + Vector2(0, raycast_distance)

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

	# Cambiar color del sprite (placeholder hasta tener arte real)
	sprite.modulate = Color(0.6, 0.6, 1.0, 1.0)  # Azul pálido, opaco

	# Cambiar animación si existe
	if animation_player and animation_player.has_animation("revealed"):
		animation_player.play("revealed")

	print("False Enemy revealed! Now fleeing...")
