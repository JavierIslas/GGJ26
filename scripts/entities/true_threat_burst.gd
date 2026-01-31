extends StaticBody2D
class_name TrueThreatBurst
## Verdadero Enemigo - Torreta de Ráfagas (Variante de Tipo 3)
##
## ENMASCARADO: Estatua gris inofensiva
## REVELADO: Torreta que dispara en ráfagas de 3 proyectiles

signal died

@export_group("Shooting")
@export var shoot_interval: float = 3.0
@export var burst_count: int = 3
@export var burst_delay: float = 0.2
@export var projectile_speed: float = 200.0
@export var projectile_damage: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent

var is_revealed: bool = false
var player_ref: Node2D = null
var shoot_timer: Timer
var projectile_scene = preload("res://scenes/components/projectile.tscn")

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Feedback visual: Estatua (gris semi-transparente)
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)

	# Cachear referencia al jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

	# Crear timer para disparos
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _on_veil_torn() -> void:
	"""Revelado: Se activa como torreta de ráfagas"""
	is_revealed = true

	# Cambio visual: Púrpura más oscuro/peligroso
	sprite.modulate = Color(0.5, 0.1, 0.6, 1.0)

	# Registrar verdad revelada
	GameManager.reveal_truth()

	# Comenzar a disparar
	shoot_timer.start()

	print("TrueThreatBurst revealed! Starting burst fire...")

func _on_shoot_timer_timeout() -> void:
	"""Dispara ráfaga de proyectiles"""
	if not is_revealed or not player_ref or not is_instance_valid(player_ref):
		return

	# Disparar ráfaga
	_fire_burst()

func _fire_burst() -> void:
	"""Dispara múltiples proyectiles en ráfaga"""
	for i in range(burst_count):
		# Esperar delay entre cada disparo de la ráfaga
		if i > 0:
			await get_tree().create_timer(burst_delay).timeout

		_fire_projectile()

func _fire_projectile() -> void:
	"""Dispara un solo proyectil"""
	if not projectile_scene or not player_ref or not is_instance_valid(player_ref):
		return

	var projectile = projectile_scene.instantiate()

	# Posicionar proyectil
	projectile.global_position = global_position

	# Predecir posición del jugador
	var target_pos = _predict_player_position()
	var direction = (target_pos - global_position).normalized()

	# Configurar proyectil
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = projectile_damage

	# Añadir al mundo
	get_tree().root.add_child(projectile)

	# SFX
	AudioManager.play_sfx("projectile_shoot", -8.0)

func _predict_player_position() -> Vector2:
	"""Predice dónde estará el jugador"""
	var player_pos = player_ref.global_position
	var player_velocity = Vector2.ZERO

	if player_ref is CharacterBody2D:
		player_velocity = player_ref.velocity

	var distance = global_position.distance_to(player_pos)
	var time_to_hit = distance / projectile_speed
	var predicted_position = player_pos + player_velocity * time_to_hit

	return predicted_position
