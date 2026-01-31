extends Node
## AudioManager: Maneja música y efectos de sonido
##
## Sistema de capas dinámicas para música:
## - Capa base: Siempre activa (ambiental)
## - Capa combate: Se activa cuando hay enemigos cerca
##
## También maneja SFX con pooling básico

# Referencias a AudioStreamPlayers (se crearán dinámicamente o se asignarán)
var ambient_layer: AudioStreamPlayer
var combat_layer: AudioStreamPlayer

# Estado
var combat_active: bool = false
var crossfade_duration: float = 1.0

func _ready() -> void:
	# Crear AudioStreamPlayers para música
	ambient_layer = AudioStreamPlayer.new()
	ambient_layer.name = "AmbientLayer"
	ambient_layer.bus = "Music"
	add_child(ambient_layer)

	combat_layer = AudioStreamPlayer.new()
	combat_layer.name = "CombatLayer"
	combat_layer.bus = "Music"
	combat_layer.volume_db = -80  # Comienza silenciado
	add_child(combat_layer)

	print("AudioManager initialized")

## Reproduce un efecto de sonido
func play_sfx(sfx_name: String, volume_db: float = 0.0) -> void:
	var sfx_path = "res://assets/audio/sfx/%s.wav" % sfx_name

	if not ResourceLoader.exists(sfx_path):
		# Intentar con .ogg
		sfx_path = "res://assets/audio/sfx/%s.ogg" % sfx_name
		if not ResourceLoader.exists(sfx_path):
			push_warning("SFX not found: %s" % sfx_name)
			return

	var player = AudioStreamPlayer.new()
	player.stream = load(sfx_path)
	player.volume_db = volume_db
	player.bus = "SFX"
	add_child(player)
	player.play()

	# Auto-eliminar cuando termine
	player.finished.connect(func(): player.queue_free())

## Activa la capa de combate
func activate_combat() -> void:
	if combat_active:
		return

	combat_active = true

	if combat_layer.stream:
		var tween = create_tween()
		tween.tween_property(combat_layer, "volume_db", 0.0, crossfade_duration)

## Desactiva la capa de combate
func deactivate_combat() -> void:
	if not combat_active:
		return

	combat_active = false

	if combat_layer.stream:
		var tween = create_tween()
		tween.tween_property(combat_layer, "volume_db", -80.0, crossfade_duration)

## Carga y reproduce música (placeholder por ahora)
func play_music(ambient_path: String, combat_path: String = "") -> void:
	# Cargar capa ambiental
	if ResourceLoader.exists(ambient_path):
		ambient_layer.stream = load(ambient_path)
		ambient_layer.play()

	# Cargar capa de combate si existe
	if combat_path != "" and ResourceLoader.exists(combat_path):
		combat_layer.stream = load(combat_path)
		combat_layer.play()

## Detiene toda la música
func stop_music() -> void:
	ambient_layer.stop()
	combat_layer.stop()
