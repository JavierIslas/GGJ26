class_name ParticleEffects
extends Node
## Utilidad estática para crear efectos de partículas reutilizables
##
## Uso: ParticleEffects.spawn_death_particles(position, color)

# Preload de autoloads
var _camera_shake: Node = null
var _screen_flash: Node = null

func _ready() -> void:
	# Obtener referencias a autoloads
	_camera_shake = get_node_or_null("/root/CameraShake")
	_screen_flash = get_node_or_null("/root/ScreenFlash")

## Partículas de muerte/destrucción de enemigos
static func spawn_death_particles(pos: Vector2, entity_color: Color = Color.WHITE, particle_count: int = 30) -> void:
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = particle_count
	particles.lifetime = 1.0
	particles.explosiveness = 1.0

	# Emisión explosiva radial
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 8.0

	# Explosión en todas direcciones
	particles.direction = Vector2(0, 1)  # Hacia abajo por defecto
	particles.spread = 180.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 200.0

	# Gravedad
	particles.gravity = Vector2(0, 250)

	# Escala variable
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0

	# Rotación rápida
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0

	# Color del enemigo con fade
	particles.color = entity_color
	var gradient = Gradient.new()
	gradient.add_point(0.0, entity_color)
	gradient.add_point(0.7, Color(entity_color.r * 0.8, entity_color.g * 0.8, entity_color.b * 0.8, 0.7))
	gradient.add_point(1.0, Color(entity_color.r, entity_color.g, entity_color.b, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol root
	if Engine.get_main_loop() and Engine.get_main_loop().root:
		Engine.get_main_loop().root.add_child(particles)

		# Auto-destruir
		var timer = Engine.get_main_loop().root.get_tree().create_timer(particles.lifetime + 0.1)
		timer.timeout.connect(func(): particles.queue_free())

## Partículas de revelación específicas por tipo de enemigo
static func spawn_reveal_particles_typed(pos: Vector2, is_true_threat: bool) -> void:
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 25
	particles.lifetime = 0.8
	particles.explosiveness = 1.0

	# Emisión radial
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 12.0

	# Dirección
	particles.direction = Vector2(0, 1)
	particles.spread = 180.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 150.0

	# Gravedad
	particles.gravity = Vector2(0, 200)

	# Escala
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0

	# Rotación
	particles.angular_velocity_min = -270.0
	particles.angular_velocity_max = 270.0

	# Color basado en tipo
	var base_color: Color
	if is_true_threat:
		base_color = Color(0.8, 0.2, 0.5, 1.0)  # Rojo/púrpura para True Threat
	else:
		base_color = Color(0.5, 0.5, 0.8, 1.0)  # Azul para False Enemy

	particles.color = base_color
	var gradient = Gradient.new()
	gradient.add_point(0.0, base_color * 1.3)  # Overbright
	gradient.add_point(0.6, base_color)
	gradient.add_point(1.0, Color(base_color.r, base_color.g, base_color.b, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol root
	if Engine.get_main_loop() and Engine.get_main_loop().root:
		Engine.get_main_loop().root.add_child(particles)

		# Auto-destruir
		var timer = Engine.get_main_loop().root.get_tree().create_timer(particles.lifetime + 0.1)
		timer.timeout.connect(func(): particles.queue_free())

## Partículas de transformación/cambio de estado
static func spawn_transform_particles(pos: Vector2, from_color: Color, to_color: Color) -> void:
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.6
	particles.explosiveness = 0.5  # Semi-continua

	# Emisión circular - CPUParticles2D no tiene EMISSION_SHAPE_RING, usar SPHERE
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 16.0

	# Movimiento hacia afuera
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 60.0

	# Sin gravedad (efecto mágico)
	particles.gravity = Vector2.ZERO

	# Escala
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Rotación
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0

	# Gradient de color (de from_color a to_color)
	particles.color = from_color
	var gradient = Gradient.new()
	gradient.add_point(0.0, from_color)
	gradient.add_point(0.5, Color(
		(from_color.r + to_color.r) * 0.5,
		(from_color.g + to_color.g) * 0.5,
		(from_color.b + to_color.b) * 0.5,
		0.8
	))
	gradient.add_point(1.0, Color(to_color.r, to_color.g, to_color.b, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol root
	if Engine.get_main_loop() and Engine.get_main_loop().root:
		Engine.get_main_loop().root.add_child(particles)

		# Auto-destruir
		var timer = Engine.get_main_loop().root.get_tree().create_timer(particles.lifetime + 0.1)
		timer.timeout.connect(func(): particles.queue_free())

## Burst simple de partículas para eventos genéricos
static func spawn_burst(pos: Vector2, color: Color = Color.WHITE, amount: int = 15) -> void:
	var particles = CPUParticles2D.new()

	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 0.4
	particles.explosiveness = 1.0

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 6.0
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 100.0
	particles.gravity = Vector2(0, 150)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	particles.color = color
	var gradient = Gradient.new()
	gradient.add_point(0.0, color)
	gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = gradient

	if Engine.get_main_loop() and Engine.get_main_loop().root:
		Engine.get_main_loop().root.add_child(particles)
		var timer = Engine.get_main_loop().root.get_tree().create_timer(particles.lifetime + 0.1)
		timer.timeout.connect(func(): particles.queue_free())

## Partículas de rotura de máscara para Tutorial 0
static func spawn_mask_break(pos: Vector2 = Vector2.ZERO) -> void:
	# Crear efecto de máscara rompiéndose con múltiples tipos de partículas

	# 1. Fragmentos grandes de la máscara
	var large_fragments = CPUParticles2D.new()
	large_fragments.global_position = pos
	large_fragments.emitting = true
	large_fragments.one_shot = true
	large_fragments.amount = 12
	large_fragments.lifetime = 1.2
	large_fragments.explosiveness = 1.0

	large_fragments.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	large_fragments.emission_sphere_radius = 10.0
	large_fragments.direction = Vector2(0, 1)
	large_fragments.spread = 200.0
	large_fragments.initial_velocity_min = 100.0
	large_fragments.initial_velocity_max = 250.0
	large_fragments.gravity = Vector2(0, 400)

	large_fragments.scale_amount_min = 4.0
	large_fragments.scale_amount_max = 8.0
	large_fragments.angular_velocity_min = -540.0
	large_fragments.angular_velocity_max = 540.0

	# Color blanco/gris de la máscara
	large_fragments.color = Color(0.9, 0.9, 0.95, 1.0)
	var lg_gradient = Gradient.new()
	lg_gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 1.0))
	lg_gradient.add_point(0.5, Color(0.9, 0.9, 0.95, 0.8))
	lg_gradient.add_point(1.0, Color(0.7, 0.7, 0.8, 0.0))
	large_fragments.color_ramp = lg_gradient

	# 2. Polvo fino
	var fine_dust = CPUParticles2D.new()
	fine_dust.global_position = pos
	fine_dust.emitting = true
	fine_dust.one_shot = true
	fine_dust.amount = 40
	fine_dust.lifetime = 0.8
	fine_dust.explosiveness = 0.8

	fine_dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	fine_dust.emission_sphere_radius = 8.0
	fine_dust.direction = Vector2(0, -1)
	fine_dust.spread = 120.0
	fine_dust.initial_velocity_min = 30.0
	fine_dust.initial_velocity_max = 80.0
	fine_dust.gravity = Vector2(0, 100)

	fine_dust.scale_amount_min = 1.0
	fine_dust.scale_amount_max = 3.0
	fine_dust.angular_velocity_min = -90.0
	fine_dust.angular_velocity_max = 90.0

	fine_dust.color = Color(0.95, 0.95, 1.0, 0.6)
	var fd_gradient = Gradient.new()
	fd_gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 0.7))
	fd_gradient.add_point(1.0, Color(0.8, 0.8, 0.9, 0.0))
	fine_dust.color_ramp = fd_gradient

	# 3. Chispas de energía oscura
	var dark_sparks = CPUParticles2D.new()
	dark_sparks.global_position = pos
	dark_sparks.emitting = true
	dark_sparks.one_shot = true
	dark_sparks.amount = 20
	dark_sparks.lifetime = 0.5
	dark_sparks.explosiveness = 1.0

	dark_sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	dark_sparks.emission_sphere_radius = 5.0
	dark_sparks.direction = Vector2(0, 0)
	dark_sparks.spread = 360.0
	dark_sparks.initial_velocity_min = 150.0
	dark_sparks.initial_velocity_max = 300.0
	dark_sparks.gravity = Vector2.ZERO

	dark_sparks.scale_amount_min = 2.0
	dark_sparks.scale_amount_max = 4.0

	# Color púrpura oscuro de la corrupción
	dark_sparks.color = Color(0.4, 0.1, 0.6, 1.0)
	var ds_gradient = Gradient.new()
	ds_gradient.add_point(0.0, Color(0.6, 0.2, 0.8, 1.0))
	ds_gradient.add_point(0.5, Color(0.4, 0.1, 0.6, 0.8))
	ds_gradient.add_point(1.0, Color(0.2, 0.0, 0.3, 0.0))
	dark_sparks.color_ramp = ds_gradient

	# Añadir todos al árbol
	if Engine.get_main_loop() and Engine.get_main_loop().root:
		var root = Engine.get_main_loop().root

		root.add_child(large_fragments)
		root.add_child(fine_dust)
		root.add_child(dark_sparks)

		# Auto-destruir
		var max_lifetime = 1.3
		var timer = root.get_tree().create_timer(max_lifetime)
		timer.timeout.connect(func():
			large_fragments.queue_free()
			fine_dust.queue_free()
			dark_sparks.queue_free()
		)

## Efecto completo de revelación de Tutorial 0 con shake y flash
static func tutorial_0_reveal_effect(pos: Vector2) -> void:
	# Partículas de rotura de máscara
	spawn_mask_break(pos)

	# Acceder a los autoloads usando Engine.get_main_loop()
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop is SceneTree:
		var root = main_loop.root

		# Camera shake
		var camera_shake = root.get_node_or_null("CameraShake")
		if camera_shake and camera_shake.has_method("shake"):
			camera_shake.shake(0.8)

		# Screen flash rojo
		var screen_flash = root.get_node_or_null("ScreenFlash")
		if screen_flash and screen_flash.has_method("flash"):
			screen_flash.flash(Color.RED, 0.3)
