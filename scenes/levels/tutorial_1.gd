extends Node2D
## Tutorial 1 Manager
##
## Primer nivel después de la muerte en Tutorial 0
## El jugador renace con el poder de Reveal desbloqueado

signal level_ready

func _ready() -> void:
	print("=== TUTORIAL 1 INICIADO ===")
	print("¡Revelación desbloqueada!")
	print("HP del jugador: %d" % GameManager.player_hp)

	# Inicializar Tutorial 1 (esto desbloquea reveal)
	GameManager.start_tutorial_1()

	# Mostrar estado actual
	_print_status()

	# Spawnear jugador si no existe
	_spawn_player_if_needed()

	# Emitir señal de que el nivel está listo
	level_ready.emit()

func _print_status() -> void:
	print("--- ESTADO DEL JUGADOR ---")
	print("HP: %d / %d" % [GameManager.player_hp, GameManager.max_hp])
	print("Verdades reveladas: %d" % GameManager.total_truths_revealed)
	print("Reveal desbloqueado: %s" % GameManager.reveal_unlocked)
	print("Dash desbloqueado: %s" % GameManager.dash_unlocked)
	print("--------------------------")

func _spawn_player_if_needed() -> void:
	# Verificar si ya existe un jugador en la escena
	var existing_player = get_tree().get_first_node_in_group("player")
	if existing_player:
		print("Jugador ya existe en la escena")
		return

	# Crear jugador en el spawn point
	var player_scene = load("res://scenes/characters/player.tscn")
	if player_scene:
		var player = player_scene.instantiate()
		add_child(player)

		# Posicionar en el spawn point
		var spawn_point = $PlayerSpawn
		if spawn_point:
			player.global_position = spawn_point.global_position
		else:
			player.global_position = Vector2(125, 300)

		print("Jugador spawnado en Tutorial 1")
	else:
		print("ERROR: No se pudo cargar escena del jugador")

func _input(event: InputEvent) -> void:
	# DEBUG: Presionar R para reiniciar el nivel
	if event.is_action_pressed("ui_cancel"):  # ESC
		print("Reiniciando Tutorial 1...")
		get_tree().reload_current_scene()
