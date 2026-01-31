extends Node
class_name LevelManager
## Gestiona el estado y configuración de un nivel específico
##
## Se encarga de:
## - Contar entidades revelables al inicio
## - Resetear current_level_truths
## - Actualizar total_truths_possible

# Guardar estado al inicio del nivel para poder resetear
var level_start_total_truths: int = 0

func _ready() -> void:
	# Agregar al grupo para que GameManager pueda encontrarlo
	add_to_group("level_manager")

	# Esperar un frame para asegurar que todas las entidades estén listas
	await get_tree().process_frame

	# Guardar el total de verdades al INICIO del nivel
	level_start_total_truths = GameManager.total_truths_revealed

	# Resetear verdades del nivel actual
	GameManager.current_level_truths = 0

	# Contar entidades revelables
	_count_revealable_entities()

	print("Level initialized - Revealable entities: %d" % _get_entity_count())

func _count_revealable_entities() -> void:
	"""Cuenta todas las verdades revelables en el nivel"""
	var truth_count = 0
	var entity_count = 0

	print("=== LevelManager: Counting entities ===")

	# Buscar todos los nodos con VeilComponent
	for node in get_tree().get_nodes_in_group("entities"):
		if node.has_node("VeilComponent"):
			entity_count += 1
			# Verificar si tiene la propiedad truth_count (para entidades multi-revelación)
			if "truth_count" in node:
				print("  - %s: %d truths (has truth_count property)" % [node.name, node.truth_count])
				truth_count += node.truth_count
			else:
				print("  - %s: 1 truth (normal entity)" % [node.name])
				truth_count += 1

	# Si no hay grupo "entities", buscar por VeilComponent directamente
	if truth_count == 0:
		print("  No entities in group, searching for VeilComponents...")
		var veil_components = _find_all_veil_components(get_tree().root)
		for component in veil_components:
			var parent = component.get_parent()
			entity_count += 1
			if parent and "truth_count" in parent:
				print("  - %s: %d truths (has truth_count property)" % [parent.name, parent.truth_count])
				truth_count += parent.truth_count
			else:
				print("  - %s: 1 truth (normal entity)" % [parent.name if parent else "Unknown"])
				truth_count += 1

	# Actualizar GameManager
	GameManager.total_truths_possible = GameManager.total_truths_revealed + truth_count

	print("=== Total: %d entities = %d truths ===" % [entity_count, truth_count])
	print("GameManager.total_truths_revealed = %d" % GameManager.total_truths_revealed)
	print("GameManager.total_truths_possible = %d" % GameManager.total_truths_possible)

func _find_all_veil_components(node: Node) -> Array:
	"""Busca recursivamente todos los VeilComponent en el árbol"""
	var components = []

	for child in node.get_children():
		if child.name == "VeilComponent":
			components.append(child)
		components.append_array(_find_all_veil_components(child))

	return components

func _get_entity_count() -> int:
	"""Retorna el número de entidades revelables encontradas"""
	return GameManager.total_truths_possible - GameManager.total_truths_revealed

func get_level_start_truths() -> int:
	"""Retorna el total de verdades al inicio del nivel"""
	return level_start_total_truths
