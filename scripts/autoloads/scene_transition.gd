extends CanvasLayer
## Scene Transition Manager
##
## Maneja transiciones suaves entre escenas con fade in/out

var color_rect: ColorRect
var animation_player: AnimationPlayer

var is_transitioning: bool = false

func _ready() -> void:
	# Configurar layer para estar encima de todo

	# Crear ColorRect
	color_rect = ColorRect.new()
	color_rect.name = "ColorRect"
	color_rect.color = Color.BLACK
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)

	# Crear AnimationPlayer
	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	add_child(animation_player)
	_create_animations()

	# Empezar invisible
	color_rect.modulate.a = 0.0

func _create_animations() -> void:
	"""Crea las animaciones de fade"""
	# Fade Out (pantalla se pone negra)
	var fade_out = Animation.new()
	var track_idx = fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track_idx, "ColorRect:modulate:a")
	fade_out.track_insert_key(track_idx, 0.0, 0.0)
	fade_out.track_insert_key(track_idx, 0.5, 1.0)
	fade_out.length = 0.5
	animation_player.add_animation_library("", AnimationLibrary.new())
	animation_player.get_animation_library("").add_animation("fade_out", fade_out)

	# Fade In (pantalla se aclara)
	var fade_in = Animation.new()
	track_idx = fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track_idx, "ColorRect:modulate:a")
	fade_in.track_insert_key(track_idx, 0.0, 1.0)
	fade_in.track_insert_key(track_idx, 0.5, 0.0)
	fade_in.length = 0.5
	animation_player.get_animation_library("").add_animation("fade_in", fade_in)

func change_scene(scene_path: String) -> void:
	"""Cambia de escena con transición"""
	if is_transitioning:
		return

	is_transitioning = true

	# Fade out
	animation_player.play("fade_out")
	await animation_player.animation_finished

	# Cambiar escena
	get_tree().change_scene_to_file(scene_path)

	# Fade in
	animation_player.play("fade_in")
	await animation_player.animation_finished

	is_transitioning = false

func fade_in() -> void:
	"""Solo hace fade in (útil para inicio de escenas)"""
	animation_player.play("fade_in")
	await animation_player.animation_finished

func fade_out() -> void:
	"""Solo hace fade out"""
	animation_player.play("fade_out")
	await animation_player.animation_finished
