extends Control
## Ending Screen para VEIL
##
## Muestra el ending final basado en el % de verdades reveladas globalmente

@onready var title_label: Label = $CenterContainer/VBoxContainer/Title
@onready var ending_name_label: Label = $CenterContainer/VBoxContainer/EndingName
@onready var narrative_text: RichTextLabel = $CenterContainer/VBoxContainer/ScrollContainer/NarrativeText
@onready var stats_label: Label = $CenterContainer/VBoxContainer/StatsLabel
@onready var percentage_label: Label = $CenterContainer/VBoxContainer/PercentageLabel
@onready var new_game_button: Button = $CenterContainer/VBoxContainer/NewGameButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton

# Configuración de endings
const ENDINGS = {
	"ignorance": {
		"name": "Ignorancia",
		"color": Color(0.7, 0.3, 0.3),  # Rojo oscuro
		"threshold": 0.0,  # < 50%
		"narrative": "Cerraste los ojos ante la verdad.\n\nPreferiste la comodidad de la ignorancia, dejando la mayoría de los velos intactos. El mundo sigue igual que antes, con sus máscaras y sus mentiras.\n\nTe convenciste de que algunas verdades no merecen ser confrontadas. Quizás tengas razón. Quizás no.\n\nPero en las noches oscuras, aún puedes sentir el peso de los velos que dejaste sin arrancar."
	},
	"awakening": {
		"name": "Despertar",
		"color": Color(0.3, 0.8, 1.0),  # Azul brillante
		"threshold": 50.0,  # 50-80%
		"narrative": "Confrontaste la verdad, pero no sin costo.\n\nArrancaste suficientes velos para ver el mundo tal como es: un lugar de hipocresía y dualidad. Los monstruos que parecían amigos. Las víctimas que parecían amenazas.\n\nLa verdad duele. Ahora lo sabes mejor que nadie.\n\nPero el conocimiento viene con un precio. Algunas verdades te perseguirán. Algunas heridas nunca sanarán.\n\n¿Valió la pena? Solo tú puedes responder eso."
	},
	"revelator": {
		"name": "El Revelador",
		"color": Color(1.0, 0.84, 0.0),  # Dorado
		"threshold": 80.0,  # > 80%
		"narrative": "No dejaste ningún velo sin arrancar.\n\nCon valor implacable, confrontaste cada verdad, sin importar las consecuencias. El mundo ya no puede esconderse de ti.\n\nVes las máscaras en todas partes. La hipocresía. Las mentiras. La dualidad de cada ser.\n\nEres El Revelador. El que no teme a la verdad.\n\nPero en un mundo donde todos llevan máscaras, ¿qué significa ser el único que puede verlas?\n\nLa soledad del conocimiento absoluto es tu recompensa. Y tu maldición."
	}
}

func _ready() -> void:
	# Configurar para que no sea afectado por la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Ocultar por defecto
	visible = false

func show_ending() -> void:
	"""Muestra el ending basado en el % de verdades reveladas"""
	visible = true

	# Pausar el juego
	get_tree().paused = true

	# Calcular porcentaje global
	var percentage = GameManager.get_truth_percentage()

	# Determinar qué ending mostrar
	var ending_data = _get_ending_for_percentage(percentage)

	# Actualizar UI
	ending_name_label.text = ending_data["name"].to_upper()
	ending_name_label.modulate = ending_data["color"]

	narrative_text.text = ending_data["narrative"]

	# Stats globales
	stats_label.text = "Truths Revealed: %d / %d" % [
		GameManager.total_truths_revealed,
		GameManager.total_truths_possible
	]

	percentage_label.text = "Completion: %.1f%%" % percentage

	# Colorear percentage según ranking
	percentage_label.modulate = ending_data["color"]

	# Enfocar botón
	new_game_button.grab_focus()

	# Animación de entrada
	_play_entrance_animation()

func _get_ending_for_percentage(percentage: float) -> Dictionary:
	"""Determina qué ending corresponde al porcentaje dado"""
	if percentage >= ENDINGS["revelator"]["threshold"]:
		return ENDINGS["revelator"]
	elif percentage >= ENDINGS["awakening"]["threshold"]:
		return ENDINGS["awakening"]
	else:
		return ENDINGS["ignorance"]

func _play_entrance_animation() -> void:
	"""Animación de entrada con fade"""
	var container = $CenterContainer/VBoxContainer

	# Estado inicial
	container.modulate.a = 0.0

	# Tween de entrada
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)

func _on_new_game_button_pressed() -> void:
	"""Inicia un nuevo juego desde el principio"""
	# Despausar
	get_tree().paused = false

	# Resetear GameManager completamente
	GameManager.reset_game()

	# FIX MEMORY LEAK: Limpiar proyectiles antes de nuevo juego
	ProjectileManager.clear_all_projectiles()

	# Cargar Level 1
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_menu_button_pressed() -> void:
	"""Vuelve al menú principal"""
	# Despausar
	get_tree().paused = false

	# Resetear GameManager
	GameManager.reset_game()

	# FIX MEMORY LEAK: Limpiar proyectiles antes de volver a menú
	ProjectileManager.clear_all_projectiles()

	# Volver al menú
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
