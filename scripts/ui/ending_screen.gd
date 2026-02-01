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
		"name": "The Comfortable Lie",
		"color": Color(0.5, 0.5, 0.5),  # Gris (mediocridad, neutralidad)
		"threshold": 0.0,  # < 50%
		"narrative": "Revelaste pocas verdades.\nPreferiste la comodidad de la mentira.\n\nEscapaste del Velo...\npero no cambiaste nada.\n\nLas máscaras siguen ahí.\nLos depredadores siguen cazando.\nLas víctimas siguen sufriendo.\n\nY tú...\nvolviste a ponerte la tuya.\n\n\n[El mundo de máscaras permanece intacto]\n[Eres parte del sistema ahora]"
	},
	"awakening": {
		"name": "The Painful Truth",
		"color": Color(0.3, 0.6, 1.0),  # Azul (tristeza, verdad fría)
		"threshold": 50.0,  # 50-80%
		"narrative": "Revelaste muchas verdades.\nViste el mundo como realmente es.\n\nLos amenazantes eran víctimas.\nLos amigables eran depredadores.\nEl sistema era violento.\n\nEscapaste del Velo...\npero el peso te sigue.\n\nAhora sabes demasiado para ser feliz.\nPero no suficiente para cambiar todo.\n\nVives con la verdad.\nY duele.\n\n[La claridad tiene un precio]\n[Algunas heridas nunca sanan]"
	},
	"revelator": {
		"name": "The Big Bad Wolf",
		"color": Color(1.0, 1.0, 1.0),  # Blanco puro (verdad absoluta)
		"threshold": 80.0,  # > 80%
		"narrative": "Revelaste TODAS las verdades.\nArrancaste cada velo.\nConfrontaste cada mentira.\n\nNo fuiste amable.\nNo fuiste selectiva.\nNo perdonaste nada.\n\nLos depredadores te temieron.\nLas víctimas te admiraron.\nEl sistema... colapsó.\n\nYa no eres la niña asustada.\nYa no eres la víctima.\n\nEres el lobo ahora.\n\nY el bosque te pertenece.\n\n[I'm not your victim anymore]\n[I'm the big bad wolf now]"
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
