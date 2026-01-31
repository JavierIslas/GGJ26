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

	# Cargar nivel de prueba simple (sin TileMap)
	get_tree().change_scene_to_file("res://scenes/levels/test_level_simple.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
