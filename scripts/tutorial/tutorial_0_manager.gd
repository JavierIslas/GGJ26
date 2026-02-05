extends Node2D
class_name Tutorial0Manager

## Tutorial 0 Manager
##
## Controla el flujo del Tutorial 0:
## - Inicia el tutorial (sin HUD, sin habilidades)
## - Oculta HUD inicialmente
## - Maneja transiciones
## - Música ambiental

@onready var player: CharacterBody2D = get_node_or_null("Player")
@onready var hud: Control = get_node_or_null("UI/HUD")
@onready var camera: Camera2D = get_node_or_null("Camera2D")

var tutorial_started: bool = false

func _ready() -> void:
	print("=== Tutorial 0: Innocence ===")

	# Iniciar Tutorial 0 en GameManager
	GameManager.start_tutorial_0()

	# Ocultar HUD (se mostrará cuando el False Friend ataque)
	if hud:
		hud.visible = false

	# Configurar cámara para seguir al jugador
	if camera and player:
		_setup_camera()

	# Música ambiental (silencio o muy tenue)
	_start_ambient_music()

	# Marcar como iniciado
	tutorial_started = true

	print("Tutorial 0 started - Player has no abilities")

func _setup_camera() -> void:
	"""Configura la cámara para seguir al jugador"""
	# USAR la cámara del jugador, NO la del nivel
	if player and player.has_node("Camera2D"):
		# Asegurar que la cámara del jugador está activa
		player.get_node("Camera2D").enabled = true
		# Desactivar cámara del nivel si existe
		if camera:
			camera.enabled = false
	else:
		# Fallback: usar cámara del nivel
		if camera:
			camera.enabled = true
			set_process(true)

func _process(delta: float) -> void:
	if camera and player and is_instance_valid(player):
		# Seguir al jugador con la cámara del nivel
		camera.global_position = player.global_position

func _start_ambient_music() -> void:
	"""Inicia música ambiental muy tenue (o silencio)"""
	# Opción 1: Silencio total
	AudioManager.stop_music()

	# Opción 2: Ambient muy tenue (descomentar si existe el archivo)
	# AudioManager.play_music("tutorial_0_silence", "", 0.2)  # 20% volume

	print("Tutorial 0: Ambient music started (silence)")

## Llamado cuando el False Friend hace su primer ataque
func on_first_attack() -> void:
	"""Muestra el HUD por primera vez"""
	if hud:
		hud.visible = true
		_update_hud()

	print("Tutorial 0: HUD revealed")

## Actualiza el HUD con valores actuales
func _update_hud() -> void:
	if not hud:
		return

	var hp_label = hud.get_node_or_null("HPLabel")
	if hp_label:
		hp_label.text = "HP: %d/%d" % [GameManager.player_hp, GameManager.max_hp]

	var truths_label = hud.get_node_or_null("TruthsLabel")
	if truths_label:
		truths_label.text = "Velos: %d / 1" % GameManager.current_level_truths

## Conectar señales del GameManager
func _connect_signals() -> void:
	if not GameManager.health_changed.is_connected(_on_health_changed):
		GameManager.health_changed.connect(_on_health_changed)

	if not GameManager.truth_revealed.is_connected(_on_truth_revealed):
		GameManager.truth_revealed.connect(_on_truth_revealed)

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	_update_hud()

func _on_truth_revealed(total: int) -> void:
	_update_hud()
