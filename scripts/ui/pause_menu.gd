extends Control
## Menú de Pausa para VEIL
##
## Se activa con ESC, pausa el juego y muestra opciones

func _ready() -> void:
	# Ocultar por defecto
	visible = false

	# Configurar para que no sea afectado por la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# Toggle pausa con ESC
	if event.is_action_pressed("ui_cancel"):  # ESC
		_toggle_pause()

func _toggle_pause() -> void:
	"""Alterna entre pausado y no pausado"""
	var is_paused = get_tree().paused

	if is_paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	"""Pausa el juego y muestra el menú"""
	get_tree().paused = true
	visible = true

	# Focus en el botón Resume
	$CenterContainer/VBoxContainer/ResumeButton.grab_focus()

func _resume() -> void:
	"""Resume el juego y oculta el menú"""
	get_tree().paused = false
	visible = false

func _on_resume_button_pressed() -> void:
	_resume()

func _on_restart_button_pressed() -> void:
	# Despausar antes de cambiar de escena
	get_tree().paused = false

	# Resetear estado del nivel
	GameManager.reset_current_level()

	# Reiniciar el nivel actual
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	# Despausar antes de cambiar de escena
	get_tree().paused = false

	# Reiniciar estado del GameManager
	GameManager.reset_game()

	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
