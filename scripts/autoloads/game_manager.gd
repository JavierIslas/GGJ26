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
	# Tutorial (nivel 0) = invencible, no recibe daño
	if current_level == 0 and amount < 0:
		print("Tutorial mode: damage ignored")
		return

	player_hp = clamp(player_hp + amount, 0, max_hp)
	health_changed.emit(player_hp, max_hp)

	# SFX de daño
	if amount < 0:
		AudioManager.play_sfx("damage", -3.0)

	if player_hp <= 0:
		player_died()

## Maneja la muerte del jugador
func player_died() -> void:
	print("Player died!")

	# SFX de muerte
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
