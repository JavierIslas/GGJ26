class_name FalseFriend
extends CharacterBody2D
## FALSE FRIEND - "Los Depredadores" (Tipo 2)
##
## NARRATIVA: Manipuladores que usan máscaras de amabilidad para cazar.
##           "Confía en mí... no te haría daño..." (mentira)
##
## ENMASCARADO: Brazos abiertos, sonrisa perfecta, hace señas "ven aquí"
## REVELADO: Monstruo con garras, persigue agresivamente, daña por contacto
##
## PREGUNTA: "¿Cuántos 'aliados' están esperando el momento de atacar?"
## CONEXIÓN: Estos victimizaron a la protagonista antes. Revelarlos es justicia y peligro.

signal died

@export_group("Movement")
@export var chase_speed: float = 120.0

@export_group("Combat")
@export var damage: int = 1
@export var attack_range: float = 24.0  # Reducido para que no se frene tan lejos
@export var knockback_force: float = 1500.0  # Fuerza de rebote al golpear
@export var knockback_duration: float = 0.6  # Tiempo de aturdimiento después de golpear

@export_group("Health")
@export var max_hp: int = 1  # Muere con 1 shard (más accesible)
var current_hp: int = max_hp

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_revealed: bool = false
var player_ref: Node2D = null
var can_attack: bool = true
var is_stunned: bool = false  # Aturdido después de golpear (knockback)
var grace_period_active: bool = false  # Grace period después de revelarse

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Configurar hurtbox (daña al jugador al contacto cuando revelado)
	if hurtbox:
		hurtbox.monitoring = false  # Desactivado mientras está enmascarado
		hurtbox.body_entered.connect(_on_hurtbox_body_entered)

	# Feedback visual: Es sólido (opaco completo)
	sprite.modulate.a = 1.0  # 100% opacidad = sólido

	# Cachear referencia al jugador
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_revealed:
		_behavior_revealed(delta)
	else:
		_behavior_masked(delta)

	move_and_slide()

func _behavior_masked(_delta: float) -> void:
	"""Comportamiento mientras está enmascarado: estático, hace señas"""

	# Quedarse quieto
	velocity.x = move_toward(velocity.x, 0, 100.0)

	# Animación de "llamar" si existe
	if animation_player and animation_player.has_animation("call"):
		if not animation_player.is_playing():
			animation_player.play("call")

func _behavior_revealed(_delta: float) -> void:
	"""Comportamiento revelado: perseguir al jugador agresivamente"""

	# Si está aturdido (knockback), solo aplicar fricción
	if is_stunned:
		velocity.x = move_toward(velocity.x, 0, chase_speed * 2.0)
		return

	if not player_ref or not is_instance_valid(player_ref):
		# No hay jugador, quedarse quieto
		velocity.x = move_toward(velocity.x, 0, chase_speed)
		return

	# Calcular dirección hacia el jugador
	var direction_to_player = sign(player_ref.global_position.x - global_position.x)

	# Perseguir siempre, no frenar
	velocity.x = direction_to_player * chase_speed

	# Saltar si hay pared adelante
	if is_on_wall() and is_on_floor():
		velocity.y = -300.0

	# Voltear sprite
	sprite.flip_h = direction_to_player < 0

func _on_veil_torn() -> void:
	"""Llamado cuando se revela el velo"""
	is_revealed = true

	# Cambiar color del sprite (placeholder hasta tener arte real)
	sprite.modulate = Color(1.0, 0.3, 0.3)  # Rojo intenso

	# FIX: Grace period para evitar daño instantáneo
	grace_period_active = true
	can_attack = false

	# FIX: Empujar levemente hacia atrás para dar espacio al jugador
	if player_ref and is_instance_valid(player_ref):
		var direction_away = sign(global_position.x - player_ref.global_position.x)
		velocity.x = direction_away * 200.0  # Pequeño empujón inicial
		velocity.y = -100.0  # Pequeño salto

	# AUTO-STUN: Aturdir al revelarse (más satisfactorio para el jugador)
	stun(2.0)

	# Activar hurtbox después de grace period (1 segundo)
	await get_tree().create_timer(1.0).timeout
	if hurtbox:
		hurtbox.monitoring = true
	can_attack = true
	grace_period_active = false

	# Rugido/transformación
	if animation_player and animation_player.has_animation("transform"):
		animation_player.play("transform")

	print("False Friend revealed! Grace period active...")

func _on_hurtbox_body_entered(body: Node2D) -> void:
	"""Daña al jugador al contacto"""
	# FIX: No hacer daño durante grace period
	if not is_revealed or not can_attack or is_stunned or grace_period_active:
		return

	if body.is_in_group("player"):
		# Dañar al jugador usando el sistema de iFrames
		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			# Fallback si el jugador no tiene el método
			GameManager.change_health(-damage)

		print("False Friend damaged player: -%d HP" % damage)

		# Aplicar knockback (rebote hacia atrás)
		_apply_knockback(body)

		# Cooldown breve para evitar daño múltiple instantáneo
		can_attack = false
		await get_tree().create_timer(0.5).timeout
		can_attack = true

func _apply_knockback(player: Node2D) -> void:
	"""Rebota hacia atrás después de golpear"""
	# Calcular dirección opuesta al jugador
	var direction_away = sign(global_position.x - player.global_position.x)

	# Aplicar fuerza de knockback
	velocity.x = direction_away * knockback_force
	velocity.y = -150.0  # Pequeño salto hacia atrás

	# Aturdir temporalmente
	is_stunned = true

	# Remover aturdimiento después del tiempo
	await get_tree().create_timer(knockback_duration).timeout
	is_stunned = false

func take_damage(amount: int) -> void:
	"""Recibe daño de shards del jugador"""
	# Solo puede ser dañado si está revelado
	if not is_revealed:
		print("False Friend: Cannot be damaged while masked")
		return

	current_hp -= amount
	print("False Friend damaged: -%d HP (Remaining: %d/%d)" % [amount, current_hp, max_hp])

	# Feedback visual de daño
	_damage_flash()

	# Verificar si murió
	if current_hp <= 0:
		_die()

func _damage_flash() -> void:
	"""Flash blanco al recibir daño"""
	var original_color = sprite.modulate
	sprite.modulate = Color(2.0, 2.0, 2.0)  # Flash blanco

	var tween = create_tween()
	tween.tween_property(sprite, "modulate", original_color, 0.15)

func _die() -> void:
	"""Muerte del False Friend"""
	print("False Friend eliminated!")

	# Partículas de muerte
	var death_color = Color(1.0, 0.3, 0.3)  # Rojo (depredador)
	ParticleEffects.spawn_death_particles(global_position, death_color, 30)

	# SFX
	AudioManager.play_sfx("enemy_destroyed", -3.0)

	# Emitir señal
	died.emit()

	# Destruir
	queue_free()

func stun(duration: float) -> void:
	"""Aturde al False Friend (Wolf's Howl)"""
	if not is_revealed:
		return

	print("False Friend stunned for %.1fs" % duration)

	# Activar estado de aturdimiento
	is_stunned = true
	can_attack = false

	# Feedback visual de stun
	_stun_visual_feedback()

	# Remover stun después del tiempo
	await get_tree().create_timer(duration).timeout
	is_stunned = false
	can_attack = true

	print("False Friend stun ended")

func _stun_visual_feedback() -> void:
	"""Feedback visual de aturdimiento"""
	# Partículas de estrellas arriba de la cabeza
	var particles = CPUParticles2D.new()

	particles.global_position = global_position + Vector2(0, -24)  # Arriba de la cabeza
	particles.emitting = true
	particles.one_shot = false  # Continuo durante stun
	particles.amount = 3
	particles.lifetime = 0.8

	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 8.0
	particles.direction = Vector2(0, -1)
	particles.spread = 30.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 20.0
	particles.gravity = Vector2(0, -20)
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 5.0
	particles.color = Color(1.0, 1.0, 0.3, 0.9)  # Amarillo (mareado)

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 0.5, 1.0))
	gradient.add_point(1.0, Color(1.0, 1.0, 0.0, 0.0))
	particles.color_ramp = gradient

	add_child(particles)

	# Destruir partículas después de stun
	await get_tree().create_timer(is_stunned and 2.0 or 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()
