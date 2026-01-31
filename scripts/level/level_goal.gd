extends Area2D
class_name LevelGoal
## Área de meta que completa el nivel cuando el jugador llega
##
## Puede configurarse para requerir un número mínimo de verdades reveladas

@export var required_truths: int = 0  # 0 = no requiere verdades específicas
@export var next_level_path: String = ""  # Path al siguiente nivel (vacío = volver a menú)

@onready var sprite: ColorRect = $ColorRect
@onready var label: Label = $Label

var player_in_area: bool = false

func _ready() -> void:
	# Conectar señales
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameManager.truth_revealed.connect(_on_truth_revealed)

	# Configurar visual
	sprite.color = Color(0.2, 0.8, 0.2, 0.6)  # Verde brillante
	_update_label()

	# Pulsar suavemente
	_start_pulse_animation()

func _update_label() -> void:
	"""Actualiza el texto del label"""
	if required_truths > 0:
		var current = GameManager.current_level_truths
		if current >= required_truths:
			label.text = "GOAL!"
			label.modulate = Color(0.2, 1.0, 0.2, 1.0)
		else:
			label.text = "Need %d truths" % (required_truths - current)
			label.modulate = Color(1.0, 1.0, 0.2, 1.0)
	else:
		label.text = "GOAL!"
		label.modulate = Color(0.2, 1.0, 0.2, 1.0)

func _on_body_entered(body: Node2D) -> void:
	"""Detecta cuando el jugador entra al área"""
	if body.is_in_group("player"):
		player_in_area = true
		_try_complete_level()

func _on_body_exited(body: Node2D) -> void:
	"""Detecta cuando el jugador sale del área"""
	if body.is_in_group("player"):
		player_in_area = false

func _try_complete_level() -> void:
	"""Intenta completar el nivel si se cumplen las condiciones"""
	if not player_in_area:
		return

	# Verificar si tiene las verdades requeridas
	if required_truths > 0:
		if GameManager.current_level_truths < required_truths:
			print("Not enough truths revealed: %d / %d" % [GameManager.current_level_truths, required_truths])
			return

	# ¡Nivel completado!
	_complete_level()

func _complete_level() -> void:
	"""Completa el nivel y muestra pantalla de victoria o ending"""
	print("Level completed!")

	# SFX de victoria
	AudioManager.play_sfx("level_complete", 0.0)

	# IMPORTANTE: Guardar stats ANTES de complete_level() porque resetea current_level_truths
	var level_truths = GameManager.current_level_truths
	var level_truths_possible = GameManager.total_truths_possible - GameManager.total_truths_revealed + level_truths

	# Verificar si es el último nivel ANTES de incrementar current_level
	var is_final = GameManager.is_final_level()

	# Notificar al GameManager
	GameManager.complete_level()

	# Si es el último nivel, mostrar Ending Screen
	if is_final:
		var ending_screen = get_tree().get_first_node_in_group("ending_screen")
		if ending_screen and ending_screen.has_method("show_ending"):
			print("Final level completed! Showing ending...")
			ending_screen.show_ending()
		else:
			# Fallback: volver al menú si no hay ending screen
			print("WARNING: Ending screen not found!")
			await get_tree().create_timer(2.0).timeout
			GameManager.reset_game()
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		# Nivel intermedio: mostrar Victory Screen normal
		var victory_screen = get_tree().get_first_node_in_group("victory_screen")
		if victory_screen and victory_screen.has_method("show_victory"):
			# Obtener path del nivel actual
			var current_scene = get_tree().current_scene
			var current_path = current_scene.scene_file_path if current_scene else ""

			# Mostrar victory screen con stats guardados
			victory_screen.show_victory(
				level_truths,
				level_truths_possible,
				next_level_path,
				current_path
			)
		else:
			# Fallback: cargar siguiente nivel directamente
			await get_tree().create_timer(1.0).timeout
			if next_level_path != "":
				get_tree().change_scene_to_file(next_level_path)
			else:
				GameManager.reset_game()
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _start_pulse_animation() -> void:
	"""Animación de pulso constante"""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate:a", 0.8, 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 0.4, 1.0).set_ease(Tween.EASE_IN_OUT)

func _on_truth_revealed(_total: int) -> void:
	"""Actualiza el label cuando se revela una verdad"""
	_update_label()
