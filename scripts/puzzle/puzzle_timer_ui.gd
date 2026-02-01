extends Label
## UI simple para mostrar el progreso del TimedPuzzleController

@export var controller_path: NodePath = NodePath("")

var controller: Node = null

func _ready() -> void:
	visible = false

	if not controller_path.is_empty():
		controller = get_node(controller_path)
		if controller:
			controller.time_window_started.connect(_on_puzzle_started)
			controller.puzzle_completed.connect(_on_puzzle_completed)
			controller.puzzle_failed.connect(_on_puzzle_failed)
			controller.progress_changed.connect(_on_progress_changed)

func _on_puzzle_started(_duration: float) -> void:
	visible = true

func _on_puzzle_completed() -> void:
	text = "¡PUZZLE COMPLETADO!"
	modulate = Color.GREEN
	await get_tree().create_timer(2.0).timeout
	visible = false

func _on_puzzle_failed() -> void:
	text = "¡TIEMPO AGOTADO!"
	modulate = Color.RED
	await get_tree().create_timer(2.0).timeout
	visible = false

func _on_progress_changed(current: int, required: int) -> void:
	text = "Progreso: %d/%d" % [current, required]

func _process(_delta: float) -> void:
	if not controller or not visible:
		return

	if controller.is_active and controller.has("time_remaining"):
		var time_left = controller.time_remaining
		text = "Tiempo: %.1fs | Progreso: ?" % time_left

		# Color warning cuando queda poco tiempo
		if time_left < 3.0:
			modulate = Color.RED
		elif time_left < 5.0:
			modulate = Color.YELLOW
		else:
			modulate = Color.WHITE
