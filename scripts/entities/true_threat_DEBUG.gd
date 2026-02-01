class_name TrueThreatDebug
extends StaticBody2D
## VERSIÓN DEBUG de TrueThreat para diagnosticar problemas en Level 3
##
## INSTRUCCIONES:
## 1. Abre scenes/characters/entities/true_threat.tscn
## 2. Cambia el script de "true_threat.gd" a "true_threat_DEBUG.gd"
## 3. Guarda y ejecuta Level 3
## 4. Revisa la consola de Godot para ver los mensajes de debug

signal died

@export_group("Combat")
@export var projectile_scene: PackedScene
@export var fire_rate: float = 2.0  # Segundos entre disparos
@export var projectile_speed: float = 150.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var veil_component: VeilComponent = $VeilComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fire_timer: Timer = $FireTimer

var is_revealed: bool = false
var player_ref: Node2D = null
var debug_shot_count: int = 0

func _ready() -> void:
	print("[DEBUG TrueThreat] _ready() called at position: ", global_position)
	add_to_group("entities")

	# Conectar señal del veil
	if veil_component:
		print("[DEBUG TrueThreat] VeilComponent found, connecting signal")
		veil_component.veil_torn.connect(_on_veil_torn)
	else:
		print("[DEBUG TrueThreat] ERROR: VeilComponent NOT FOUND!")

	# Configurar timer de disparo
	if not has_node("FireTimer"):
		print("[DEBUG TrueThreat] FireTimer not found, creating one")
		fire_timer = Timer.new()
		fire_timer.name = "FireTimer"
		fire_timer.wait_time = fire_rate
		fire_timer.one_shot = false
		add_child(fire_timer)
	else:
		print("[DEBUG TrueThreat] FireTimer found in scene, wait_time: ", fire_timer.wait_time)

	fire_timer.timeout.connect(_on_fire_timer_timeout)
	print("[DEBUG TrueThreat] FireTimer timeout signal connected")

	# Cargar escena de proyectil si no está asignada
	if not projectile_scene:
		print("[DEBUG TrueThreat] projectile_scene not assigned, loading default")
		projectile_scene = load("res://scenes/components/projectile.tscn")
		print("[DEBUG TrueThreat] Projectile scene loaded: ", projectile_scene != null)
	else:
		print("[DEBUG TrueThreat] projectile_scene already assigned: ", projectile_scene)

	# Feedback visual: Parece estatua (gris, semi-opaco)
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.8)
	print("[DEBUG TrueThreat] Initialization complete")

func _on_veil_torn() -> void:
	"""Llamado cuando se revela el velo"""
	print("[DEBUG TrueThreat] ===== VEIL TORN! =====")
	print("[DEBUG TrueThreat] Position: ", global_position)

	is_revealed = true
	print("[DEBUG TrueThreat] is_revealed set to true")

	# Cambiar apariencia (placeholder: púrpura oscuro)
	sprite.modulate = Color(0.6, 0.2, 0.8, 1.0)  # Púrpura oscuro
	print("[DEBUG TrueThreat] Sprite color changed")

	# Buscar al jugador
	print("[DEBUG TrueThreat] Searching for player...")
	player_ref = get_tree().get_first_node_in_group("player")

	if player_ref:
		print("[DEBUG TrueThreat] ✅ PLAYER FOUND!")
		print("[DEBUG TrueThreat] Player position: ", player_ref.global_position)
		print("[DEBUG TrueThreat] Player type: ", player_ref.get_class())
	else:
		print("[DEBUG TrueThreat] ❌ PLAYER NOT FOUND!")
		print("[DEBUG TrueThreat] Nodes in 'player' group: ", get_tree().get_nodes_in_group("player").size())

	# Iniciar disparos
	print("[DEBUG TrueThreat] Starting FireTimer...")
	print("[DEBUG TrueThreat] Timer wait_time: ", fire_timer.wait_time)
	print("[DEBUG TrueThreat] Timer one_shot: ", fire_timer.one_shot)
	fire_timer.start()
	print("[DEBUG TrueThreat] FireTimer started. Is stopped: ", fire_timer.is_stopped())

	# Animación de "despertar"
	if animation_player and animation_player.has_animation("awaken"):
		animation_player.play("awaken")

	print("[DEBUG TrueThreat] ===== VEIL TORN COMPLETE =====")

func _on_fire_timer_timeout() -> void:
	"""Dispara un proyectil hacia el jugador con predicción de movimiento"""
	debug_shot_count += 1
	print("[DEBUG TrueThreat] ========== FIRE TIMER TIMEOUT #", debug_shot_count, " ==========")
	print("[DEBUG TrueThreat] is_revealed: ", is_revealed)
	print("[DEBUG TrueThreat] player_ref: ", player_ref)
	print("[DEBUG TrueThreat] player_ref valid: ", player_ref != null and is_instance_valid(player_ref))

	if not is_revealed:
		print("[DEBUG TrueThreat] ❌ Skipping shot: not revealed")
		return

	if not player_ref:
		print("[DEBUG TrueThreat] ❌ Skipping shot: player_ref is null")
		return

	if not is_instance_valid(player_ref):
		print("[DEBUG TrueThreat] ❌ Skipping shot: player_ref not valid")
		return

	print("[DEBUG TrueThreat] ✅ All checks passed, creating projectile...")

	# Crear proyectil
	if not projectile_scene:
		print("[DEBUG TrueThreat] ❌ ERROR: projectile_scene is null!")
		return

	print("[DEBUG TrueThreat] Instantiating projectile from scene: ", projectile_scene)
	var projectile = projectile_scene.instantiate() as Projectile

	if not projectile:
		print("[DEBUG TrueThreat] ❌ ERROR: Failed to instantiate projectile!")
		return

	print("[DEBUG TrueThreat] ✅ Projectile created successfully")

	# Posicionar en la posición del enemigo
	projectile.global_position = global_position
	print("[DEBUG TrueThreat] Projectile positioned at: ", projectile.global_position)

	# Calcular posición predicha del jugador
	var target_position = _predict_player_position()
	print("[DEBUG TrueThreat] Target position (predicted): ", target_position)

	# Calcular dirección hacia la posición predicha
	var direction = (target_position - global_position).normalized()
	print("[DEBUG TrueThreat] Direction: ", direction)

	projectile.set_direction(direction)
	projectile.speed = projectile_speed
	print("[DEBUG TrueThreat] Projectile speed set to: ", projectile_speed)

	# FIX MEMORY LEAK: Usar ProjectileManager en lugar de root
	print("[DEBUG TrueThreat] Adding projectile to ProjectileManager...")

	if not ProjectileManager:
		print("[DEBUG TrueThreat] ❌ ERROR: ProjectileManager is null!")
		return

	ProjectileManager.add_projectile(projectile)
	print("[DEBUG TrueThreat] ✅ PROJECTILE ADDED TO MANAGER!")

	# Efecto visual de disparo (pulso)
	_fire_effect()
	print("[DEBUG TrueThreat] Fire effect played")
	print("[DEBUG TrueThreat] ========== SHOT COMPLETE ==========")

func _predict_player_position() -> Vector2:
	"""Predice dónde estará el jugador basándose en su velocidad actual"""
	if not player_ref:
		return global_position

	# Posición actual del jugador
	var player_pos = player_ref.global_position

	# Obtener velocidad del jugador (si tiene CharacterBody2D)
	var player_velocity = Vector2.ZERO
	if player_ref is CharacterBody2D:
		player_velocity = player_ref.velocity

	# FIX: Si jugador no se mueve significativamente, apuntar directo
	if player_velocity.length() < 50.0:
		return player_pos

	# Calcular distancia actual
	var distance = global_position.distance_to(player_pos)

	# Calcular tiempo estimado que tardará el proyectil en llegar
	var time_to_hit = distance / projectile_speed

	# FIX: Usar predicción reducida para evitar que proyectiles vayan "con" el jugador
	# Solo predecir 50% del movimiento para que apunte más hacia donde está
	var predicted_position = player_pos + player_velocity * time_to_hit * 0.5

	return predicted_position

func _fire_effect() -> void:
	"""Efecto visual al disparar"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	var original_scale = sprite.scale
	tween.tween_property(sprite, "scale", original_scale * 1.15, 0.1)
	tween.tween_property(sprite, "scale", original_scale, 0.2)

	# TODO: SFX de disparo
	# AudioManager.play_sfx("projectile_fire")
