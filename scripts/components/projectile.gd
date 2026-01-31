class_name Projectile
extends Area2D
## Proyectil disparado por el Verdadero Enemigo
##
## Se mueve en línea recta y daña al jugador al contacto

@export var speed: float = 150.0
@export var damage: int = 2
@export var lifetime: float = 5.0  # Auto-destrucción después de X segundos

var direction: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0

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

	# Actualizar tiempo de vida
	time_alive += delta

func set_direction(dir: Vector2) -> void:
	"""Establece la dirección del proyectil (debe estar normalizada)"""
	direction = dir.normalized()

	# Rotar el sprite para que apunte en la dirección correcta
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	"""Colisiona con el jugador"""
	if body.is_in_group("player"):
		# Dañar al jugador
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
