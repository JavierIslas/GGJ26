class_name RevealSystem
extends Node2D
## Sistema de Revelación - "Arrancar el Velo"
##
## NARRATIVA: El poder de la protagonista para revelar verdades ocultas.
##           Arrancar velos = Confrontar la verdad sin filtros.
##           No cambia a las personas, revela lo que siempre fueron.
##
## Detecta entidades enmascaradas cercanas (48px), maneja input de revelación,
## y coordina feedback visual multicapa (partículas, screen shake, flash con color coding).

signal entity_revealed(entity: Node2D)

## Rango de detección (32 píxeles según GDD)
@export var reveal_range: float = 48.0

## Cooldown entre revelaciones (0.5s según GDD)
@export var reveal_cooldown: float = 0.5

## === WOLF'S HOWL PARAMETERS ===
@export var howl_charge_time_required: float = 1.5  # Segundos para cargar howl
@export var howl_radius: float = 96.0  # Radio de efecto (doble del reveal)
@export var howl_stun_duration: float = 2.0  # Duración del aturdimiento
@export var howl_cooldown: float = 8.0  # Cooldown del howl

## Referencias
@onready var player: PlayerController = get_parent() as PlayerController
@onready var detection_area: Area2D = $DetectionArea
@onready var cooldown_timer: Timer = $CooldownTimer

## Cache de nodos
var camera: Node2D = null

## Estado
var entities_in_range: Array[Node2D] = []
var is_on_cooldown: bool = false
var current_target: Node2D = null
var needs_target_update: bool = false

## Wolf's Howl state
var howl_charge_time: float = 0.0
var is_charging_howl: bool = false
var is_howl_on_cooldown: bool = false
var howl_cooldown_timer: Timer = null

func _ready() -> void:
	_setup_detection_area()
	_setup_cooldown_timer()
	_setup_howl_cooldown_timer()

	# Cachear referencia a cámara
	if player and player.has_node("Camera2D"):
		camera = player.get_node("Camera2D")

func _setup_detection_area() -> void:
	if not has_node("DetectionArea"):
		detection_area = Area2D.new()
		detection_area.name = "DetectionArea"
		add_child(detection_area)

		# Crear CollisionShape circular
		var shape = CircleShape2D.new()
		shape.radius = reveal_range

		var collision = CollisionShape2D.new()
		collision.shape = shape
		detection_area.add_child(collision)

	# Configurar layers (detecta entidades en layer 3)
	detection_area.collision_layer = 0
	detection_area.collision_mask = 4  # Layer 3 (Entities)

	# Conectar señales
	detection_area.body_entered.connect(_on_entity_entered_range)
	detection_area.body_exited.connect(_on_entity_exited_range)

func _setup_cooldown_timer() -> void:
	if not has_node("CooldownTimer"):
		cooldown_timer = Timer.new()
		cooldown_timer.name = "CooldownTimer"
		cooldown_timer.one_shot = true
		add_child(cooldown_timer)

	cooldown_timer.timeout.connect(_on_cooldown_finished)

func _setup_howl_cooldown_timer() -> void:
	if not has_node("HowlCooldownTimer"):
		howl_cooldown_timer = Timer.new()
		howl_cooldown_timer.name = "HowlCooldownTimer"
		howl_cooldown_timer.one_shot = true
		add_child(howl_cooldown_timer)

	howl_cooldown_timer.timeout.connect(_on_howl_cooldown_finished)

func _process(delta: float) -> void:
	# Solo actualizar target si hay cambios en entities_in_range
	if needs_target_update:
		_update_closest_target()
		needs_target_update = false

	# === WOLF'S HOWL: Detectar hold de tecla E ===
	if Input.is_action_pressed("reveal") and not is_on_cooldown and not is_howl_on_cooldown:
		# Cargar howl
		is_charging_howl = true
		howl_charge_time += delta

		# Feedback visual de carga
		_update_howl_charge_visual()

		# Si completó la carga, ejecutar howl
		if howl_charge_time >= howl_charge_time_required:
			_perform_howl()
			howl_charge_time = 0.0
			is_charging_howl = false
	else:
		# Soltar botón antes de completar - resetear carga
		if is_charging_howl:
			_cancel_howl_charge()
		howl_charge_time = 0.0
		is_charging_howl = false

	# Detectar input de revelación (tap rápido)
	if Input.is_action_just_pressed("reveal") and not is_on_cooldown:
		# Solo intentar reveal si no está en cooldown de howl
		if not is_howl_on_cooldown:
			_attempt_reveal()

func _on_entity_entered_range(body: Node2D) -> void:
	if body.has_node("VeilComponent"):
		var veil = body.get_node("VeilComponent") as VeilComponent
		if not veil.is_revealed:
			entities_in_range.append(body)
			needs_target_update = true

func _on_entity_exited_range(body: Node2D) -> void:
	if body in entities_in_range:
		entities_in_range.erase(body)
		needs_target_update = true

	if body == current_target:
		current_target = null

func _update_closest_target() -> void:
	if entities_in_range.is_empty():
		current_target = null
		return

	# Encontrar entidad más cercana
	var closest: Node2D = null
	var min_distance: float = INF

	for entity in entities_in_range:
		if not is_instance_valid(entity):
			continue

		var distance = player.global_position.distance_to(entity.global_position)
		if distance < min_distance:
			min_distance = distance
			closest = entity

	current_target = closest

func _attempt_reveal() -> void:
	if not current_target or not is_instance_valid(current_target):
		return

	# Verificar que tiene VeilComponent
	if not current_target.has_node("VeilComponent"):
		return

	var veil = current_target.get_node("VeilComponent") as VeilComponent

	if veil.is_revealed:
		return

	# Iniciar revelación
	_perform_reveal(current_target, veil)

func _perform_reveal(entity: Node2D, veil: VeilComponent) -> void:
	# Activar cooldown
	is_on_cooldown = true
	cooldown_timer.start(reveal_cooldown)

	# === POLISH: Freeze frame para impacto ===
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1.0

	# === POLISH: Gamepad vibration ===
	_apply_gamepad_vibration(0.3, 0.3, 0.2)

	# Bloquear movimiento del jugador durante animación
	if player.has_method("start_tear_veil_animation"):
		player.start_tear_veil_animation()

	# Feedback visual inmediato
	_show_reveal_feedback(entity)

	# Arrancar el velo
	veil.tear_veil()

	# === VEIL SHARDS: Generar shard al revelar ===
	if player.has_method("add_veil_shard"):
		player.add_veil_shard()

	# Emitir señal
	entity_revealed.emit(entity)

	# SFX (se manejará con AudioManager)
	AudioManager.play_sfx("tear_veil")

func _show_reveal_feedback(entity: Node2D) -> void:
	# Determinar tipo de enemigo
	var is_true_threat = _is_true_threat(entity)

	# === POLISH: Flash de pantalla con color coding ===
	_flash_screen_typed(is_true_threat)

	# === POLISH: Chromatic aberration effect ===
	# DESACTIVADO - Puede causar sensación de motion blur
	# _chromatic_aberration_effect()

	# Screen shake leve (trauma 0.3)
	_shake_camera(0.3)

	# Partículas en la entidad (se implementará después)
	_spawn_reveal_particles(entity.global_position)

func _flash_screen() -> void:
	# Versión legacy - usar blanco por defecto
	_flash_screen_typed(false)

func _flash_screen_typed(is_true_threat: bool) -> void:
	"""Flash de pantalla con color según tipo de enemigo"""
	# Crear flash temporal
	var flash = ColorRect.new()

	# === POLISH: Color coding por tipo (intensidad REDUCIDA) ===
	if is_true_threat:
		# True Threat = Flash rojo/púrpura (peligro) - SUAVE
		flash.color = Color(1.0, 0.3, 0.5, 0.15)  # Alpha reducido de 0.35 a 0.15
	else:
		# False Enemy = Flash azul (inofensivo) - MUY SUAVE
		flash.color = Color(0.5, 0.7, 1.0, 0.12)  # Alpha reducido de 0.3 a 0.12

	flash.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Añadir a CanvasLayer para que esté encima de todo
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	canvas.add_child(flash)

	# Fade out más rápido
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.12)  # Reducido de 0.15s a 0.12s
	tween.finished.connect(func(): canvas.queue_free())

func _shake_camera(trauma_amount: float) -> void:
	# Usar cámara cacheada
	if not camera:
		return

	# Si la cámara tiene el método add_trauma (script camera_shake.gd)
	if camera.has_method("add_trauma"):
		camera.add_trauma(trauma_amount)
	else:
		# Fallback: shake simple
		var original_offset = camera.offset
		camera.offset = Vector2(randf_range(-3, 3), randf_range(-3, 3))

		var tween = create_tween()
		tween.tween_property(camera, "offset", original_offset, 0.2)

func _spawn_reveal_particles(pos: Vector2) -> void:
	"""Crea partículas de fragmentos de velo cayendo con burst radial mejorado"""
	var particles = CPUParticles2D.new()

	# Configuración básica - MÁS PARTÍCULAS para más impacto
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 30  # Aumentado de 20
	particles.lifetime = 1.0  # Aumentado de 0.8
	particles.explosiveness = 1.0

	# Emisión en explosión radial - MÁS GRANDE
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 12.0  # Aumentado de 8.0

	# Dirección y velocidad - MÁS RÁPIDA
	particles.direction = Vector2(0, 1)  # Hacia abajo
	particles.spread = 180.0  # Explosión en todas direcciones
	particles.initial_velocity_min = 80.0  # Aumentado de 50.0
	particles.initial_velocity_max = 200.0  # Aumentado de 150.0

	# Gravedad
	particles.gravity = Vector2(0, 250)  # Aumentado de 200

	# Escala - MÁS GRANDES
	particles.scale_amount_min = 3.0  # Aumentado de 2.0
	particles.scale_amount_max = 6.0  # Aumentado de 4.0

	# Rotación - MÁS RÁPIDA
	particles.angular_velocity_min = -360.0  # Aumentado de -180.0
	particles.angular_velocity_max = 360.0  # Aumentado de 180.0

	# === POLISH: Color con más punch (blanco brillante) ===
	particles.color = Color(1.5, 1.5, 1.5, 1.0)  # Overbright
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.5, 1.5, 1.5, 1.0))
	gradient.add_point(0.7, Color(1.0, 1.0, 1.0, 0.7))
	gradient.add_point(1.0, Color(1.0, 1.0, 1.0, 0.0))
	particles.color_ramp = gradient

	# Añadir al árbol
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

func _on_cooldown_finished() -> void:
	is_on_cooldown = false

func _apply_gamepad_vibration(weak_magnitude: float, strong_magnitude: float, duration: float) -> void:
	"""Vibración de gamepad para feedback táctil"""
	var joy_list = Input.get_connected_joypads()
	for joy_id in joy_list:
		Input.start_joy_vibration(joy_id, weak_magnitude, strong_magnitude, duration)

func _chromatic_aberration_effect() -> void:
	"""Efecto de chromatic aberration en pantalla completa al revelar"""
	# Crear ColorRect fullscreen con shader
	var aberration_rect = ColorRect.new()
	aberration_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	aberration_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Cargar shader
	var shader = load("res://resources/shaders/chromatic_aberration.gdshader")
	if not shader:
		return  # Shader no encontrado, skip

	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader

	# Configurar parámetros iniciales
	shader_material.set_shader_parameter("intensity", 0.5)
	shader_material.set_shader_parameter("center", Vector2(0.5, 0.5))

	aberration_rect.material = shader_material

	# Añadir a CanvasLayer encima de todo
	var canvas = CanvasLayer.new()
	canvas.layer = 99  # Justo debajo del flash (que es 100)
	get_tree().root.add_child(canvas)
	canvas.add_child(aberration_rect)

	# Animar intensidad de aberration: 0.5 -> 0.0 en 0.3s
	var tween = create_tween()
	tween.tween_method(
		func(value: float): shader_material.set_shader_parameter("intensity", value),
		0.5,
		0.0,
		0.3
	)
	tween.finished.connect(func(): canvas.queue_free())

func _is_true_threat(entity: Node2D) -> bool:
	"""Determina si la entidad es un True Threat o False Enemy"""
	# Verificar por class_name o grupos
	if entity.is_class("TrueThreat") or entity.is_class("TrueThreatShield") or \
	   entity.is_class("TrueThreatLaser") or entity.is_class("TrueThreatBurst") or \
	   entity.is_class("TrueThreatTracking"):
		return true

	# Verificar por nombre del nodo (fallback)
	var entity_name = entity.name.to_lower()
	if "true" in entity_name or "threat" in entity_name:
		return true

	# Si tiene color púrpura/rojo, probablemente es True Threat
	if entity.has_node("Sprite2D"):
		var sprite = entity.get_node("Sprite2D")
		if sprite.modulate.r < 0.7 and sprite.modulate.b > 0.5:  # Púrpura
			return true

	return false

## Obtiene la entidad objetivo actual (útil para UI)
func get_current_target() -> Node2D:
	return current_target

# === WOLF'S HOWL SYSTEM ===

func _perform_howl() -> void:
	"""Ejecuta el Wolf's Howl - aturde enemigos revelados en área"""
	print("=== WOLF'S HOWL UNLEASHED ===")

	# Activar cooldown
	is_howl_on_cooldown = true
	howl_cooldown_timer.start(howl_cooldown)

	# === POLISH: Freeze frame intenso ===
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1.0

	# === POLISH: Gamepad vibration fuerte ===
	_apply_gamepad_vibration(0.8, 0.8, 0.5)

	# === POLISH: Camera shake fuerte ===
	_shake_camera(0.8)

	# === POLISH: Flash de pantalla blanco intenso ===
	_howl_screen_flash()

	# Bloquear movimiento del jugador brevemente
	if player.has_method("start_tear_veil_animation"):
		# Usar la misma animación o crear una nueva
		# Por ahora reusar la animación de tear veil
		pass

	# Detectar enemigos revelados en radio amplio
	var stunned_count = 0
	for entity in get_tree().get_nodes_in_group("entities"):
		if not is_instance_valid(entity):
			continue

		# Verificar distancia
		var distance = player.global_position.distance_to(entity.global_position)
		if distance > howl_radius:
			continue

		# Verificar si está revelado
		if not entity.has_node("VeilComponent"):
			continue

		var veil = entity.get_node("VeilComponent")
		if not veil.is_revealed:
			continue

		# Aturdir enemigo
		if entity.has_method("stun"):
			entity.stun(howl_stun_duration)
			stunned_count += 1
			print("  - Stunned: %s" % entity.name)

	# Partículas de howl
	_spawn_howl_particles()

	# SFX
	AudioManager.play_sfx("wolf_howl", 0.0)

	print("=== Wolf's Howl stunned %d enemies ===" % stunned_count)

func _update_howl_charge_visual() -> void:
	"""Feedback visual mientras carga el howl"""
	if not player:
		return

	# Calcular progreso (0.0 a 1.0)
	var progress = min(howl_charge_time / howl_charge_time_required, 1.0)

	# Pulsar escala del sprite
	var scale_amount = 1.0 + (progress * 0.1)  # Hasta 1.1
	player.sprite.scale = Vector2(scale_amount, scale_amount)

	# Partículas de carga (cada 0.2s)
	if int(howl_charge_time * 5) > int((howl_charge_time - get_process_delta_time()) * 5):
		_spawn_charge_particles()

func _cancel_howl_charge() -> void:
	"""Cancela la carga del howl"""
	# Resetear escala del sprite
	if player and player.sprite:
		var tween = create_tween()
		tween.tween_property(player.sprite, "scale", Vector2.ONE, 0.2)

func _on_howl_cooldown_finished() -> void:
	"""Callback cuando termina el cooldown del howl"""
	is_howl_on_cooldown = false
	print("Wolf's Howl ready!")

func _howl_screen_flash() -> void:
	"""Flash blanco intenso al ejecutar howl"""
	var flash = ColorRect.new()

	# Flash blanco puro
	flash.color = Color(1.5, 1.5, 1.5, 0.4)  # Más intenso que reveal
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Añadir a CanvasLayer
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	canvas.add_child(flash)

	# Fade out rápido
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func(): canvas.queue_free())

func _spawn_howl_particles() -> void:
	"""Partículas de onda expansiva del howl"""
	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = player.global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 50  # Muchas partículas para impacto
	particles.lifetime = 1.5
	particles.explosiveness = 1.0

	# Emisión radial - CPUParticles no tiene EMISSION_SHAPE_RING, usar SPHERE
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = howl_radius * 0.3

	# Explosión radial hacia afuera
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 250.0

	# Sin gravedad (onda de sonido)
	particles.gravity = Vector2.ZERO

	# Escala variable
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0

	# Rotación rápida
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0

	# Color blanco brillante con fade
	particles.color = Color(1.5, 1.5, 1.5, 1.0)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.5, 1.5, 1.5, 1.0))
	gradient.add_point(0.4, Color(1.2, 1.2, 1.2, 0.7))
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

func _spawn_charge_particles() -> void:
	"""Partículas durante la carga del howl"""
	if not player:
		return

	var particles = CPUParticles2D.new()

	# Configuración básica
	particles.global_position = player.global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 5
	particles.lifetime = 0.5
	particles.explosiveness = 1.0

	# Emisión en esfera
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 16.0

	# Movimiento hacia el jugador (implosión) - en CPU usa velocidad negativa
	particles.direction = Vector2(0, 0)
	particles.spread = 0.0
	particles.initial_velocity_min = -30.0
	particles.initial_velocity_max = -50.0

	# Sin gravedad
	particles.gravity = Vector2.ZERO

	# Escala pequeña
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Color blanco con alpha
	particles.color = Color(1.2, 1.2, 1.2, 0.6)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.2, 1.2, 1.2, 0.6))
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
