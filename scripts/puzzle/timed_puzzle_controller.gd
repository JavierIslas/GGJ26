class_name TimedPuzzleController
extends Node
## Controlador de puzzles con múltiples condiciones y timing generoso
##
## Gestiona puzzles complejos que requieren:
## - Múltiples switches activos simultáneamente
## - Enemigos en estados específicos (aturdidos, revelados)
## - Ventanas de tiempo generosas con "coyote time"

signal puzzle_completed
signal puzzle_failed
signal progress_changed(current: int, required: int)
signal time_window_started(duration: float)
signal time_window_ended

@export_group("Requirements")
@export var required_switches: int = 3  # Switches que deben estar activos
@export var required_stunned_enemies: int = 0  # Enemigos que deben estar aturdidos
@export var time_window: float = 3.0  # Ventana de tiempo GENEROSA
@export var coyote_time: float = 0.5  # Buffer extra tras cumplir condiciones

@export_group("Target Elements")
@export var switch_group: String = ""  # Grupo de switches a monitorear
@export var enemy_group: String = ""  # Grupo de enemigos a monitorear

@export_group("Behavior")
@export var auto_start: bool = false  # Inicia al entrar en escena
@export var one_time_only: bool = true
@export var show_timer_ui: bool = true

# Estado
var is_active: bool = false
var is_completed: bool = false
var conditions_met: bool = false
var time_remaining: float = 0.0
var coyote_time_remaining: float = 0.0

# Colecciones
var monitored_switches: Array[PuzzleSwitch] = []
var monitored_enemies: Array[Node2D] = []

# Timers
var window_timer: Timer = null
var coyote_timer: Timer = null

func _ready() -> void:
	# Crear timers
	window_timer = Timer.new()
	window_timer.name = "WindowTimer"
	window_timer.one_shot = true
	window_timer.timeout.connect(_on_window_timeout)
	add_child(window_timer)

	coyote_timer = Timer.new()
	coyote_timer.name = "CoyoteTimer"
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(coyote_timer)

	# Buscar elementos a monitorear
	call_deferred("_collect_elements")

	if auto_start:
		call_deferred("start_puzzle")

func _collect_elements() -> void:
	# Recolectar switches
	if switch_group != "":
		for node in get_tree().get_nodes_in_group(switch_group):
			if node is PuzzleSwitch:
				monitored_switches.append(node)
				# Conectar señal de toggle
				if not node.toggled.is_connected(_on_switch_toggled):
					node.toggled.connect(_on_switch_toggled)

	# Recolectar enemigos
	if enemy_group != "":
		for node in get_tree().get_nodes_in_group(enemy_group):
			if node.has_method("is_stunned") or node.has_node("VeilComponent"):
				monitored_enemies.append(node)

	print("[TimedPuzzleController] Collected %d switches, %d enemies" % [monitored_switches.size(), monitored_enemies.size()])

func start_puzzle() -> void:
	if is_completed and one_time_only:
		print("[TimedPuzzleController] Already completed")
		return

	if is_active:
		print("[TimedPuzzleController] Already active")
		return

	is_active = true
	time_remaining = time_window
	window_timer.start(time_window)

	time_window_started.emit(time_window)
	print("[TimedPuzzleController] Puzzle started - %.1fs window" % time_window)

func _process(delta: float) -> void:
	if not is_active:
		return

	# Actualizar tiempo restante
	if not window_timer.is_stopped():
		time_remaining = window_timer.time_left

	# Verificar condiciones continuamente
	_check_conditions()

func _on_switch_toggled(_is_active: bool) -> void:
	# Un switch cambió de estado, verificar condiciones
	if is_active:
		_check_conditions()

func _check_conditions() -> void:
	if not is_active or is_completed:
		return

	# Contar switches activos
	var active_switches = 0
	for switch in monitored_switches:
		if is_instance_valid(switch) and switch.is_switch_active():
			active_switches += 1

	# Contar enemigos aturdidos
	var stunned_count = 0
	for enemy in monitored_enemies:
		if not is_instance_valid(enemy):
			continue

		if enemy.has_method("is_stunned") and enemy.is_stunned():
			stunned_count += 1

	# Emitir progreso
	var total_required = required_switches + required_stunned_enemies
	var total_current = active_switches + stunned_count
	progress_changed.emit(total_current, total_required)

	# Verificar si se cumplen TODAS las condiciones
	var switches_ok = active_switches >= required_switches
	var enemies_ok = stunned_count >= required_stunned_enemies

	if switches_ok and enemies_ok:
		if not conditions_met:
			# Primera vez que se cumplen las condiciones
			conditions_met = true
			_on_conditions_met()
	else:
		# Ya no se cumplen las condiciones
		if conditions_met:
			conditions_met = false
			_on_conditions_lost()

func _on_conditions_met() -> void:
	"""Condiciones cumplidas - iniciar coyote time"""
	print("[TimedPuzzleController] Conditions MET! Starting coyote time (%.1fs)" % coyote_time)

	# Iniciar coyote timer (buffer generoso)
	coyote_timer.start(coyote_time)

	# SFX positivo
	AudioManager.play_sfx("puzzle_progress", -5.0)

func _on_conditions_lost() -> void:
	"""Condiciones perdidas - cancelar coyote time"""
	print("[TimedPuzzleController] Conditions LOST")

	# Cancelar coyote timer si estaba activo
	if not coyote_timer.is_stopped():
		coyote_timer.stop()

	# SFX negativo
	AudioManager.play_sfx("puzzle_fail", -5.0)

func _on_coyote_timeout() -> void:
	"""Coyote time completado - puzzle resuelto!"""
	# Verificar una última vez que las condiciones siguen cumpliéndose
	if conditions_met:
		_complete_puzzle()

func _complete_puzzle() -> void:
	if is_completed:
		return

	is_completed = true
	is_active = false

	# Detener timers
	window_timer.stop()
	coyote_timer.stop()

	print("[TimedPuzzleController] PUZZLE COMPLETED!")

	# SFX de éxito
	AudioManager.play_sfx("puzzle_complete", 0.0)

	puzzle_completed.emit()

func _on_window_timeout() -> void:
	"""Ventana de tiempo expiró"""
	if is_completed:
		return

	is_active = false

	print("[TimedPuzzleController] Time window EXPIRED - puzzle failed")

	# SFX de fallo
	AudioManager.play_sfx("puzzle_timeout", -3.0)

	time_window_ended.emit()
	puzzle_failed.emit()

	# Opcional: auto-reset después de un delay
	if not one_time_only:
		await get_tree().create_timer(2.0).timeout
		_reset_puzzle()

func _reset_puzzle() -> void:
	"""Resetea el puzzle para intentar de nuevo"""
	is_active = false
	is_completed = false
	conditions_met = false
	time_remaining = 0.0

	# Resetear switches
	for switch in monitored_switches:
		if is_instance_valid(switch):
			switch.force_deactivate()

	print("[TimedPuzzleController] Puzzle reset")

## Inicia el puzzle manualmente
func trigger_start() -> void:
	start_puzzle()

## Fuerza completar el puzzle (debugging)
func force_complete() -> void:
	_complete_puzzle()
