extends StaticBody2D
class_name TrueThreatTracking
## Verdadero Enemigo - Torreta con Seguimiento (Variante Avanzada)
##
## ENMASCARADO: Estatua gris inofensiva
## REVELADO: Torreta que ROTA para seguir al jugador antes de disparar

signal died

@export_group("Shooting")
@export var shoot_interval: float = 2.5
@export var tracking_speed: float = 180.0  # Grados por segundo
@export var aim_threshold: float = 10.0    # Grados de tolerancia para disparar
@export var projectile_speed: float = 180.0
@export var projectile_damage: int = 2

@export_group("Visual")
@export var show_laser_sight: bool = true
@export var laser_color: Color = Color(1.0, 0.1, 0.1, 0.5)

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var laser_sight: Line2D = $LaserSight

var is_revealed: bool = false
var player_ref: Node2D = null
var shoot_timer: Timer
var current_rotation: float = 0.0
var target_angle: float = 0.0
var is_aimed: bool = false
var projectile_scene = preload("res://scenes/components/projectile.tscn")

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Feedback visual: Estatua
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)

	# Configurar laser sight
	if not has_node("LaserSight"):
		laser_sight = Line2D.new()
		laser_sight.name = "LaserSight"
		laser_sight.width = 2.0
		laser_sight.default_color = laser_color
		laser_sight.add_point(Vector2.ZERO)
		laser_sight.add_point(Vector2(100, 0))
		laser_sight.visible = false
		add_child(laser_sight)

	# Cachear jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

	# Timer de disparo
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _on_veil_torn() -> void:
	"""Revelado: Se activa como torreta con tracking"""
	is_revealed = true

	# Cambio visual: Rojo brillante (peligroso)
	sprite.modulate = Color(1.0, 0.2, 0.2, 1.0)

	# Mostrar laser sight
	if laser_sight and show_laser_sight:
		laser_sight.visible = true

	# Registrar verdad
	GameManager.reveal_truth()

	# Comenzar a disparar
	shoot_timer.start()

	print("TrueThreatTracking revealed! Tracking engaged...")

func _process(delta: float) -> void:
	if not is_revealed or not player_ref or not is_instance_valid(player_ref):
		return

	# Calcular ángulo hacia el jugador
	var direction_to_player = (player_ref.global_position - global_position).normalized()
	target_angle = direction_to_player.angle()

	# Rotar suavemente hacia el target
	var angle_diff = _angle_difference(current_rotation, target_angle)

	if abs(angle_diff) > deg_to_rad(aim_threshold):
		# Todavía no apuntado
		is_aimed = false
		var rotation_step = deg_to_rad(tracking_speed) * delta
		current_rotation += sign(angle_diff) * min(rotation_step, abs(angle_diff))
	else:
		# Apuntado correctamente
		is_aimed = true
		current_rotation = target_angle

	# Aplicar rotación al sprite
	sprite.rotation = current_rotation

	# Actualizar laser sight
	_update_laser_sight()

func _update_laser_sight() -> void:
	"""Actualiza la línea del laser sight"""
	if not laser_sight or not laser_sight.visible:
		return

	var laser_length = 500.0
	var end_point = Vector2(cos(current_rotation), sin(current_rotation)) * laser_length

	laser_sight.set_point_position(1, end_point)

	# Cambiar color si está apuntado
	if is_aimed:
		laser_sight.default_color = Color(1.0, 0.0, 0.0, 0.8)  # Rojo intenso
	else:
		laser_sight.default_color = laser_color  # Rojo suave

func _angle_difference(from: float, to: float) -> float:
	"""Calcula la diferencia angular más corta"""
	var diff = fmod(to - from, TAU)
	if diff > PI:
		diff -= TAU
	elif diff < -PI:
		diff += TAU
	return diff

func _on_shoot_timer_timeout() -> void:
	"""Dispara solo si está apuntado correctamente"""
	if not is_revealed or not is_aimed:
		return

	_fire_projectile()

func _fire_projectile() -> void:
	"""Dispara un proyectil en la dirección actual"""
	if not projectile_scene or not player_ref or not is_instance_valid(player_ref):
		return

	var projectile = projectile_scene.instantiate()

	# Posicionar proyectil
	projectile.global_position = global_position

	# Dirección según rotación actual
	var direction = Vector2(cos(current_rotation), sin(current_rotation))

	# Configurar proyectil
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = projectile_damage

	# Añadir al mundo
	get_tree().root.add_child(projectile)

	# SFX
	AudioManager.play_sfx("projectile_shoot", -8.0)

	# Flash del laser
	_flash_laser()

func _flash_laser() -> void:
	"""Efecto de flash al disparar"""
	if not laser_sight:
		return

	var original_width = laser_sight.width
	laser_sight.width = 6.0

	var tween = create_tween()
	tween.tween_property(laser_sight, "width", original_width, 0.1)
