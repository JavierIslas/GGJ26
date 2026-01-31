class_name VeilComponent
extends Node
## Componente que marca una entidad como "enmascarada"
##
## Cuando se revela el velo, este componente emite señales
## y cambia el estado de la entidad padre.

signal veil_torn
signal being_revealed  # Durante animación

@export var is_revealed: bool = false
@export var can_be_revealed: bool = true

## Referencia a la entidad padre (auto-detectada)
var parent_entity: Node2D

func _ready() -> void:
	parent_entity = get_parent()

	if not parent_entity:
		push_error("VeilComponent debe ser hijo de un Node2D")
		return

## Arranca el velo de la entidad
func tear_veil() -> void:
	if is_revealed or not can_be_revealed:
		return

	is_revealed = true
	being_revealed.emit()

	# Notificar al GameManager
	GameManager.reveal_truth()

	# Animación de revelación (0.25s según GDD)
	await get_tree().create_timer(0.25).timeout

	# Señal final de revelación completa
	veil_torn.emit()

	# Notificar a la entidad padre que fue revelada
	if parent_entity.has_method("_on_veil_torn"):
		parent_entity._on_veil_torn()

## Reinicia el componente (útil para testing)
func reset() -> void:
	is_revealed = false
