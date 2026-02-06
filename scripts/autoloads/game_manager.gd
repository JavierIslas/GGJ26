extends Node
## GameManager: Maneja el estado global del juego
##
## Singleton que persiste entre escenas, guardando datos importantes como:
## - Contador total de verdades reveladas
## - Nivel actual
## - HP del jugador
## - Progreso para endings

# Estadísticas globales
var total_truths_revealed: int = 0
var total_truths_possible: int = 0

# Estado del nivel actual
var current_level: int = 0  # 0 = Tutorial, 1-3 = Niveles principales
var current_level_truths: int = 0
var max_levels: int = 3  # Total de niveles principales (sin contar tutorial)

# Estado del jugador
var player_hp: int = 5
var max_hp: int = 5

# Tutorial 0 - Sistema especial
var tutorial_0_active: bool = false
var tutorial_0_one_life: bool = true  # Muerte = transición a Tutorial 1

# Habilidades desbloqueables
var reveal_unlocked: bool = false  # Tutorial 0: false, Tutorial 1+: true
var dash_unlocked: bool = false    # Tutorial 1: false, después: true

# Señales para comunicar cambios
signal truth_revealed(total: int)
signal health_changed(current_hp: int, max_hp: int)
signal level_completed(level_number: int)

func _ready() -> void:
	print("GameManager initialized")

## Registra una verdad revelada
func reveal_truth() -> void:
	total_truths_revealed += 1
	current_level_truths += 1
	truth_revealed.emit(total_truths_revealed)
	print("Truth revealed! Total: %d" % total_truths_revealed)

## Cambia la vida del jugador
func change_health(amount: int) -> void:
	# Tutorial 0: SÍ puede recibir daño (para muerte scripted)
	# Tutorial 1+: Daño normal

	player_hp = clamp(player_hp + amount, 0, max_hp)
	health_changed.emit(player_hp, max_hp)

	# SFX de daño
	if amount < 0:
		AudioManager.play_sfx("damage", -3.0)

	if player_hp <= 0:
		player_died()

## Inicia Tutorial 0 (sin habilidades)
func start_tutorial_0() -> void:
	tutorial_0_active = true
	reveal_unlocked = false
	dash_unlocked = false
	current_level = 0
	player_hp = max_hp
	print("Tutorial 0 started - Abilities locked")

## Inicia Tutorial 1 (reveal desbloqueado, dash bloqueado)
func start_tutorial_1() -> void:
	tutorial_0_active = false
	reveal_unlocked = true
	dash_unlocked = false  # Se desbloquea al FINAL de Tutorial 1
	current_level = 0  # Sigue siendo tutorial
	player_hp = max_hp  # Full HP (renaciste)
	print("Tutorial 1 started - Reveal unlocked")

## Muerte especial en Tutorial 0 (scripted, inevitable)
func player_died_tutorial_0() -> void:
	print("Tutorial 0: Scripted death - Transitioning to Tutorial 1")

	# NO hacer pause del árbol - detendría los tweens y timers de la cinemática
	# El jugador ya está congelado por scripted_death()

	# NO reproducir SFX de muerte normal (es narrativo)
	# AudioManager.play_sfx("death", 0.0)  # Comentado

	# Llamar a la secuencia de transición
	await _tutorial_0_death_sequence()

	# Cargar Tutorial principal
	start_tutorial_1()
	SceneTransition.change_scene("res://scenes/levels/tutorial.tscn")

## Secuencia cinemática de muerte Tutorial 0 → Tutorial 1
func _tutorial_0_death_sequence() -> void:
	# Fade to black lento (2 segundos)
	if SceneTransition.has_method("fade_to_black"):
		await SceneTransition.fade_to_black(2.0)
	else:
		await get_tree().create_timer(2.0).timeout

	# Texto: "Deceived."
	_show_centered_text("Deceived.")
	await get_tree().create_timer(3.0).timeout
	_hide_centered_text()

	# Esperar 1 segundo en negro
	await get_tree().create_timer(1.0).timeout

	# Texto: "Pero no te engañarán de nuevo."
	_show_centered_text("Pero no te engañarán de nuevo.")
	await get_tree().create_timer(0.5).timeout  # Beat de silencio

	# 🎤 EL GRITO (Awakening Scream)
	AudioManager.play_sfx("awakening_scream", 0.0)

	# Screen flash blanco en sincronía
	if has_node("/root/ScreenFlash"):
		get_node("/root/ScreenFlash").flash(Color.WHITE, 2.0)

	# Camera shake fuerte
	if has_node("/root/CameraShake"):
		get_node("/root/CameraShake").shake(1.5)

	# Esperar que grito termine (~3s)
	await get_tree().create_timer(3.0).timeout

	# Música "Awakening" empieza (fuerte, no fade)
	AudioManager.play_music_immediate("tutorial_1_awakening")

	# Esperar 1.5s más
	await get_tree().create_timer(1.5).timeout

	# Texto final: "Ya no eres víctima. Ahora eres la Cazadora."
	_show_centered_text("Ya no eres víctima.
Ahora eres la Cazadora.")
	await get_tree().create_timer(2.5).timeout
	_hide_centered_text()

	# Esperar un momento antes del fade
	await get_tree().create_timer(0.5).timeout

	# Fade to white (renacimiento)
	if SceneTransition.has_method("fade_to_white"):
		await SceneTransition.fade_to_white(2.0)
	else:
		await get_tree().create_timer(2.0).timeout

## Helper para mostrar texto centrado en pantalla
func _show_centered_text(text: String) -> void:
	# Crear label temporal si no existe
	var label = get_tree().get_first_node_in_group("tutorial_0_text")
	if not label:
		label = Label.new()
		label.name = "Tutorial0Text"
		label.add_to_group("tutorial_0_text")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 48)
		label.modulate = Color.WHITE

		# Agregar a CanvasLayer para que esté encima de todo
		var canvas = CanvasLayer.new()
		canvas.layer = 100
		get_tree().root.add_child(canvas)
		canvas.add_child(label)

		# Configurar para ocupar toda la pantalla y centrar el contenido
		label.anchors_preset = Control.PRESET_FULL_RECT
		label.offset_left = 0
		label.offset_top = 0
		label.offset_right = 0
		label.offset_bottom = 0

	label.text = text
	label.modulate.a = 1.0

## Helper para ocultar texto
func _hide_centered_text() -> void:
	var label = get_tree().get_first_node_in_group("tutorial_0_text")
	if label:
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 1.0)
		await tween.finished
		label.queue_free()
		if label.get_parent():
			label.get_parent().queue_free()

## Maneja la muerte del jugador (normal o Tutorial 0)
func player_died() -> void:
	print("Player died!")

	# Si estamos en Tutorial 0, usar muerte especial
	if tutorial_0_active:
		await player_died_tutorial_0()
		return

	# SFX de muerte (solo si NO es Tutorial 0)
	AudioManager.play_sfx("death", 0.0)

	# Pausar el juego
	get_tree().paused = true

	# Buscar el GameOver en la escena actual
	var game_over = get_tree().get_first_node_in_group("game_over")
	if game_over and game_over.has_method("show_game_over"):
		game_over.show_game_over()
	else:
		# Fallback: solo pausar y recargar después de un tiempo
		await get_tree().create_timer(1.0).timeout
		get_tree().paused = false
		get_tree().reload_current_scene()

## Completa el nivel actual
func complete_level() -> void:
	level_completed.emit(current_level)
	print("Level %d completed! Truths: %d" % [current_level, current_level_truths])

	# Reset para siguiente nivel
	current_level += 1
	current_level_truths = 0

	# Restaurar HP completo para el siguiente nivel
	player_hp = max_hp
	health_changed.emit(player_hp, max_hp)

## Reinicia el juego completo
func reset_game() -> void:
	total_truths_revealed = 0
	total_truths_possible = 0
	current_level = 0  # Volver al tutorial
	current_level_truths = 0
	player_hp = max_hp
	print("Game reset")

## Reinicia el nivel actual (para restart)
func reset_current_level() -> void:
	# Buscar LevelManager en la escena
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager and level_manager.has_method("get_level_start_truths"):
		# Resetear total_truths_revealed al inicio del nivel
		total_truths_revealed = level_manager.get_level_start_truths()

	# Resetear verdades del nivel actual
	current_level_truths = 0

	# Resetear HP
	player_hp = max_hp

	print("Level reset - Total truths: %d" % total_truths_revealed)

## Calcula el porcentaje de verdades reveladas (para endings)
func get_truth_percentage() -> float:
	if total_truths_possible == 0:
		return 0.0
	return (float(total_truths_revealed) / float(total_truths_possible)) * 100.0

## Verifica si el nivel actual es el último
func is_final_level() -> bool:
	return current_level >= max_levels
