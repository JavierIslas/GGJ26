extends FalseEnemy
class_name FalseEnemyFast
## Falso Enemigo Rápido (Variante de Tipo 1)
##
## ENMASCARADO: Patrulla MUY rápido, agresivo
## REVELADO: Huye a velocidad extrema, pánico total

func _ready() -> void:
	super._ready()

	# Velocidades aumentadas
	patrol_speed = 100.0  # 2x más rápido que normal (50)
	flee_speed = 200.0    # 2x más rápido que normal (100)

	# Visual: Rojo más intenso para indicar mayor peligro aparente
	if sprite:
		sprite.modulate = Color(1.0, 0.2, 0.2, 0.7)  # Rojo brillante, 70% opacidad
