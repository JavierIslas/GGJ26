class_name RevealSystem
extends Node2D
## Sistema de revelación de velos
##
## Detecta entidades enmascaradas cercanas, maneja input de revelación,
## y coordina feedback visual (partículas, screen shake, flash).

signal entity_revealed(entity: Node2D)

## Rango de detección (32 píxeles según GDD)
@export var reveal_range: float = 48.0

## Cooldown entre revelaciones (0.5s según GDD)
@export var reveal_cooldown: float = 0.5

## Referencias
@onready var player: PlayerController = get_parent() as PlayerController
@onready var detection_area: Area2D = $DetectionArea
@onready var cooldown_timer: Timer = $CooldownTimer

## Estado
var entities_in_range: Array[Node2D] = []
var is_on_cooldown: bool = false
var current_target: Node2D = null

func _ready() -> void:
	_setup_detection_area()
	_setup_cooldown_timer()

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

func _process(_delta: float) -> void:
	# Actualizar indicador visual de entidad más cercana
	_update_closest_target()

	# Detectar input de revelación
	if Input.is_action_just_pressed("reveal") and not is_on_cooldown:
		_attempt_reveal()

func _on_entity_entered_range(body: Node2D) -> void:
	if body.has_node("VeilComponent"):
		var veil = body.get_node("VeilComponent") as VeilComponent
		if not veil.is_revealed:
			entities_in_range.append(body)

func _on_entity_exited_range(body: Node2D) -> void:
	if body in entities_in_range:
		entities_in_range.erase(body)

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

	# Bloquear movimiento del jugador durante animación
	if player.has_method("start_tear_veil_animation"):
		player.start_tear_veil_animation()

	# Feedback visual inmediato
	_show_reveal_feedback(entity)

	# Arrancar el velo
	veil.tear_veil()

	# Emitir señal
	entity_revealed.emit(entity)

	# SFX (se manejará con AudioManager)
	AudioManager.play_sfx("tear_veil")

func _show_reveal_feedback(entity: Node2D) -> void:
	# Flash de pantalla blanco (30% opacity, 0.1s)
	_flash_screen()

	# Screen shake leve (trauma 0.3)
	_shake_camera(0.3)

	# Partículas en la entidad (se implementará después)
	_spawn_reveal_particles(entity.global_position)

func _flash_screen() -> void:
	# Crear flash temporal
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.3)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Añadir a CanvasLayer para que esté encima de todo
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	canvas.add_child(flash)

	# Fade out
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func(): canvas.queue_free())

func _shake_camera(trauma_amount: float) -> void:
	# Buscar la cámara del jugador
	if player.has_node("Camera2D"):
		var camera = player.get_node("Camera2D")

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
	"""Crea partículas de fragmentos de velo cayendo"""
	var particles = GPUParticles2D.new()

	# Configuración básica
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 0.8
	particles.explosiveness = 1.0

	# Material de partícula
	var material = ParticleProcessMaterial.new()

	# Emisión en explosión radial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 8.0

	# Dirección y velocidad
	material.direction = Vector3(0, 1, 0)  # Hacia abajo
	material.spread = 180.0  # Explosión en todas direcciones
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 150.0

	# Gravedad
	material.gravity = Vector3(0, 200, 0)

	# Escala
	material.scale_min = 2.0
	material.scale_max = 4.0

	# Rotación
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0

	# Color (blanco con fade a transparente)
	material.color = Color.WHITE
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	# Añadir al árbol
	get_tree().root.add_child(particles)

	# Auto-destruir después de la vida útil
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func _on_cooldown_finished() -> void:
	is_on_cooldown = false

## Obtiene la entidad objetivo actual (útil para UI)
func get_current_target() -> Node2D:
	return current_target
