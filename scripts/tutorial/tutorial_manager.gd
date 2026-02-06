extends Node
class_name TutorialManager
## Gestiona el progreso del tutorial y las secciones
##
## Controla la activación progresiva de secciones del tutorial:
## - Sección 1: Movimiento básico
## - Sección 2: Reveal (arrancar velo)
## - Sección 3: Veil Shards (proyectiles)
## - Sección 4: Wolf's Howl (grito de área)
## - Sección 5: Moonlight Dash (dash invencible)
## - Sección 6: Truth Door (puerta final)

# Secciones del tutorial
enum Section {
	MOVEMENT = 1,
	REVEAL = 2,
	SHARDS = 3,
	HOWL = 4,
	DASH = 5,
	DOOR = 6,
	COMPLETE = 7
}

var current_section: Section = Section.MOVEMENT
var section2_revealed: bool = false  # Tracking para sección 2
var section3_completed: bool = false  # Tracking para sección 3
var section4_enemies_killed: int = 0  # Contar enemigos muertos en sección 4
var section4_total_enemies: int = 3  # Total de enemigos en sección 4
var section5_completed: bool = false  # Tracking para sección 5
var section6_door_opened: bool = false  # Tracking para sección 6

# Referencias a las secciones (se asignarán desde la escena)
@export var section1_node: Node2D  # Movimiento
@export var section2_node: Node2D  # Reveal
@export var section3_node: Node2D  # Shards
@export var section4_node: Node2D  # Howl
@export var section5_node: Node2D  # Dash
@export var section6_node: Node2D  # Door

func _ready() -> void:
	print("=== Tutorial Manager initialized ===")

	# Conectar al GameManager para detectar verdades reveladas
	GameManager.truth_revealed.connect(_on_truth_revealed)

	_setup_section_1()
	_setup_section_2()

	# Esperar un frame para que los enemigos estén listos
	await get_tree().process_frame
	_setup_section_3()
	_setup_section_4()
	_setup_section_5()
	_setup_section_6()

## Configura la Sección 1: Movimiento básico
func _setup_section_1() -> void:
	print("Section 1: Movement - Active")
	# La sección 1 está siempre visible desde el inicio
	# El jugador simplemente necesita llegar al final
	# (Por ahora, las secciones siguientes se activarán manualmente)

## Avanza a la siguiente sección
func advance_to_section(section: Section) -> void:
	current_section = section

	match section:
		Section.REVEAL:
			_setup_section_2()
		Section.SHARDS:
			_setup_section_3()
		Section.HOWL:
			_setup_section_4()
		Section.DASH:
			_setup_section_5()
		Section.DOOR:
			_setup_section_6()
		Section.COMPLETE:
			print("Tutorial complete!")

## Sección 2: Reveal
func _setup_section_2() -> void:
	print("Section 2: Reveal - Active")
	# La sección 2 está visible, esperando que el jugador revele al False Enemy
	# El InputHint se muestra automáticamente cuando está en rango

## Callback cuando se revela una verdad
func _on_truth_revealed(_total: int) -> void:
	if current_section == Section.MOVEMENT or current_section == Section.REVEAL:
		if not section2_revealed:
			section2_revealed = true
			print("=== Section 2 Complete: Reveal learned! ===")
			current_section = Section.SHARDS
			print("=== Section 3: Shards - Now try using them! ===")

## Sección 3: Veil Shards
func _setup_section_3() -> void:
	print("Section 3: Veil Shards - Active")

	# Buscar el False Friend de la sección 3
	var section3_enemies = get_tree().get_nodes_in_group("section3_target")

	for enemy in section3_enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_section3_enemy_died)
			print("  - Connected to section3 enemy: %s" % enemy.name)

## Callback cuando muere el enemigo de la sección 3
func _on_section3_enemy_died() -> void:
	if not section3_completed:
		section3_completed = true
		print("=== Section 3 Complete: Shards mastered! ===")
		current_section = Section.HOWL
		print("=== Section 4: Howl - Face the pack! ===")

## Sección 4: Wolf's Howl
func _setup_section_4() -> void:
	print("Section 4: Wolf's Howl - Active")

	# Buscar los False Friends de la sección 4
	var section4_enemies = get_tree().get_nodes_in_group("section4_enemies")

	for enemy in section4_enemies:
		if enemy.has_signal("died"):
			enemy.died.connect(_on_section4_enemy_died)
			print("  - Connected to section4 enemy: %s" % enemy.name)

## Callback cuando muere un enemigo de la sección 4
func _on_section4_enemy_died() -> void:
	section4_enemies_killed += 1
	print("Section 4 progress: %d / %d enemies defeated" % [section4_enemies_killed, section4_total_enemies])

	# Cuando todos los enemigos mueren, sección completa
	if section4_enemies_killed >= section4_total_enemies:
		print("=== Section 4 Complete: Howl mastered! ===")
		current_section = Section.DASH
		print("=== Section 5: Dash - Cross the void! ===")

## Sección 5: Moonlight Dash
func _setup_section_5() -> void:
	print("Section 5: Moonlight Dash - Active")

	# Buscar el trigger del dash
	var dash_triggers = get_tree().get_nodes_in_group("dash_trigger")

	for trigger in dash_triggers:
		if trigger is Area2D:
			trigger.body_entered.connect(_on_dash_trigger_entered)
			print("  - Connected to dash trigger")

## Callback cuando el jugador entra al trigger del dash
func _on_dash_trigger_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not section5_completed:
		section5_completed = true
		print("=== Section 5 Complete: Dash mastered! ===")
		current_section = Section.DOOR
		print("=== Section 6: Door - Final challenge! ===")

## Sección 6: Truth Door
func _setup_section_6() -> void:
	print("Section 6: Truth Door - Active")
	# La Truth Door y los False Enemies están en la escena
	# El jugador debe revelar 2 enemigos para abrir la puerta

	# Buscar la Truth Door para conectar cuando se abra
	var truth_doors = get_tree().get_nodes_in_group("truth_door")
	for door in truth_doors:
		if door.has_signal("door_opened"):
			door.door_opened.connect(_on_truth_door_opened)
			print("  - Connected to truth door")

## Callback cuando se abre la Truth Door
func _on_truth_door_opened() -> void:
	if not section6_door_opened:
		section6_door_opened = true
		print("=== Section 6 Complete: Truth Door opened! ===")
		current_section = Section.COMPLETE
		print("=== Tutorial Complete! ===")

## Verifica si el jugador puede avanzar de sección
func can_advance() -> bool:
	match current_section:
		Section.MOVEMENT:
			# Sección 1 se completa automáticamente al llegar al final
			return true
		Section.REVEAL:
			# Verificar que reveló al False Enemy
			return section2_revealed
		Section.SHARDS:
			# Verificar que eliminó al False Friend con shard
			return section3_completed
		Section.HOWL:
			# Verificar que eliminó todos los enemigos con Howl
			return section4_enemies_killed >= section4_total_enemies
		Section.DASH:
			# Verificar que usó Dash (cruzó el trigger)
			return section5_completed
		Section.DOOR:
			# Verificar que abrió la Truth Door
			return section6_door_opened
		_:
			return false
