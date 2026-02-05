class_name PlayerController
extends CharacterBody2D
## LA REVELADORA - "The Wolf"
##
## NARRATIVA: Ex-víctima transformada en cazadora. Posee el poder de "Arrancar Velos"
##           para revelar la verdadera naturaleza de las personas enmascaradas.
##           "I'm not your victim anymore. I'm the big bad wolf now."
##
## Incluye movimiento fluido, salto, coyote time, jump buffer.
## La mecánica de "tear the veil" se maneja en RevealSystem (sistema separado).

# === SEÑALES ===
signal jumped
signal landed
signal veil_torn  # Se emitirá cuando arranque un velo

# === CONSTANTES DE MOVIMIENTO ===
const SPEED = 230.0           # Más dinámico para combate (era 200.0)
const JUMP_VELOCITY = -500.0  # Más preciso, menos flotante (era -550.0)
const GRAVITY = 1300.0        # Complementa jump reducido (era 1200.0)
const COYOTE_TIME = 0.12      # Más tight, menos obvio (era 0.15)
const JUMP_BUFFER = 0.1       # Responsivo

# === PARÁMETROS DE MOVIMIENTO ===
@export_group("Movement")
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0
@export var air_resistance: float = 700.0  # Más control en el aire (era 400.0)

# === PARÁMETROS DE SALTO ===
@export_group("Jump")
@export var jump_cut_multiplier: float = 0.5  # Al soltar el botón
@export var max_fall_speed: float = 500.0  # Caída más responsiva (era 400.0)

# === PARÁMETROS DE DAÑO ===
@export_group("Damage")
@export var invincibility_duration: float = 1.0  # Segundos de iFrames después de recibir daño
@export var flash_frequency: float = 0.1  # Frecuencia del parpadeo durante iFrames

# === PARÁMETROS DE VEIL SHARDS ===
@export_group("Veil Shards")
@export var max_shards: int = 3  # Máximo de shards que puede almacenar
@export var shard_orbit_radius: float = 32.0  # Radio de órbita de shards
@export var shard_orbit_speed: float = 2.0  # Velocidad de rotación de órbita

# === PARÁMETROS DE MOONLIGHT DASH ===
@export_group("Moonlight Dash")
@export var dash_distance: float = 135.0  # Distancia del dash en píxeles (era 80.0)
@export var dash_duration: float = 0.25  # Duración del dash en segundos (era 0.2)
@export var dash_cooldown: float = 2.0  # Cooldown entre dashes (era 3.0)

# === REFERENCIAS ===
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var invincibility_timer: Timer = null
@onready var flash_timer: Timer = null

# === ESTADO ===
var was_on_floor: bool = false
var is_dead: bool = false
var is_tearing_veil: bool = false  # Bloqueado durante animación de tear
var is_invincible: bool = false  # Invencibilidad temporal después de daño

# === VEIL SHARDS STATE ===
var veil_shards: int = 0
var shard_visuals: Array[Sprite2D] = []  # Sprites de shards orbitando
var shard_orbit_angle: float = 0.0  # Ángulo actual de órbita
var shard_scene = preload("res://scenes/components/veil_shard.tscn")

# === MOONLIGHT DASH STATE ===
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var is_dash_on_cooldown: bool = false
var dash_cooldown_timer: Timer = null
var enemies_hit_during_dash: Array[Node2D] = []  # Para evitar contar el mismo enemigo dos veces

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

	# Timer de invencibilidad
	if not has_node("InvincibilityTimer"):
		invincibility_timer = Timer.new()
		invincibility_timer.name = "InvincibilityTimer"
		invincibility_timer.one_shot = true
		invincibility_timer.wait_time = invincibility_duration
		invincibility_timer.timeout.connect(_on_invincibility_timeout)
		add_child(invincibility_timer)
	else:
		invincibility_timer = $InvincibilityTimer
		invincibility_timer.timeout.connect(_on_invincibility_timeout)

	# Timer para el parpadeo visual
	if not has_node("FlashTimer"):
		flash_timer = Timer.new()
		flash_timer.name = "FlashTimer"
		flash_timer.one_shot = false
		flash_timer.wait_time = flash_frequency
		flash_timer.timeout.connect(_on_flash_timeout)
		add_child(flash_timer)
	else:
		flash_timer = $FlashTimer
		flash_timer.timeout.connect(_on_flash_timeout)

	# Timer de cooldown del dash
	if not has_node("DashCooldownTimer"):
		dash_cooldown_timer = Timer.new()
		dash_cooldown_timer.name = "DashCooldownTimer"
		dash_cooldown_timer.one_shot = true
		dash_cooldown_timer.wait_time = dash_cooldown
		dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
		add_child(dash_cooldown_timer)
	else:
		dash_cooldown_timer = $DashCooldownTimer
		dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Tutorial 0: Freeze timer
	if is_frozen:
		freeze_timer -= delta
		if freeze_timer <= 0:
			is_frozen = false
			freeze_timer = 0.0
			print("Player unfrozen")
		else:
			# Mientras está frozen, no hacer nada
			velocity = Vector2.ZERO
			move_and_slide()
			return

	# Dash tiene prioridad sobre movimiento normal
	if is_dashing:
		_process_dash(delta)
	else:
		_apply_gravity(delta)
		_handle_jump()
		_handle_movement(delta)
		_handle_dash_input()

	_handle_shard_launch()
	_update_shard_orbit(delta)
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
	AudioManager.play_sfx("jump", -5.0)

	# Squash & stretch en salto
	_jump_squash()

func _check_landed() -> void:
	if is_on_floor() and not was_on_floor:
		landed.emit()
		# Squash & stretch al aterrizar
		_land_squash()
		# === POLISH: Dust particles al aterrizar ===
		_spawn_landing_dust()

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

func _jump_squash() -> void:
	"""Efecto de squash & stretch al saltar (muy sutil)"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)  # Más suave que BACK

	# Squash horizontal, stretch vertical (muy reducido)
	sprite.scale = Vector2(0.95, 1.05)  # Solo 5% de deformación
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.15)

func _land_squash() -> void:
	"""Efecto de squash & stretch al aterrizar (muy sutil)"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)  # Más suave que BACK

	# Stretch horizontal, squash vertical (muy reducido)
	sprite.scale = Vector2(1.05, 0.95)  # Solo 5% de deformación
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.2)

## === SISTEMA DE IFRAMES ===

func take_damage(amount: int) -> void:
	"""Recibe daño y activa iFrames"""
	# Si ya está invencible, ignorar daño
	if is_invincible:
		print("Player is invincible, damage ignored")
		return

	# === POLISH: Freeze frame ===
	_apply_freeze_frame(0.05)

	# === POLISH: Gamepad vibration ===
	_apply_gamepad_vibration(0.4, 0.4, 0.25)

	# === POLISH: Camera shake (muy sutil) ===
	_apply_camera_shake(0.15)

	# === POLISH: Hit flash ===
	_apply_hit_flash()

	# === POLISH: Knockback ===
	_apply_knockback(amount)

	# Aplicar daño
	GameManager.change_health(-amount)

	# Si el jugador murió, no activar iFrames
	if GameManager.player_hp <= 0:
		return

	# Activar invencibilidad temporal
	_activate_invincibility()

func _activate_invincibility() -> void:
	"""Activa los iFrames y el feedback visual"""
	is_invincible = true

	# Iniciar timer de invencibilidad
	if invincibility_timer:
		invincibility_timer.start()

	# Iniciar parpadeo visual
	if flash_timer:
		flash_timer.start()

	print("Player invincible for %.1f seconds" % invincibility_duration)

func _on_invincibility_timeout() -> void:
	"""Callback cuando termina la invencibilidad"""
	is_invincible = false

	# Detener parpadeo
	if flash_timer:
		flash_timer.stop()

	# Asegurar que el sprite sea visible
	sprite.modulate.a = 1.0

	print("Player invincibility ended")

func _on_flash_timeout() -> void:
	"""Callback para el parpadeo visual durante iFrames"""
	# Alternar entre visible e invisible
	sprite.modulate.a = 0.3 if sprite.modulate.a == 1.0 else 1.0

func is_player_invincible() -> bool:
	"""Retorna true si el jugador está en iFrames"""
	return is_invincible

# === VEIL SHARDS SYSTEM ===

func add_veil_shard() -> void:
	"""Agrega un shard al inventario del jugador"""
	if veil_shards >= max_shards:
		print("Max shards reached (%d)" % max_shards)
		return

	veil_shards += 1
	_update_shard_visuals()

	# SFX
	AudioManager.play_sfx("shard_collect", -8.0)

	# Feedback visual sutil
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	sprite.scale = Vector2(1.1, 1.1)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.2)

	print("Veil Shard collected! Total: %d/%d" % [veil_shards, max_shards])

func _handle_shard_launch() -> void:
	"""Detecta input para lanzar shards"""
	# No lanzar durante tear veil animation
	if is_tearing_veil or is_dead:
		return

	# Input: Click derecho del mouse o botón R (gamepad)
	if Input.is_action_just_pressed("launch_shard"):
		_launch_shard()

func _launch_shard() -> void:
	"""Lanza un shard hacia el cursor/dirección"""
	if veil_shards <= 0:
		print("No shards to launch")
		return

	# Reducir contador
	veil_shards -= 1
	_update_shard_visuals()

	# Crear proyectil
	var shard = shard_scene.instantiate()

	# Posicionar en el jugador
	shard.global_position = global_position

	# Determinar dirección
	var launch_direction: Vector2

	# Detectar si se usó gamepad para lanzar
	var used_gamepad = Input.is_action_just_pressed("launch_shard") and Input.get_connected_joypads().size() > 0

	# Si usó gamepad o teclado: lanzar horizontal
	if used_gamepad or Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		# Gamepad o teclado: lanzar en la dirección que mira el sprite
		launch_direction = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
	else:
		# Mouse: apuntar hacia el cursor
		var mouse_pos = get_global_mouse_position()
		launch_direction = (mouse_pos - global_position).normalized()

	# Lanzar
	shard.launch(launch_direction)

	# Añadir al ProjectileManager
	ProjectileManager.add_projectile(shard)

	# SFX
	AudioManager.play_sfx("shard_launch", -6.0)

	# Feedback visual de lanzamiento
	_shard_launch_feedback()

	print("Shard launched in direction: %v | Remaining: %d" % [launch_direction, veil_shards])

func _update_shard_visuals() -> void:
	"""Actualiza los sprites de shards orbitando"""
	# Limpiar visuales existentes
	for visual in shard_visuals:
		if is_instance_valid(visual):
			visual.queue_free()
	shard_visuals.clear()

	# Crear nuevos visuales
	for i in veil_shards:
		var shard_sprite = Sprite2D.new()

		# Configurar sprite (usar el mismo que el proyectil o un placeholder)
		# Por ahora usaremos un ColorRect simple
		var rect = ColorRect.new()
		rect.size = Vector2(6, 6)
		rect.position = Vector2(-3, -3)  # Centrar
		rect.color = Color(1.0, 1.0, 1.0, 0.8)

		shard_sprite.add_child(rect)
		add_child(shard_sprite)
		shard_visuals.append(shard_sprite)

		# Efecto de aparición
		shard_sprite.modulate.a = 0.0
		shard_sprite.scale = Vector2.ZERO
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard_sprite, "modulate:a", 1.0, 0.3)
		tween.tween_property(shard_sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

func _update_shard_orbit(delta: float) -> void:
	"""Actualiza la posición orbital de los shards visuales"""
	if shard_visuals.is_empty():
		return

	# Incrementar ángulo
	shard_orbit_angle += shard_orbit_speed * delta

	# Posicionar cada shard en órbita
	var angle_step = TAU / shard_visuals.size()

	for i in shard_visuals.size():
		if not is_instance_valid(shard_visuals[i]):
			continue

		var angle = shard_orbit_angle + (angle_step * i)
		var offset = Vector2(
			cos(angle) * shard_orbit_radius,
			sin(angle) * shard_orbit_radius
		)

		shard_visuals[i].position = offset

		# Rotar el shard para que apunte hacia afuera
		shard_visuals[i].rotation = angle + PI/2

func _shard_launch_feedback() -> void:
	"""Feedback visual al lanzar un shard"""
	# Pequeño recoil
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	var recoil = Vector2(0.95, 1.05)
	sprite.scale = recoil
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

	# Partículas de lanzamiento
	_spawn_shard_launch_particles()

func _spawn_shard_launch_particles() -> void:
	"""Partículas al lanzar un shard"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.3
	particles.explosiveness = 1.0

	# Emisión en punto
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT

	# Dirección hacia atrás (recoil)
	particles.direction = Vector2(0, 0)
	particles.spread = 30.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0

	# Gravedad ligera
	particles.gravity = Vector2(0, 50)

	# Escala pequeña
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Color blanco brillante
	particles.color = Color(1.2, 1.2, 1.2, 0.8)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.2, 1.2, 1.2, 0.8))
	gradient.add_point(1.0, Color(1.0, 1.0, 1.0, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = particles.lifetime + 0.1
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
		cleanup_timer.queue_free()
	)
	get_tree().root.add_child(cleanup_timer)

# === MOONLIGHT DASH SYSTEM ===

func _handle_dash_input() -> void:
	"""Detecta input para iniciar dash"""
	# No dash durante tear veil o si está en cooldown
	if is_tearing_veil or is_dash_on_cooldown or is_dead:
		return

	# Input: Shift / Botón B (gamepad) / Doble tap (opcional)
	if Input.is_action_just_pressed("dash"):
		_start_dash()

func _start_dash() -> void:
	"""Inicia el dash"""
	# Determinar dirección del dash
	var input_direction = Input.get_axis("move_left", "move_right")

	# Si no hay input, dash en la dirección que mira el sprite
	if input_direction == 0:
		dash_direction = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
	else:
		dash_direction = Vector2.RIGHT if input_direction > 0 else Vector2.LEFT

	# Activar estado de dash
	is_dashing = true
	dash_timer = dash_duration
	enemies_hit_during_dash.clear()

	# Activar cooldown
	is_dash_on_cooldown = true
	dash_cooldown_timer.start()

	# Feedback visual de inicio
	_dash_start_feedback()

	# SFX
	AudioManager.play_sfx("dash", -6.0)

	print("Moonlight Dash started! Direction: %v" % dash_direction)

func _process_dash(delta: float) -> void:
	"""Procesa el movimiento durante el dash"""
	dash_timer -= delta

	if dash_timer <= 0:
		_end_dash()
		return

	# Calcular velocidad del dash
	var dash_speed = dash_distance / dash_duration
	velocity.x = dash_direction.x * dash_speed
	velocity.y = 0  # Dash horizontal puro (no afectado por gravedad)

	# Detectar enemigos atravesados
	_check_dash_collisions()

	# Feedback visual continuo (after-images)
	_spawn_dash_afterimage()

func _end_dash() -> void:
	"""Termina el dash"""
	is_dashing = false
	dash_timer = 0.0

	# Restaurar velocidad (momentum aumentado para más fluidez)
	velocity.x *= 0.75  # Era 0.5, ahora 75% de momentum

	print("Moonlight Dash ended! Shards: %d" % veil_shards)

func _check_dash_collisions() -> void:
	"""Detecta colisiones con enemigos durante el dash"""
	# Buscar enemigos cercanos
	for body in get_tree().get_nodes_in_group("entities"):
		if not is_instance_valid(body):
			continue

		# Evitar contar el mismo enemigo dos veces
		if body in enemies_hit_during_dash:
			continue

		# Verificar distancia
		var distance = global_position.distance_to(body.global_position)
		if distance > 32.0:  # Radio de detección durante dash
			continue

		# Verificar si está revelado
		if not body.has_node("VeilComponent"):
			continue

		var veil = body.get_node("VeilComponent")
		if not veil.is_revealed:
			continue

		# Atravesado! Generar shard extra
		_on_enemy_dashed_through(body)

func _on_enemy_dashed_through(enemy: Node2D) -> void:
	"""Callback cuando atraviesas un enemigo durante dash"""
	# Marcar como golpeado
	enemies_hit_during_dash.append(enemy)

	# Generar shard extra
	add_veil_shard()

	# Efecto visual de atravesar
	_spawn_dash_pierce_particles(enemy.global_position)

	# Aplicar micro-stun al enemigo (0.3s)
	if enemy.has_method("stun"):
		enemy.stun(0.3)

	# Determinar tipo para feedback específico
	var is_false_enemy = enemy.is_class("FalseEnemy") or "FalseEnemy" in enemy.name

	if is_false_enemy:
		# False Enemies entran en pánico
		print("Dashed through False Enemy (victim) - they panic!")
	else:
		print("Dashed through %s - shard generated!" % enemy.name)

func _on_dash_cooldown_timeout() -> void:
	"""Callback cuando termina el cooldown del dash"""
	is_dash_on_cooldown = false
	print("Moonlight Dash ready!")

func _dash_start_feedback() -> void:
	"""Feedback visual al iniciar dash"""
	# Pequeño squash horizontal
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	sprite.scale = Vector2(1.2, 0.9)  # Comprimido verticalmente
	tween.tween_property(sprite, "scale", Vector2.ONE, dash_duration)

	# Partículas de inicio
	_spawn_dash_start_particles()

func _spawn_dash_afterimage() -> void:
	"""Crea after-image durante el dash"""
	# Crear sprite duplicado
	var afterimage = Sprite2D.new()
	afterimage.texture = sprite.texture
	afterimage.flip_h = sprite.flip_h
	afterimage.global_position = global_position
	afterimage.modulate = Color(0.7, 0.9, 1.0, 0.6)  # Azul/blanco fantasmal
	afterimage.z_index = -1  # Detrás del jugador

	# Añadir al árbol
	get_tree().root.add_child(afterimage)

	# Fade out rápido
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(afterimage, "modulate:a", 0.0, 0.3)
	tween.tween_property(afterimage, "scale", Vector2(0.8, 0.8), 0.3)
	tween.finished.connect(func(): afterimage.queue_free())

func _spawn_dash_start_particles() -> void:
	"""Partículas al iniciar el dash"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 15
	particles.lifetime = 0.4
	particles.explosiveness = 1.0

	# Emisión radial
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 16.0

	# Dirección opuesta al dash
	particles.direction = Vector2(-dash_direction.x, 0)
	particles.spread = 45.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 100.0

	# Gravedad ligera
	particles.gravity = Vector2(0, 150)

	# Escala
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0

	# Color plateado/blanco
	particles.color = Color(0.8, 0.9, 1.0, 0.9)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 1.2, 1.0))
	gradient.add_point(1.0, Color(0.7, 0.8, 1.0, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = particles.lifetime + 0.1
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
		cleanup_timer.queue_free()
	)
	get_tree().root.add_child(cleanup_timer)

func _spawn_dash_pierce_particles(position: Vector2) -> void:
	"""Partículas al atravesar un enemigo"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.5
	particles.explosiveness = 1.0

	# Emisión radial
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 8.0

	# Explosión radial
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0

	# Gravedad
	particles.gravity = Vector2(0, 200)

	# Escala
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0

	# Rotación
	particles.angular_velocity_min = -540.0
	particles.angular_velocity_max = 540.0

	# Color blanco brillante (atravesar)
	particles.color = Color(1.5, 1.5, 1.5, 1.0)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.5, 1.5, 1.5, 1.0))
	gradient.add_point(0.6, Color(1.2, 1.2, 1.2, 0.7))
	gradient.add_point(1.0, Color(1.0, 1.0, 1.0, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = particles.lifetime + 0.1
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
		cleanup_timer.queue_free()
	)
	get_tree().root.add_child(cleanup_timer)

# === POLISH & JUICE METHODS ===

func _apply_freeze_frame(duration: float) -> void:
	"""Congela el tiempo brevemente para impacto dramático"""
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func _apply_gamepad_vibration(weak_magnitude: float, strong_magnitude: float, duration: float) -> void:
	"""Vibración de gamepad para feedback táctil"""
	# Detectar todos los joysticks conectados
	var joy_list = Input.get_connected_joypads()
	for joy_id in joy_list:
		Input.start_joy_vibration(joy_id, weak_magnitude, strong_magnitude, duration)

func _apply_camera_shake(trauma_amount: float) -> void:
	"""Aplica screen shake a través de la cámara"""
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(trauma_amount)

func _apply_hit_flash() -> void:
	"""Flash rojo al recibir daño"""
	var tween = create_tween()
	sprite.modulate = Color(2.0, 0.5, 0.5)  # Rojo intenso
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func _apply_knockback(damage_amount: int) -> void:
	"""Knockback basado en el daño recibido"""
	# Determinar dirección del knockback (opuesto a la velocidad actual o aleatorio)
	var knockback_direction = -sign(velocity.x) if velocity.x != 0 else (1 if randf() > 0.5 else -1)
	var knockback_force = 150.0 + (damage_amount * 50.0)

	velocity.x = knockback_direction * knockback_force
	velocity.y = -200.0  # Empuje hacia arriba

func _spawn_landing_dust() -> void:
	"""Crea partículas de polvo al aterrizar"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = global_position + Vector2(0, 16)  # A los pies del jugador
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 0.5
	particles.explosiveness = 1.0

	# Emisión horizontal (a los lados)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 8.0

	# Dirección horizontal con un poco de altura
	particles.direction = Vector2(0, -0.5)  # Ligeramente hacia arriba
	particles.spread = 60.0  # Solo a los lados
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 80.0

	# Gravedad ligera
	particles.gravity = Vector2(0, 150)

	# Escala pequeña (partículas de polvo)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Rotación
	particles.angular_velocity_min = -90.0
	particles.angular_velocity_max = 90.0

	# Color gris/blanco (polvo)
	particles.color = Color(0.8, 0.8, 0.8, 0.8)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.9, 0.9, 0.9, 0.8))
	gradient.add_point(1.0, Color(0.8, 0.8, 0.8, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol root (NO como hijo del jugador para mantener posición global)
	get_tree().root.add_child(particles)

	# Auto-destruir usando Timer (evita memory leak del await)
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = particles.lifetime + 0.1
	cleanup_timer.one_shot = true
	cleanup_timer.autostart = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
		cleanup_timer.queue_free()
	)
	get_tree().root.add_child(cleanup_timer)

## === TUTORIAL 0 METHODS ===

var is_frozen: bool = false
var freeze_timer: float = 0.0

func freeze(duration: float) -> void:
	"""Congela el jugador por X segundos (Tutorial 0)"""
	is_frozen = true
	freeze_timer = duration
	velocity = Vector2.ZERO
	print("Player frozen for %s seconds" % duration)

func scripted_death() -> void:
	"""Muerte scripted para Tutorial 0 (sin game over normal)"""
	print("Player: Scripted death triggered")
	is_dead = true
	is_frozen = true
	velocity = Vector2.ZERO

	# Animación de muerte si existe
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")

	# Llamar a GameManager para manejar transición
	GameManager.player_died_tutorial_0()
