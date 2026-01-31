extends Control
## Main Menu para VEIL
##
## Pantalla inicial del juego con botones Play y Quit

func _ready() -> void:
	# Focus en el botón Play
	$VBoxContainer/PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	# Reiniciar estado del GameManager
	GameManager.reset_game()

	# Cargar nivel de prueba (cambiar a level_01 cuando esté listo)
	get_tree().change_scene_to_file("res://scenes/levels/test_level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
