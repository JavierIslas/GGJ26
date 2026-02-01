extends Area2D
## HP Pickup - Restaura vida del jugador

@export var hp_amount: int = 1
@export var auto_collect: bool = true

var collected: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # Layer 2: Player

	body_entered.connect(_on_body_entered)

	# Visual feedback
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		sprite.modulate = Color(0.3, 1.0, 0.3)  # Verde (salud)

		# Animación idle (bounce)
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(sprite, "position:y", -5, 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite, "position:y", 0, 0.5).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	if auto_collect:
		_collect()

func _collect() -> void:
	collected = true

	# Dar HP al jugador
	GameManager.change_health(hp_amount)

	print("[HPPickup] +%d HP collected!" % hp_amount)

	# SFX
	AudioManager.play_sfx("pickup", -5.0)

	# Feedback visual
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "position:y", sprite.position.y - 30, 0.3)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)

	await get_tree().create_timer(0.3).timeout
	queue_free()
