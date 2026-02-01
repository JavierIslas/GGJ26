extends StaticBody2D
## Plataforma que aparece al activar un PuzzleSwitch

@export var puzzle_switch_path: NodePath = NodePath("")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	# Inicialmente invisible y sin colisión
	if collision_shape:
		collision_shape.disabled = true

	modulate.a = 0.3

	# Conectar al switch
	if not puzzle_switch_path.is_empty():
		var switch = get_node(puzzle_switch_path)
		if switch and switch.has_signal("activated"):
			switch.activated.connect(_on_switch_activated)
			print("[ActivatedPlatform] Connected to switch: %s" % puzzle_switch_path)

func _on_switch_activated() -> void:
	print("[ActivatedPlatform] Switch activated - appearing!")

	# Habilitar colisión
	if collision_shape:
		collision_shape.disabled = false

	# Animación de aparición
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

	# SFX
	AudioManager.play_sfx("switch_on", -3.0)
