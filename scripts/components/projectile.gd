class_name Projectile
extends Area2D
## Proyectil disparado por el Verdadero Enemigo
##
## Se mueve en línea recta y daña al jugador al contacto

@export var speed: float = 150.0
@export var damage: int = 1  # Reducido de 2 a 1 para mejor balance con iFrames
@export var lifetime: float = 5.0  # Auto-destrucción después de X segundos
@export var trail_enabled: bool = false  # DESACTIVADO - Causa lag con muchos proyectiles

var direction: Vector2 = Vector2.RIGHT
var trail_particles: CPUParticles2D = null

func _ready() -> void:
	# Configurar collision
	collision_layer = 8  # Layer 4: Projectiles
	collision_mask = 2   # Mask 2: Player

	# Conectar señal de colisión
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# === POLISH: Trail particles ===
	if trail_enabled:
		_setup_trail_particles()

	# Auto-destrucción después del lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Mover en la dirección establecida
	position += direction * speed * delta

	# OPTIMIZATION: Destroy if way off screen to prevent accumulation
	# Use camera position instead of viewport size for large levels
	var camera = get_viewport().get_camera_2d()
	if camera:
		var screen_center = camera.get_screen_center_position()
		var screen_size = get_viewport_rect().size
		var margin = 200.0

		# Calculate screen bounds based on camera position
		var left_bound = screen_center.x - screen_size.x / 2 - margin
		var right_bound = screen_center.x + screen_size.x / 2 + margin
		var top_bound = screen_center.y - screen_size.y / 2 - margin
		var bottom_bound = screen_center.y + screen_size.y / 2 + margin

		if global_position.x < left_bound or global_position.x > right_bound or \
		   global_position.y < top_bound or global_position.y > bottom_bound:
			queue_free()

func set_direction(dir: Vector2) -> void:
	"""Establece la dirección del proyectil (debe estar normalizada)"""
	direction = dir.normalized()

	# Rotar el sprite para que apunte en la dirección correcta
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	"""Colisiona con el jugador"""
	if body.is_in_group("player"):
		# Dañar al jugador usando el sistema de iFrames
		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			# Fallback si el jugador no tiene el método
			GameManager.change_health(-damage)

		print("Projectile hit player: -%d HP" % damage)

		# === POLISH: Partículas de impacto ===
		_spawn_impact_particles()

		# Destruir el proyectil
		_destroy()

func _on_area_entered(area: Area2D) -> void:
	"""Colisiona con otras áreas (opcional, para destruir en paredes)"""
	# Por ahora no destruir en paredes, solo en jugador
	pass

func _destroy() -> void:
	"""Destruye el proyectil con efecto visual"""
	queue_free()

# === POLISH & JUICE METHODS ===

func _setup_trail_particles() -> void:
	"""Crea partículas de trail detrás del proyectil"""
	trail_particles = CPUParticles2D.new()

	# Configuración básica
	trail_particles.emitting = true
	trail_particles.amount = 15
	trail_particles.lifetime = 0.4
	trail_particles.preprocess = 0.1
	trail_particles.explosiveness = 0.0  # Emisión continua

	# Emisión en punto (en el proyectil)
	trail_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT

	# Sin dirección específica (solo fade)
	trail_particles.direction = Vector2(0, 0)
	trail_particles.spread = 0.0
	trail_particles.initial_velocity_min = 0.0
	trail_particles.initial_velocity_max = 5.0

	# Sin gravedad
	trail_particles.gravity = Vector2.ZERO

	# Escala pequeña decreciente
	trail_particles.scale_amount_min = 2.0
	trail_particles.scale_amount_max = 4.0
	trail_particles.scale_amount_curve = _create_decay_curve()

	# Color basado en el sprite del proyectil (rojo/púrpura)
	var sprite = get_node_or_null("Sprite2D")
	var trail_color = Color(0.8, 0.3, 0.5, 0.6) if sprite else Color(1.0, 0.5, 0.5, 0.6)

	trail_particles.color = trail_color
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(trail_color.r, trail_color.g, trail_color.b, 0.8))
	gradient.add_point(1.0, Color(trail_color.r, trail_color.g, trail_color.b, 0.0))
	trail_particles.color_ramp = gradient

	# Añadir como hijo del proyectil
	add_child(trail_particles)

func _create_decay_curve() -> Curve:
	"""Crea una curva de decay para el trail"""
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	return curve

func _spawn_impact_particles() -> void:
	"""Partículas de impacto cuando golpea al jugador"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.5
	particles.explosiveness = 1.0

	# Emisión radial desde el punto de impacto
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 4.0

	# Explosión en dirección opuesta al movimiento
	particles.direction = Vector2(-direction.x, -direction.y)
	particles.spread = 90.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 120.0

	# Gravedad ligera
	particles.gravity = Vector2(0, 150)

	# Escala pequeña
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Rotación
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0

	# Color rojo/naranja (impacto de daño)
	particles.color = Color(1.0, 0.4, 0.3, 0.9)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.2, 0.5, 0.3, 1.0))  # Naranja brillante
	gradient.add_point(0.6, Color(0.9, 0.3, 0.2, 0.7))
	gradient.add_point(1.0, Color(0.8, 0.2, 0.1, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol root
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
