class_name PlayerController
extends CharacterBody2D
## Controlador del jugador para VEIL
##
## Incluye movimiento, salto, coyote time, jump buffer.
## La mecánica de "tear the veil" se maneja en un sistema separado.

# === SEÑALES ===
signal jumped
signal landed
signal veil_torn  # Se emitirá cuando arranque un velo

# === CONSTANTES DE MOVIMIENTO ===
const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const COYOTE_TIME = 0.15
const JUMP_BUFFER = 0.1

# === PARÁMETROS DE MOVIMIENTO ===
@export_group("Movement")
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0
@export var air_resistance: float = 400.0

# === PARÁMETROS DE SALTO ===
@export_group("Jump")
@export var jump_cut_multiplier: float = 0.5  # Al soltar el botón
@export var max_fall_speed: float = 400.0

# === REFERENCIAS ===
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

# === ESTADO ===
var was_on_floor: bool = false
var is_dead: bool = false
var is_tearing_veil: bool = false  # Bloqueado durante animación de tear

func _ready() -> void:
	_setup_timers()
	add_to_group("player")

func _setup_timers() -> void:
	# Crear timers si no existen en la escena
	if not has_node("CoyoteTimer"):
		coyote_timer = Timer.new()
		coyote_timer.name = "CoyoteTimer"
		coyote_timer.one_shot = true
		add_child(coyote_timer)

	if not has_node("JumpBufferTimer"):
		jump_buffer_timer = Timer.new()
		jump_buffer_timer.name = "JumpBufferTimer"
		jump_buffer_timer.one_shot = true
		add_child(jump_buffer_timer)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	_update_animations()

	was_on_floor = is_on_floor()
	move_and_slide()
	_check_landed()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, max_fall_speed)

func _handle_movement(delta: float) -> void:
	# No mover durante tear_veil animation
	if is_tearing_veil:
		# Aplicar fricción
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return

	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		# Acelerar hacia la dirección
		if is_on_floor():
			velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, air_resistance * delta)

		# Voltear sprite
		sprite.flip_h = direction < 0
	else:
		# Aplicar fricción
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_resistance * 0.5 * delta)

func _handle_jump() -> void:
	# No saltar durante tear_veil animation
	if is_tearing_veil:
		return

	# Detectar input de salto
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start(JUMP_BUFFER)

	# Coyote time - iniciar timer al dejar el suelo
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start(COYOTE_TIME)

	# Intentar salto
	var can_jump := is_on_floor() or not coyote_timer.is_stopped()

	if not jump_buffer_timer.is_stopped() and can_jump:
		_perform_jump()
		jump_buffer_timer.stop()
		coyote_timer.stop()

	# Cortar salto al soltar botón (variable jump height)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

func _perform_jump() -> void:
	velocity.y = JUMP_VELOCITY
	jumped.emit()
	# SFX se manejará mediante señal

func _check_landed() -> void:
	if is_on_floor() and not was_on_floor:
		landed.emit()
		# SFX se manejará mediante señal

func _update_animations() -> void:
	if is_tearing_veil:
		# La animación tear_veil ya está reproduciéndose
		return

	if not is_on_floor():
		if velocity.y < 0:
			if animation_player and animation_player.has_animation("jump"):
				animation_player.play("jump")
		else:
			if animation_player and animation_player.has_animation("fall"):
				animation_player.play("fall")
	elif abs(velocity.x) > 10:
		if animation_player and animation_player.has_animation("walk"):
			animation_player.play("walk")
	else:
		if animation_player and animation_player.has_animation("idle"):
			animation_player.play("idle")

# === MÉTODOS PÚBLICOS ===

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")

	# Notificar al GameManager
	GameManager.change_health(-999)  # Forzar muerte

func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	is_dead = false
	is_tearing_veil = false
	if animation_player:
		animation_player.play("idle")

func start_tear_veil_animation() -> void:
	"""Llamado por el sistema de revelación cuando comienza la animación"""
	is_tearing_veil = true
	velocity.x = 0  # Detener movimiento horizontal

	if animation_player and animation_player.has_animation("tear_veil"):
		animation_player.play("tear_veil")
		# Esperar a que termine la animación
		await animation_player.animation_finished
	else:
		# Placeholder: esperar un tiempo fijo
		await get_tree().create_timer(0.4).timeout

	is_tearing_veil = false

func bounce(bounce_velocity: float = -300.0) -> void:
	"""Hace que el jugador rebote (útil para stomp en enemigos)"""
	velocity.y = bounce_velocity
	jumped.emit()
