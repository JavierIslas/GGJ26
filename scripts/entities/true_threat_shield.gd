extends StaticBody2D
class_name TrueThreatShield
## Verdadero Enemigo - Torreta con Escudo (Variante Avanzada)
##
## ENMASCARADO: Estatua gris inofensiva
## PRIMERA REVELACIÓN: Escudo se rompe, queda vulnerable
## SEGUNDA REVELACIÓN: Se destruye completamente

signal died
signal shield_broken

@export_group("Shooting")
@export var shoot_interval: float = 2.0
@export var projectile_speed: float = 150.0
@export var projectile_damage: int = 2

@export_group("Shield")
@export var shield_health: int = 1  # Cuántas revelaciones para romper escudo
@export var shield_color: Color = Color(0.2, 0.6, 1.0, 0.6)  # Azul

# Esta propiedad indica cuántas verdades proporciona esta entidad
# Shield = 2 (romper escudo + destruir)
@export var truth_count: int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var shield_sprite: Sprite2D = $ShieldSprite

var is_revealed: bool = false
var shield_active: bool = true
var current_shield_health: int
var player_ref: Node2D = null
var shoot_timer: Timer
var projectile_scene = preload("res://scenes/components/projectile.tscn")

func _ready() -> void:
	add_to_group("entities")

	# Inicializar escudo
	current_shield_health = shield_health
	shield_active = true

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Feedback visual: Estatua con escudo
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)

	# Configurar shield sprite
	_setup_shield_sprite()

	# Cachear jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

	# Timer de disparo
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _setup_shield_sprite() -> void:
	"""Configura el sprite del escudo"""
	if not has_node("ShieldSprite"):
		shield_sprite = Sprite2D.new()
		shield_sprite.name = "ShieldSprite"
		shield_sprite.texture = sprite.texture
		shield_sprite.scale = Vector2(1.4, 1.4)
		shield_sprite.modulate = shield_color
		add_child(shield_sprite)

	shield_sprite.visible = true

	# Efecto de pulsación en escudo
	_animate_shield()

func _animate_shield() -> void:
	"""Anima el escudo pulsando"""
	if not shield_sprite or not shield_sprite.visible:
		return

	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(shield_sprite, "scale", Vector2(1.5, 1.5), 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shield_sprite, "scale", Vector2(1.4, 1.4), 1.0).set_ease(Tween.EASE_IN_OUT)

func _on_veil_torn() -> void:
	"""Revelado: Primera vez rompe escudo, segunda vez se destruye"""

	if shield_active:
		# Primera revelación: Romper escudo
		_break_shield()
	else:
		# Segunda revelación: Destruir entidad
		_destroy_turret()

func _break_shield() -> void:
	"""Rompe el escudo y activa la torreta"""
	shield_active = false
	current_shield_health = 0

	# Ocultar escudo con animación
	if shield_sprite:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(shield_sprite, "modulate:a", 0.0, 0.5)
		tween.tween_property(shield_sprite, "scale", Vector2(2.0, 2.0), 0.5)
		tween.finished.connect(func(): shield_sprite.visible = false)

	# Cambio visual: Púrpura (sin escudo, vulnerable)
	sprite.modulate = Color(0.6, 0.2, 0.8, 1.0)

	# Activar como torreta
	is_revealed = true

	# NOTA: VeilComponent ya contó esta verdad automáticamente

	# Comenzar a disparar
	shoot_timer.start()

	# SFX
	AudioManager.play_sfx("shield_break", -3.0)

	# Emitir señal
	shield_broken.emit()

	# Resetear VeilComponent para segunda revelación
	if veil_component:
		veil_component.is_revealed = false

	print("TrueThreatShield: Shield broken! Now vulnerable...")

func _destroy_turret() -> void:
	"""Destruye la torreta completamente"""

	# NOTA: VeilComponent ya contó la segunda verdad automáticamente

	# Detener disparos
	shoot_timer.stop()

	# SFX
	AudioManager.play_sfx("enemy_destroyed", -3.0)

	# Animación de destrucción
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.5)
	tween.tween_property(sprite, "rotation", PI * 2, 0.5)

	# Emitir señal de muerte
	died.emit()

	# Destruir después de animación
	await tween.finished
	queue_free()

	print("TrueThreatShield: Destroyed!")

func _on_shoot_timer_timeout() -> void:
	"""Dispara proyectiles (solo si el escudo está roto)"""
	if not is_revealed or shield_active:
		return

	_fire_projectile()

func _fire_projectile() -> void:
	"""Dispara un proyectil"""
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

func _process(_delta: float) -> void:
	"""Rotar escudo constantemente"""
	if shield_sprite and shield_sprite.visible:
		shield_sprite.rotation += _delta * 0.5
