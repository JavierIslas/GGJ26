extends CharacterBody2D
class_name Tutorial0FalseFriend

## FALSE FRIEND - Tutorial 0 Version
##
## Comportamiento especial para Tutorial 0:
## 1. Se revela AUTOMÁTICAMENTE cuando jugador ENTRA en el área
## 2. Persigue al jugador inevitablemente (más rápido)
## 3. Mata al jugador (muerte scripted → Tutorial 1)

# Constantes de movimiento
const CHASE_SPEED: float = 180.0  # Más rápido que jugador (150)
const JUMP_FORCE: float = -450.0  # Salta más alto que jugador
const GRAVITY: float = 980.0
const CATCH_RANGE: float = 32.0  # Distancia para "atrapar" al jugador

# Auto-reveal settings
@export var auto_reveal_range: float = 48.0
@export var auto_reveal_enabled: bool = true

# Estado
enum State { IDLE, CHASING }
var current_state: State = State.IDLE
var has_auto_revealed: bool = false

# Referencias
var player: CharacterBody2D
var sprite: Node  # Puede ser Sprite2D o ColorRect
var anim_player: AnimationPlayer
var trigger_area: Area2D

# Direccion de movimiento
var facing_right: bool = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	# Buscar sprite - puede ser Sprite2D o ColorRect
	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = get_node_or_null("Sprite")
	if not sprite:
		sprite = get_node_or_null("ColorRect")
	anim_player = $AnimationPlayer if has_node("AnimationPlayer") else null

	# Crear área de trigger si no existe
	if auto_reveal_enabled and not has_node("TriggerArea"):
		_setup_trigger_area()

	# Asegurar que tiene collision
	if not has_node("CollisionShape2D"):
		push_warning("Tutorial0FalseFriend: Missing CollisionShape2D")

	print("Tutorial0FalseFriend ready. Player found: ", player != null)

func _setup_trigger_area() -> void:
	# Crear Area2D para detectar cuando el jugador pasa DETRÁS
	trigger_area = Area2D.new()
	trigger_area.name = "TriggerArea"
	add_child(trigger_area)

	# Configurar collision layers para detectar al jugador
	trigger_area.collision_layer = 0
	trigger_area.collision_mask = 2  # Player está en layer 2

	# Crear CollisionShape2D largo detrás del personaje (trigger volume)
	var area_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()

	# El trigger es un rectángulo alto y angosto detrás del personaje
	# Ancho: 20px, Alto: 200px (para que no puedan saltarlo)
	rect.size = Vector2(20, 200)
	area_shape.shape = rect

	# Posicionar el trigger DETRÁS del personaje (más lejos)
	# Si el personaje mira a la derecha (default), el trigger está a la derecha
	area_shape.position = Vector2(200, 0)  # 200px adelante del centro

	trigger_area.add_child(area_shape)

	# Conectar señales
	trigger_area.body_entered.connect(_on_body_entered)

	print("Tutorial0FalseFriend: Trigger volume created (20x200) behind player")

func _on_body_entered(body: Node2D) -> void:
	print("Tutorial0FalseFriend: body_entered called! body=", body.name, " has_auto_revealed=", has_auto_revealed, " enabled=", auto_reveal_enabled)

	if has_auto_revealed or not auto_reveal_enabled:
		print("Tutorial0FalseFriend: Skipping reveal (already revealed or disabled)")
		return

	# Verificar que sea el jugador
	if body.is_in_group("player"):
		print("Tutorial0FalseFriend: Player entered trigger area!")
		_trigger_auto_reveal()
	else:
		print("Tutorial0FalseFriend: Body is not player, group=", body.get_groups())

func _process(delta: float) -> void:
	# Debug: verificar distancia al jugador
	if player and not has_auto_revealed and auto_reveal_enabled:
		var dist = global_position.distance_to(player.global_position)
		if dist < auto_reveal_range:
			print("Tutorial0FalseFriend: Player is close! dist=", dist, " range=", auto_reveal_range)

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Comportamiento según estado
	match current_state:
		State.IDLE:
			_idle_behavior()
		State.CHASING:
			_chase_behavior()

	move_and_slide()

	# Voltear sprite según dirección (solo para Sprite2D)
	if sprite and velocity.x != 0:
		if sprite.has_method("set_flip_h"):
			# Es Sprite2D
			sprite.set_flip_h(velocity.x < 0)
		# ColorRect no necesita flip

func _check_auto_reveal() -> void:
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= auto_reveal_range:
		_trigger_auto_reveal()

func _trigger_auto_reveal() -> void:
	has_auto_revealed = true
	auto_reveal_enabled = false

	print("Tutorial 0: Auto-reveal triggered!")

	# Iniciar secuencia cinemática
	await _cinematic_reveal_sequence()

	# Empezar persecución
	_start_chase()

func _cinematic_reveal_sequence() -> void:
	# t=0.0s: Freeze player
	if player and player.has_method("freeze"):
		player.freeze(2.5)

	# Detener música
	AudioManager.stop_music()

	# t=0.5s: Máscara crujiendo
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_sfx("mask_cracking", -5.0)
	_shake_sprite(0.5, 2.0)  # 0.5s duration, 2px intensity

	# t=1.0s: Máscara rompe
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_sfx("glass_shatter", -3.0)
	_spawn_mask_break_particles()

	# t=1.5s: Transformación completa
	await get_tree().create_timer(0.5).timeout
	_transform_to_revealed()
	AudioManager.play_sfx("false_friend_reveal", 0.0)

	# Screen shake
	if has_node("/root/CameraShake"):
		get_node("/root/CameraShake").shake(0.8)

	# Screen flash rojo
	if has_node("/root/ScreenFlash"):
		get_node("/root/ScreenFlash").flash(Color.RED, 0.3)

	# t=2.0s: Ataque (primer daño)
	await get_tree().create_timer(0.5).timeout
	_lunge_attack()

	# Hacer daño al jugador
	if player and player.has_method("take_damage"):
		player.take_damage(1)
	else:
		GameManager.change_health(-1)

	# Notificar al Tutorial0Manager para mostrar HUD
	var tutorial_manager = get_tree().get_first_node_in_group("tutorial_0_manager")
	if tutorial_manager and tutorial_manager.has_method("on_first_attack"):
		tutorial_manager.on_first_attack()
	else:
		# Fallback: mostrar HUD directamente
		var hud = get_node_or_null("/root/Tutorial0/UI/HUD")
		if hud:
			hud.visible = true

	# t=2.5s: Jugador recupera control automáticamente (freeze termina)
	# Música de panic
	AudioManager.play_music("tutorial_panic")

	# NO mostrar tutorial hint (reveal no está desbloqueado en T0)
	# El jugador solo puede correr

func _shake_sprite(duration: float, intensity: float) -> void:
	if not sprite:
		return

	# Funciona tanto para Sprite2D como ColorRect
	var original_pos = sprite.position
	var elapsed = 0.0

	while elapsed < duration:
		sprite.position = original_pos + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	sprite.position = original_pos

func _spawn_mask_break_particles() -> void:
	# Crear partículas simples de máscara rompiéndose
	# TODO: Usar ParticleEffects si está disponible
	if has_node("/root/ParticleEffects"):
		var fx = get_node("/root/ParticleEffects")
		if fx.has_method("spawn_mask_break"):
			fx.spawn_mask_break(global_position)

func _transform_to_revealed() -> void:
	# Cambiar sprite a versión revelada
	if sprite:
		# Intentar cambiar color según tipo
		if sprite.has_method("set_color"):
			# Es ColorRect
			sprite.call("set_color", Color(1.0, 0.2, 0.2))
		elif sprite.has_method("set_modulate"):
			# Es Sprite2D
			sprite.set_modulate(Color(1.0, 0.2, 0.2))

	# Activar aura roja si existe
	if has_node("Aura"):
		$Aura.visible = true
		$Aura.modulate = Color.RED

	print("Tutorial0FalseFriend transformed to revealed form!")

func _lunge_attack() -> void:
	# Animación de lunge hacia jugador
	if not player:
		return

	var direction = (player.global_position - global_position).normalized()
	var tween = create_tween()
	tween.tween_property(self, "global_position",
		global_position + direction * 30, 0.2)

func _start_chase() -> void:
	current_state = State.CHASING
	print("Tutorial 0: Chase started")

func _idle_behavior() -> void:
	# Estático, esperando al jugador
	velocity.x = 0

	# Animación idle si existe
	if anim_player and anim_player.has_animation("idle"):
		if anim_player.current_animation != "idle":
			anim_player.play("idle")

func _chase_behavior() -> void:
	if not player:
		velocity.x = 0
		return

	var direction = (player.global_position - global_position).normalized()

	# Movimiento horizontal
	velocity.x = direction.x * CHASE_SPEED

	# Saltar si jugador está arriba
	if is_on_floor() and player.global_position.y < global_position.y - 50:
		velocity.y = JUMP_FORCE

	# Animación de chase si existe
	if anim_player and anim_player.has_animation("chase"):
		if anim_player.current_animation != "chase":
			anim_player.play("chase")

	# Verificar si alcanzó al jugador
	var distance = global_position.distance_to(player.global_position)
	if distance < CATCH_RANGE:
		_catch_player()

func _catch_player() -> void:
	print("Tutorial 0: Player caught!")

	# Detener persecución
	current_state = State.IDLE
	velocity = Vector2.ZERO

	# Animación de ataque final (opcional)
	if anim_player and anim_player.has_animation("attack"):
		anim_player.play("attack")

	# Hacer mucho daño (matar al jugador)
	if player and player.has_method("scripted_death"):
		player.scripted_death()
	else:
		# Fallback: Hacer 999 de daño
		GameManager.change_health(-999)

	# El GameManager manejará la transición a Tutorial 1
