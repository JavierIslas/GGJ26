class_name ParticleEffects
extends Node
## Utilidad estática para crear efectos de partículas reutilizables
##
## Uso: ParticleEffects.spawn_death_particles(position, color)

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
