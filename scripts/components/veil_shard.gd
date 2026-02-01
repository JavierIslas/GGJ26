class_name VeilShard
extends Area2D
## Fragmento de Velo - Proyectil del Jugador
##
## NARRATIVA: Los velos arrancados se convierten en fragmentos cortantes de verdad.
##           "Tu máscara rota es MI arma ahora."
##
## COMPORTAMIENTO:
## - Solo daña a enemigos REVELADOS (False Friends, True Threats)
## - Atraviesa False Enemies sin dañarlos (son víctimas)
## - Puede destruir proyectiles de True Threats

@export var speed: float = 250.0
@export var damage: int = 1
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var launched: bool = false

func _ready() -> void:
	# Agregar al grupo de proyectiles
	add_to_group("projectiles")

	# Configurar collision
	collision_layer = 16  # Layer 5: Player Projectiles (nueva)
	collision_mask = 4 | 8  # Mask 3: Entities, Mask 4: Enemy Projectiles

	# Conectar señales de colisión
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-destrucción después del lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if not launched:
		return

	# Mover en la dirección establecida
	position += direction * speed * delta

	# OPTIMIZATION: Destroy if way off screen
	var camera = get_viewport().get_camera_2d()
	if camera:
		var screen_center = camera.get_screen_center_position()
		var screen_size = get_viewport_rect().size
		var margin = 200.0

		var left_bound = screen_center.x - screen_size.x / 2 - margin
		var right_bound = screen_center.x + screen_size.x / 2 + margin
		var top_bound = screen_center.y - screen_size.y / 2 - margin
		var bottom_bound = screen_center.y + screen_size.y / 2 + margin

		if global_position.x < left_bound or global_position.x > right_bound or \
		   global_position.y < top_bound or global_position.y > bottom_bound:
			queue_free()

func launch(dir: Vector2) -> void:
	"""Lanza el shard en una dirección"""
	direction = dir.normalized()
	rotation = direction.angle()
	launched = true

func _on_body_entered(body: Node2D) -> void:
	"""Colisiona con enemigos"""
	# Solo dañar enemigos revelados
	if not body.has_node("VeilComponent"):
		return

	var veil = body.get_node("VeilComponent")
	if not veil.is_revealed:
		# No dañar enemigos no revelados
		return

	# Identificar tipo de enemigo
	var is_false_enemy = body.is_class("FalseEnemy") or "FalseEnemy" in body.name

	if is_false_enemy:
		# False Enemies son víctimas - atravesar sin daño
		print("VeilShard atravesó False Enemy (víctima)")
		return

	# Dañar False Friends o True Threats
	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("VeilShard hit %s: -%d HP" % [body.name, damage])

	# Efecto de impacto
	_spawn_impact_particles()

	# Destruir el shard
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	"""Colisiona con proyectiles enemigos - los destruye"""
	if area.is_class("Projectile") or "Projectile" in area.name:
		# Destruir proyectil enemigo
		area.queue_free()

		# Efecto de destrucción
		_spawn_destruction_particles()

		print("VeilShard destroyed enemy projectile")

		# Destruir el shard también
		queue_free()

func _spawn_impact_particles() -> void:
	"""Partículas de impacto cuando golpea enemigo"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 15
	particles.lifetime = 0.4
	particles.explosiveness = 1.0

	# Emisión radial
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 4.0

	# Explosión en dirección opuesta
	particles.direction = Vector2(-direction.x, -direction.y)
	particles.spread = 90.0
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 80.0

	# Gravedad ligera
	particles.gravity = Vector2(0, 100)

	# Escala pequeña
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Color blanco brillante (verdad/luz)
	particles.color = Color(1.5, 1.5, 1.5, 1.0)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.5, 1.5, 1.5, 1.0))
	gradient.add_point(0.6, Color(1.0, 1.0, 1.0, 0.7))
	gradient.add_point(1.0, Color(1.0, 1.0, 1.0, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir
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

func _spawn_destruction_particles() -> void:
	"""Partículas cuando destruye un proyectil enemigo"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.5
	particles.explosiveness = 1.0

	# Emisión radial
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 6.0

	# Explosión radial
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 120.0

	# Gravedad ligera
	particles.gravity = Vector2(0, 150)

	# Escala variable
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0

	# Rotación
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0

	# Color azul/blanco (choque de energías)
	particles.color = Color(0.5, 0.8, 1.5, 1.0)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.8, 1.0, 1.5, 1.0))
	gradient.add_point(0.6, Color(0.5, 0.7, 1.0, 0.7))
	gradient.add_point(1.0, Color(0.3, 0.5, 0.8, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir
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
