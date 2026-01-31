extends Node
## ProjectileManager: Maneja proyectiles y evita memory leaks
##
## Los proyectiles se añaden a un contenedor que se limpia automáticamente
## al cambiar de nivel, evitando que persistan en memoria

var projectile_container: Node = null

func _ready() -> void:
	# Conectar a cambios de escena para limpiar proyectiles
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	# Detectar cuando se carga un nuevo nivel
	if node == get_tree().current_scene:
		_setup_projectile_container()

func _setup_projectile_container() -> void:
	"""Crea un contenedor para proyectiles en el nivel actual"""
	# Limpiar contenedor anterior si existe
	if projectile_container and is_instance_valid(projectile_container):
		projectile_container.queue_free()

	# Crear nuevo contenedor en la escena actual
	var current_scene = get_tree().current_scene
	if current_scene:
		projectile_container = Node.new()
		projectile_container.name = "Projectiles"
		current_scene.add_child(projectile_container)
		print("ProjectileManager: Container created in %s" % current_scene.name)

func add_projectile(projectile: Node2D) -> void:
	"""Añade un proyectil al contenedor del nivel actual"""
	if not projectile_container or not is_instance_valid(projectile_container):
		_setup_projectile_container()

	if projectile_container:
		projectile_container.add_child(projectile)
	else:
		# Fallback: añadir a la escena actual
		push_warning("ProjectileManager: No container, adding to current scene")
		get_tree().current_scene.add_child(projectile)

func clear_all_projectiles() -> void:
	"""Limpia todos los proyectiles (útil al cambiar de nivel)"""
	if projectile_container and is_instance_valid(projectile_container):
		for child in projectile_container.get_children():
			child.queue_free()
		print("ProjectileManager: All projectiles cleared")
