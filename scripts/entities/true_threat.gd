class_name TrueThreat
extends StaticBody2D
## Verdadero Enemigo (Tipo 3)
##
## ENMASCARADO: Parece estatua/objeto inanimado, completamente estático
## REVELADO: Torreta biológica que dispara proyectiles hacia el jugador

signal died

@export_group("Combat")
@export var projectile_scene: PackedScene
@export var fire_rate: float = 2.0  # Segundos entre disparos
@export var projectile_speed: float = 150.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fire_timer: Timer = $FireTimer

var is_revealed: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Configurar timer de disparo
	if not has_node("FireTimer"):
		fire_timer = Timer.new()
		fire_timer.name = "FireTimer"
		fire_timer.wait_time = fire_rate
		fire_timer.one_shot = false
		add_child(fire_timer)

	fire_timer.timeout.connect(_on_fire_timer_timeout)

	# Cargar escena de proyectil si no está asignada
	if not projectile_scene:
		projectile_scene = load("res://scenes/components/projectile.tscn")

	# Feedback visual: Parece estatua (gris, semi-opaco)
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)

func _on_veil_torn() -> void:
	"""Llamado cuando se revela el velo"""
	is_revealed = true

	# Cambiar apariencia (placeholder: púrpura oscuro)
	sprite.modulate = Color(0.6, 0.2, 0.8, 1.0)  # Púrpura oscuro

	# Buscar al jugador
	player_ref = get_tree().get_first_node_in_group("player")

	# Iniciar disparos
	fire_timer.start()

	# Animación de "despertar"
	if animation_player and animation_player.has_animation("awaken"):
		animation_player.play("awaken")

	print("True Threat revealed! Now firing projectiles...")

func _on_fire_timer_timeout() -> void:
	"""Dispara un proyectil hacia el jugador con predicción de movimiento"""
	if not is_revealed or not player_ref or not is_instance_valid(player_ref):
		return

	# Crear proyectil
	var projectile = projectile_scene.instantiate() as Projectile

	# Posicionar en la posición del enemigo
	projectile.global_position = global_position

	# Calcular posición predicha del jugador
	var target_position = _predict_player_position()

	# Calcular dirección hacia la posición predicha
	var direction = (target_position - global_position).normalized()
	projectile.set_direction(direction)
	projectile.speed = projectile_speed

	# FIX MEMORY LEAK: Usar ProjectileManager en lugar de root
	ProjectileManager.add_projectile(projectile)

	# Efecto visual de disparo (pulso)
	_fire_effect()

func _predict_player_position() -> Vector2:
	"""Predice dónde estará el jugador basándose en su velocidad actual"""
	if not player_ref:
		return global_position

	# Posición actual del jugador
	var player_pos = player_ref.global_position

	# Obtener velocidad del jugador (si tiene CharacterBody2D)
	var player_velocity = Vector2.ZERO
	if player_ref is CharacterBody2D:
		player_velocity = player_ref.velocity

	# FIX: Si jugador no se mueve significativamente, apuntar directo
	if player_velocity.length() < 50.0:
		return player_pos

	# Calcular distancia actual
	var distance = global_position.distance_to(player_pos)

	# Calcular tiempo estimado que tardará el proyectil en llegar
	var time_to_hit = distance / projectile_speed

	# FIX: Usar predicción reducida para evitar que proyectiles vayan "con" el jugador
	# Solo predecir 50% del movimiento para que apunte más hacia donde está
	var predicted_position = player_pos + player_velocity * time_to_hit * 0.5

	return predicted_position

func _fire_effect() -> void:
	"""Efecto visual al disparar"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	var original_scale = sprite.scale
	tween.tween_property(sprite, "scale", original_scale * 1.15, 0.1)
	tween.tween_property(sprite, "scale", original_scale, 0.2)

	# TODO: SFX de disparo
	# AudioManager.play_sfx("projectile_fire")
