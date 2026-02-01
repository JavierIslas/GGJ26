class_name PuzzleSwitch
extends Area2D
## Interruptor de puzzle activable por proyectiles o interacción
##
## Puede ser activado por:
## - Veil Shards (proyectiles del jugador)
## - Interacción directa (presionar E)
## - Ambos

signal activated
signal deactivated
signal toggled(is_active: bool)

enum ActivationType { PROJECTILE, INTERACTION, BOTH }

@export_group("Behavior")
@export var activation_type: ActivationType = ActivationType.BOTH
@export var stays_active: bool = true  # Si false, se desactiva tras un tiempo
@export var auto_deactivate_time: float = 2.0  # Tiempo antes de desactivarse
@export var can_toggle: bool = true  # Si true, presionar de nuevo desactiva

@export_group("Visual Feedback")
@export var active_color: Color = Color.GREEN
@export var inactive_color: Color = Color.GRAY
@export var sprite_node_path: NodePath = ""

@export_group("Audio")
@export var activation_sound: String = "switch_on"
@export var deactivation_sound: String = "switch_off"

# Estado
var is_active: bool = false
var deactivate_timer: Timer = null

# Referencias
var sprite: Sprite2D = null

func _ready() -> void:
	# Configurar collision para detectar proyectiles
	collision_layer = 0
	collision_mask = 4  # Layer 4: Projectiles

	# Conectar señales
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Obtener sprite si existe
	if not sprite_node_path.is_empty():
		sprite = get_node(sprite_node_path)
	elif has_node("Sprite2D"):
		sprite = $Sprite2D

	# Crear timer para auto-desactivación
	if not stays_active:
		deactivate_timer = Timer.new()
		deactivate_timer.name = "DeactivateTimer"
		deactivate_timer.one_shot = true
		deactivate_timer.wait_time = auto_deactivate_time
		deactivate_timer.timeout.connect(_on_deactivate_timer_timeout)
		add_child(deactivate_timer)

	_update_visual()

func _on_area_entered(area: Area2D) -> void:
	# Activado por proyectil (Veil Shard)
	if activation_type == ActivationType.PROJECTILE or activation_type == ActivationType.BOTH:
		if area.is_in_group("projectiles") or area.name.contains("Shard"):
			_activate()

func _on_body_entered(body: Node2D) -> void:
	# Activado por interacción del jugador
	if activation_type == ActivationType.INTERACTION or activation_type == ActivationType.BOTH:
		if body.is_in_group("player"):
			# Mostrar prompt de interacción
			_show_interaction_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_show_interaction_prompt(false)

func _process(_delta: float) -> void:
	# Detectar input de interacción
	if activation_type == ActivationType.INTERACTION or activation_type == ActivationType.BOTH:
		var player_in_range = false
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				player_in_range = true
				break

		if player_in_range and Input.is_action_just_pressed("reveal"):
			_activate()

func _activate() -> void:
	if is_active and not can_toggle:
		return

	if is_active and can_toggle:
		_deactivate()
		return

	is_active = true
	_update_visual()

	# SFX
	if activation_sound != "":
		AudioManager.play_sfx(activation_sound, -3.0)

	# Feedback visual (escala)
	if sprite:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		sprite.scale = Vector2(1.3, 1.3)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.2)

	activated.emit()
	toggled.emit(true)
	print("[PuzzleSwitch] %s activated" % name)

	# Auto-desactivar si corresponde
	if not stays_active and deactivate_timer:
		deactivate_timer.start()

func _deactivate() -> void:
	if not is_active:
		return

	is_active = false
	_update_visual()

	# SFX
	if deactivation_sound != "":
		AudioManager.play_sfx(deactivation_sound, -3.0)

	deactivated.emit()
	toggled.emit(false)
	print("[PuzzleSwitch] %s deactivated" % name)

func _on_deactivate_timer_timeout() -> void:
	_deactivate()

func _update_visual() -> void:
	if not sprite:
		return

	sprite.modulate = active_color if is_active else inactive_color

func _show_interaction_prompt(show: bool) -> void:
	# TODO: Mostrar UI prompt "Press E"
	pass

## Fuerza activación (útil para debugging o scripts externos)
func force_activate() -> void:
	if not is_active:
		_activate()

## Fuerza desactivación
func force_deactivate() -> void:
	if is_active:
		_deactivate()

## Retorna si el switch está activo
func is_switch_active() -> bool:
	return is_active
