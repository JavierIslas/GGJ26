extends StaticBody2D
## Puerta controlada por un TimedPuzzleController

@export var puzzle_controller_path: NodePath = NodePath("")
@export var open_direction: Vector2 = Vector2(0, -200)
@export var open_duration: float = 1.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

var is_open: bool = false
var initial_position: Vector2

func _ready() -> void:
	initial_position = global_position

	# Conectar al controller
	if not puzzle_controller_path.is_empty():
		var controller = get_node(puzzle_controller_path)
		if controller and controller.has_signal("puzzle_completed"):
			controller.puzzle_completed.connect(_on_puzzle_completed)
			print("[PuzzleControlledDoor] Connected to controller: %s" % puzzle_controller_path)

func _on_puzzle_completed() -> void:
	if is_open:
		return

	print("[PuzzleControlledDoor] Puzzle completed - opening door!")
	is_open = true

	# Deshabilitar colisión
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	# Animación de apertura
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", initial_position + open_direction, open_duration)

	# Fade out
	var fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_property(self, "modulate:a", 0.0, open_duration * 0.5).set_delay(open_duration * 0.5)

	# SFX
	AudioManager.play_sfx("door_open", -3.0)
