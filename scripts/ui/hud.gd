extends CanvasLayer
## HUD para VEIL
##
## Muestra contador de verdades reveladas y HP del jugador

@onready var truth_label: Label = $MarginContainer/VBoxContainer/TruthCounter
@onready var hp_container: HBoxContainer = $MarginContainer/VBoxContainer/HPContainer

## Sprites de corazones (se crearán dinámicamente)
var heart_sprites: Array[ColorRect] = []

func _ready() -> void:
	# Conectar señales del GameManager
	GameManager.truth_revealed.connect(_on_truth_revealed)
	GameManager.health_changed.connect(_on_health_changed)

	# Inicializar display
	_update_truth_display()
	_setup_hearts()

func _setup_hearts() -> void:
	"""Crea los sprites de corazones según max_hp"""
	# Limpiar corazones existentes
	for child in hp_container.get_children():
		child.queue_free()
	heart_sprites.clear()

	# Crear corazones (usando ColorRect como placeholder)
	for i in GameManager.max_hp:
		var heart = ColorRect.new()
		heart.custom_minimum_size = Vector2(24, 24)
		heart.size = Vector2(24, 24)
		heart.color = Color(1.0, 0.3, 0.3)  # Rojo por defecto

		hp_container.add_child(heart)
		heart_sprites.append(heart)

	_update_hearts_display()

func _update_truth_display() -> void:
	"""Actualiza el contador de verdades"""
	var current = GameManager.total_truths_revealed
	var total = GameManager.total_truths_possible

	if total > 0:
		truth_label.text = "Verdades: %d / %d" % [current, total]
	else:
		truth_label.text = "Verdades: %d" % current

func _update_hearts_display() -> void:
	"""Actualiza el display de corazones según HP actual"""
	var current_hp = GameManager.player_hp

	for i in heart_sprites.size():
		if i < current_hp:
			# Corazón lleno
			heart_sprites[i].color = Color(1.0, 0.3, 0.3)  # Rojo
		else:
			# Corazón vacío
			heart_sprites[i].color = Color(0.3, 0.3, 0.3)  # Gris oscuro

func _on_truth_revealed(_total: int) -> void:
	"""Callback cuando se revela una verdad"""
	_update_truth_display()

	# Efecto de "bump" en el label
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	truth_label.scale = Vector2.ONE
	tween.tween_property(truth_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(truth_label, "scale", Vector2.ONE, 0.2)

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	"""Callback cuando cambia la salud"""
	_update_hearts_display()

	# Efecto de shake en los corazones cuando se pierde HP
	if _current_hp < GameManager.player_hp:
		for heart in heart_sprites:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BOUNCE)
			var original_rotation = heart.rotation
			tween.tween_property(heart, "rotation", deg_to_rad(15), 0.1)
			tween.tween_property(heart, "rotation", deg_to_rad(-15), 0.1)
			tween.tween_property(heart, "rotation", original_rotation, 0.1)
