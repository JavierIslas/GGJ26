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
	player.process_mode = Node.PROCESS_MODE_ALWAYS  # No afectado por pausa
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

## Carga y reproduce música con soporte para intro + loop
func play_music(ambient_path: String, combat_path: String = "") -> void:
	# Detener música previa
	stop_music()

	# Cargar capa ambiental
	if ResourceLoader.exists(ambient_path):
		ambient_layer.stream = load(ambient_path)
		ambient_layer.play()

	# Cargar capa de combate si existe
	if combat_path != "" and ResourceLoader.exists(combat_path):
		combat_layer.stream = load(combat_path)
		combat_layer.play()

## Carga y reproduce música con intro separada
## intro_path: Se reproduce una vez
## loop_path: Se reproduce en loop después del intro
## combat_path: Capa de combate (opcional)
func play_music_with_intro(intro_path: String, loop_path: String, combat_path: String = "") -> void:
	# Detener música previa
	stop_music()

	# Cargar intro (sin loop)
	if ResourceLoader.exists(intro_path):
		ambient_layer.stream = load(intro_path)
		ambient_layer.play()

		# Conectar señal para cambiar al loop cuando termine
		if not ambient_layer.finished.is_connected(_on_intro_finished):
			ambient_layer.finished.connect(_on_intro_finished.bind(loop_path))

	# Cargar capa de combate si existe
	if combat_path != "" and ResourceLoader.exists(combat_path):
		combat_layer.stream = load(combat_path)
		# No reproducir aún, esperar a que empiece el loop
		# (o reproducir sincronizado con la intro si prefieres)

## Callback cuando termina la intro
func _on_intro_finished(loop_path: String) -> void:
	# Desconectar señal para evitar reconexiones
	if ambient_layer.finished.is_connected(_on_intro_finished):
		ambient_layer.finished.disconnect(_on_intro_finished)

	# Cargar y reproducir loop
	if ResourceLoader.exists(loop_path):
		ambient_layer.stream = load(loop_path)
		ambient_layer.play()

		# IMPORTANTE: Activar loop en el stream si es AudioStreamOggVorbis
		if ambient_layer.stream is AudioStreamOggVorbis:
			ambient_layer.stream.loop = true

## Detiene toda la música
func stop_music() -> void:
	ambient_layer.stop()
	combat_layer.stop()

## Reproduce música inmediatamente (sin fade, para transiciones rápidas)
func play_music_immediate(music_name: String) -> void:
	var music_path = "res://assets/audio/music/%s.ogg" % music_name

	if not ResourceLoader.exists(music_path):
		push_warning("Music not found: %s" % music_name)
		return

	stop_music()
	ambient_layer.stream = load(music_path)
	ambient_layer.volume_db = 0.0
	ambient_layer.play()
