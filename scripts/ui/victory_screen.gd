extends Control
## Victory Screen para VEIL
##
## Muestra estadísticas al completar un nivel y permite continuar o volver

@onready var title_label: Label = $CenterContainer/VBoxContainer/Title
@onready var truths_label: Label = $CenterContainer/VBoxContainer/TruthsLabel
@onready var percentage_label: Label = $CenterContainer/VBoxContainer/PercentageLabel
@onready var rank_label: Label = $CenterContainer/VBoxContainer/RankLabel
@onready var next_button: Button = $CenterContainer/VBoxContainer/NextLevelButton
@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton

var next_level_path: String = ""
var current_level_path: String = ""

func _ready() -> void:
	# Configurar para que no sea afectado por la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Ocultar por defecto
	visible = false

func show_victory(truths_revealed: int, truths_possible: int, next_level: String = "", current_level: String = "") -> void:
	"""Muestra la pantalla de victoria con estadísticas"""
	visible = true
	next_level_path = next_level
	current_level_path = current_level

	# Pausar el juego
	get_tree().paused = true

	# Calcular estadísticas
	var percentage = 0.0
	if truths_possible > 0:
		percentage = (float(truths_revealed) / float(truths_possible)) * 100.0

	# Calcular ranking
	var rank = _calculate_rank(percentage)

	# Actualizar labels
	truths_label.text = "Truths Revealed: %d / %d" % [truths_revealed, truths_possible]
	percentage_label.text = "Completion: %.0f%%" % percentage
	rank_label.text = "Rank: %s" % rank

	# Colorear rank
	_color_rank_label(rank)

	# Configurar botones
	if next_level_path != "":
		next_button.disabled = false
		next_button.grab_focus()
	else:
		next_button.disabled = true
		retry_button.grab_focus()

	# Animación de entrada
	_play_entrance_animation()

func _calculate_rank(percentage: float) -> String:
	"""Calcula el ranking según el porcentaje"""
	if percentage >= 100.0:
		return "S"  # Perfect
	elif percentage >= 80.0:
		return "A"  # Great
	elif percentage >= 60.0:
		return "B"  # Good
	elif percentage >= 40.0:
		return "C"  # Average
	else:
		return "D"  # Poor

func _color_rank_label(rank: String) -> void:
	"""Colorea el label del rank según su valor"""
	match rank:
		"S":
			rank_label.modulate = Color(1.0, 0.84, 0.0)  # Dorado
		"A":
			rank_label.modulate = Color(0.0, 1.0, 0.5)  # Verde brillante
		"B":
			rank_label.modulate = Color(0.3, 0.8, 1.0)  # Azul
		"C":
			rank_label.modulate = Color(1.0, 1.0, 0.3)  # Amarillo
		"D":
			rank_label.modulate = Color(1.0, 0.3, 0.3)  # Rojo

func _play_entrance_animation() -> void:
	"""Animación de entrada con fade y escala"""
	var container = $CenterContainer/VBoxContainer

	# Estado inicial
	container.modulate.a = 0.0
	container.scale = Vector2(0.8, 0.8)

	# Tween de entrada
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(container, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "scale", Vector2.ONE, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_next_level_button_pressed() -> void:
	"""Carga el siguiente nivel"""
	if next_level_path == "":
		return

	# Despausar
	get_tree().paused = false

	# FIX MEMORY LEAK: Limpiar proyectiles antes de cambiar de nivel
	ProjectileManager.clear_all_projectiles()

	# Cargar siguiente nivel
	get_tree().change_scene_to_file(next_level_path)

func _on_retry_button_pressed() -> void:
	"""Reinicia el nivel actual"""
	# Despausar
	get_tree().paused = false

	# Resetear estado del nivel
	GameManager.reset_current_level()

	# FIX MEMORY LEAK: Limpiar proyectiles antes de recargar nivel
	ProjectileManager.clear_all_projectiles()

	# Recargar nivel
	if current_level_path != "":
		get_tree().change_scene_to_file(current_level_path)
	else:
		get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	"""Vuelve al menú principal"""
	# Despausar
	get_tree().paused = false

	# Resetear GameManager
	GameManager.reset_game()

	# FIX MEMORY LEAK: Limpiar proyectiles antes de ir al menú
	ProjectileManager.clear_all_projectiles()

	# Volver al menú
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
