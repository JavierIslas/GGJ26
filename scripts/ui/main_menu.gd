extends Control
## Main Menu para VEIL
##
## Pantalla inicial del juego con opciones de Play, Options, Quit

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Focus en el botón Play
	play_button.grab_focus()

	# Reiniciar GameManager al volver al menú
	GameManager.reset_game()

func _on_play_button_pressed() -> void:
	"""Inicia el juego desde Level 1"""
	print("Starting game...")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_options_button_pressed() -> void:
	"""Abre menú de opciones (placeholder por ahora)"""
	print("Options menu not implemented yet")
	# TODO: Implementar menú de opciones con controles de volumen, etc.

func _on_quit_button_pressed() -> void:
	"""Cierra el juego"""
	print("Quitting game...")
	get_tree().quit()
