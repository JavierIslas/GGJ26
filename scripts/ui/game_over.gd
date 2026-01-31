extends Control
## Pantalla de Game Over para VEIL
##
## Aparece cuando el jugador muere (HP = 0)

@onready var truths_label: Label = $CenterContainer/VBoxContainer/TruthsLabel

func _ready() -> void:
	# Configurar para que no sea afectado por la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Ocultar por defecto
	visible = false

func show_game_over() -> void:
	"""Muestra la pantalla de Game Over"""
	visible = true

	# Focus en el botón Restart
	$CenterContainer/VBoxContainer/RestartButton.grab_focus()

	# Mostrar estadísticas
	_update_stats()

func _update_stats() -> void:
	"""Actualiza las estadísticas mostradas"""
	var truths = GameManager.total_truths_revealed
	var possible = GameManager.total_truths_possible

	if possible > 0:
		var percentage = (float(truths) / float(possible)) * 100.0
		truths_label.text = "Verdades reveladas: %d / %d (%.0f%%)" % [truths, possible, percentage]
	else:
		truths_label.text = "Verdades reveladas: %d" % truths

func _on_restart_button_pressed() -> void:
	# Despausar si estaba pausado
	get_tree().paused = false

	# Resetear estado del nivel
	GameManager.reset_current_level()

	# FIX MEMORY LEAK: Limpiar proyectiles antes de reiniciar
	ProjectileManager.clear_all_projectiles()

	# Reiniciar nivel
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	# Despausar si estaba pausado
	get_tree().paused = false

	# Reiniciar estado del GameManager
	GameManager.reset_game()

	# FIX MEMORY LEAK: Limpiar proyectiles antes de volver a menú
	ProjectileManager.clear_all_projectiles()

	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
