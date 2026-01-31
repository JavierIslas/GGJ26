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
	"""Anima el escudo pulsando y rotando"""
	if not shield_sprite or not shield_sprite.visible:
		return

	# OPTIMIZATION: Use tweens for both scale and rotation instead of _process
	# Scale animation (pulsing)
	var scale_tween = create_tween()
	scale_tween.set_loops()
	scale_tween.tween_property(shield_sprite, "scale", Vector2(1.5, 1.5), 1.0).set_ease(Tween.EASE_IN_OUT)
	scale_tween.tween_property(shield_sprite, "scale", Vector2(1.4, 1.4), 1.0).set_ease(Tween.EASE_IN_OUT)

	# Rotation animation (continuous spin, replaces _process rotation)
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(shield_sprite, "rotation", TAU, 12.0).set_trans(Tween.TRANS_LINEAR)

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

	# === POLISH: Freeze frame para máximo impacto ===
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.08, true, false, true).timeout
	Engine.time_scale = 1.0

	# === POLISH: Vibración fuerte al romper escudo ===
	_apply_gamepad_vibration(0.8, 0.8, 0.4)

	# === POLISH: Camera shake fuerte ===
	_apply_camera_shake(0.7)

	# === POLISH: Partículas de escudo roto ===
	_spawn_shield_break_particles()

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

	# === POLISH: Partículas de muerte ===
	var death_color = Color(0.6, 0.2, 0.8, 1.0)  # Púrpura (True Threat)
	ParticleEffects.spawn_death_particles(global_position, death_color, 40)

	# === POLISH: Freeze frame en muerte ===
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1.0

	# === POLISH: Camera shake en muerte ===
	_apply_camera_shake(0.5)

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

	# FIX MEMORY LEAK: Usar ProjectileManager en lugar de root
	ProjectileManager.add_projectile(projectile)

	# SFX
	AudioManager.play_sfx("projectile_shoot", -8.0)

func _predict_player_position() -> Vector2:
	"""Predice dónde estará el jugador"""
	if not player_ref or not is_instance_valid(player_ref):
		return global_position

	var player_pos = player_ref.global_position
	var player_velocity = Vector2.ZERO

	# OPTIMIZATION: Only predict if player is moving significantly
	if player_ref is CharacterBody2D:
		player_velocity = player_ref.velocity

		# If player is barely moving, don't bother with prediction
		if player_velocity.length() < 50.0:
			return player_pos

	var distance = global_position.distance_to(player_pos)
	var time_to_hit = distance / projectile_speed
	var predicted_position = player_pos + player_velocity * time_to_hit * 0.5  # Reduced prediction

	return predicted_position

func _process(_delta: float) -> void:
	"""Rotar escudo constantemente"""
	# OPTIMIZATION: Use Tween instead of manual rotation in _process
	# This is handled by _animate_shield() now, so this function can be removed
	# Keeping it minimal for compatibility
	pass

func stun(duration: float) -> void:
	"""Aturde al True Threat Shield - deja de disparar temporalmente"""
	if not is_revealed:
		return

	print("True Threat Shield stunned for %.1fs" % duration)

	# Detener disparo
	shoot_timer.stop()

	# Feedback visual de stun (oscurecer)
	var original_color = sprite.modulate
	sprite.modulate = Color(0.3, 0.1, 0.4, 0.6)  # Púrpura oscuro

	# Restaurar después del tiempo
	await get_tree().create_timer(duration).timeout
	sprite.modulate = original_color

	# Reiniciar timer de disparo (solo si el escudo está roto)
	if is_revealed and not shield_active:
		shoot_timer.start()

	print("True Threat Shield stun ended")

# === POLISH & JUICE METHODS ===

func _apply_camera_shake(trauma_amount: float) -> void:
	"""Aplica screen shake a través de la cámara"""
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(trauma_amount)

func _apply_gamepad_vibration(weak_magnitude: float, strong_magnitude: float, duration: float) -> void:
	"""Vibración de gamepad para feedback táctil"""
	var joy_list = Input.get_connected_joypads()
	for joy_id in joy_list:
		Input.start_joy_vibration(joy_id, weak_magnitude, strong_magnitude, duration)

func _spawn_shield_break_particles() -> void:
	"""Partículas de escudo rompiéndose"""
	var particles = GPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 40  # Muchas partículas para impacto
	particles.lifetime = 1.2
	particles.explosiveness = 1.0

	# Material de partícula
	var material = ParticleProcessMaterial.new()

	# Emisión en explosión radial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 16.0

	# Dirección explosiva en todas direcciones
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 250.0

	# Gravedad moderada
	material.gravity = Vector3(0, 200, 0)

	# Escala variable (fragmentos de escudo)
	material.scale_min = 3.0
	material.scale_max = 7.0

	# Rotación rápida
	material.angular_velocity_min = -540.0
	material.angular_velocity_max = 540.0

	# Color del escudo (azul brillante)
	material.color = shield_color * 1.5  # Overbright
	var gradient = Gradient.new()
	gradient.add_point(0.0, shield_color * 1.5)
	gradient.add_point(0.6, shield_color)
	gradient.add_point(1.0, Color(shield_color.r, shield_color.g, shield_color.b, 0.0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir usando Timer (evita memory leak del await)
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = particles.lifetime + 0.1
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
		cleanup_timer.queue_free()
	)
	get_tree().root.add_child(cleanup_timer)
