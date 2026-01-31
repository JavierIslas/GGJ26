class_name Projectile
extends Area2D
## Proyectil disparado por el Verdadero Enemigo
##
## Se mueve en línea recta y daña al jugador al contacto

@export var speed: float = 150.0
@export var damage: int = 1  # Reducido de 2 a 1 para mejor balance con iFrames
@export var lifetime: float = 5.0  # Auto-destrucción después de X segundos

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Configurar collision
	collision_layer = 8  # Layer 4: Projectiles
	collision_mask = 2   # Mask 2: Player

	# Conectar señal de colisión
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

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

		# Destruir el proyectil
		_destroy()

func _on_area_entered(area: Area2D) -> void:
	"""Colisiona con otras áreas (opcional, para destruir en paredes)"""
	# Por ahora no destruir en paredes, solo en jugador
	pass

func _destroy() -> void:
	"""Destruye el proyectil con efecto visual"""
	# TODO: Agregar partículas de explosión
	queue_free()
