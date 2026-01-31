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
var current_level: int = 1
var current_level_truths: int = 0

# Estado del jugador
var player_hp: int = 3
var max_hp: int = 3

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
	player_hp = clamp(player_hp + amount, 0, max_hp)
	health_changed.emit(player_hp, max_hp)

	if player_hp <= 0:
		player_died()

## Maneja la muerte del jugador
func player_died() -> void:
	print("Player died! Restarting level...")
	# TODO: Implementar restart de nivel
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

## Completa el nivel actual
func complete_level() -> void:
	level_completed.emit(current_level)
	print("Level %d completed! Truths: %d" % [current_level, current_level_truths])

	# Reset para siguiente nivel
	current_level += 1
	current_level_truths = 0

## Reinicia el juego completo
func reset_game() -> void:
	total_truths_revealed = 0
	total_truths_possible = 0
	current_level = 1
	current_level_truths = 0
	player_hp = max_hp
	print("Game reset")

## Calcula el porcentaje de verdades reveladas (para endings)
func get_truth_percentage() -> float:
	if total_truths_possible == 0:
		return 0.0
	return (float(total_truths_revealed) / float(total_truths_possible)) * 100.0
