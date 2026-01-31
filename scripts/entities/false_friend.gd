class_name FalseFriend
extends CharacterBody2D
## Falso Aliado (Tipo 2)
##
## ENMASCARADO: Parece amigable, estático, hace señas
## REVELADO: Se transforma en monstruo agresivo que persigue

signal died

@export_group("Movement")
@export var chase_speed: float = 120.0

@export_group("Combat")
@export var damage: int = 1
@export var attack_range: float = 24.0  # Reducido para que no se frene tan lejos

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_revealed: bool = false
var player_ref: Node2D = null
var can_attack: bool = true

func _ready() -> void:
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		veil_component.veil_torn.connect(_on_veil_torn)

	# Configurar hurtbox (daña al jugador al contacto cuando revelado)
	if hurtbox:
		hurtbox.monitoring = false  # Desactivado mientras está enmascarado
		hurtbox.body_entered.connect(_on_hurtbox_body_entered)

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

	# Buscar al jugador si no lo tenemos
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player")

	if not player_ref:
		# No hay jugador, quedarse quieto
		velocity.x = move_toward(velocity.x, 0, chase_speed)
		return

	# Calcular dirección hacia el jugador
	var direction_to_player = sign(player_ref.global_position.x - global_position.x)

	# Perseguir si está lejos
	var distance_to_player = global_position.distance_to(player_ref.global_position)

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

	# Activar hurtbox para dañar al jugador
	if hurtbox:
		hurtbox.monitoring = true

	# Rugido/transformación
	if animation_player and animation_player.has_animation("transform"):
		animation_player.play("transform")

	print("False Friend revealed! Now hostile!")

func _on_hurtbox_body_entered(body: Node2D) -> void:
	"""Daña al jugador al contacto"""
	if not is_revealed or not can_attack:
		return

	if body.is_in_group("player"):
		# Dañar al jugador
		GameManager.change_health(-damage)
		print("False Friend damaged player: -%d HP" % damage)

		# Cooldown breve para evitar daño múltiple instantáneo
		can_attack = false
		await get_tree().create_timer(0.5).timeout
		can_attack = true
