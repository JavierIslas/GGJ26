extends Area2D
## Shard Pickup - Da shards extra al jugador

@export var shard_amount: int = 1
@export var auto_collect: bool = true

var collected: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # Layer 2: Player

	body_entered.connect(_on_body_entered)

	# Visual feedback
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		sprite.modulate = Color(0.7, 0.9, 1.0)  # Azul claro (shards)

		# Animación idle (rotación + bounce)
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(sprite, "rotation", TAU, 2.0)

		var tween2 = create_tween()
		tween2.set_loops()
		tween2.tween_property(sprite, "position:y", -5, 0.5).set_trans(Tween.TRANS_SINE)
		tween2.tween_property(sprite, "position:y", 0, 0.5).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	if auto_collect:
		_collect()

func _collect() -> void:
	collected = true

	# Dar shards al jugador
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_veil_shard"):
		for i in shard_amount:
			player.add_veil_shard()

	print("[ShardPickup] +%d Shard(s) collected!" % shard_amount)

	# SFX
	AudioManager.play_sfx("shard_collect", -5.0)

	# Feedback visual
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "position:y", sprite.position.y - 40, 0.4)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.4)

	await get_tree().create_timer(0.4).timeout
	queue_free()
