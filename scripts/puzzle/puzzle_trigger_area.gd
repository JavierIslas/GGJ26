extends Area2D
## Área que inicia un TimedPuzzleController cuando el jugador entra

@export var puzzle_controller_path: NodePath = NodePath("")
@export var one_time_only: bool = true

var has_triggered: bool = false

func _ready() -> void:
	# Configurar collision para detectar al jugador
	collision_layer = 0
	collision_mask = 1  # Layer 1: Player

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if has_triggered and one_time_only:
		return

	if not body.is_in_group("player"):
		return

	# Iniciar puzzle
	if not puzzle_controller_path.is_empty():
		var controller = get_node(puzzle_controller_path)
		if controller and controller.has_method("start_puzzle"):
			controller.start_puzzle()
			has_triggered = true
			print("[PuzzleTriggerArea] Puzzle started!")
