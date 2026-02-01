# Debug Guide: Level 3 TrueThreat Not Shooting

## Problema Reportado
Los TrueThreat en Level 3 no están spawneando proyectiles

## Pasos de Debugging

### 1. Verificar que los enemigos se están revelando
**Ejecuta Level 3 y revela un TrueThreat, luego chequea la consola de Godot**

Deberías ver este mensaje:
```
True Threat revealed! Now firing projectiles...
```

- ✅ **Si aparece:** El enemigo se revela correctamente, el problema está en el disparo
- ❌ **Si NO aparece:** El enemigo no se está revelando, el problema está en VeilComponent

### 2. Verificar que el jugador se encuentra correctamente
**Agrega prints de debug temporales en `true_threat.gd`**

Abre `scripts/entities/true_threat.gd` y modifica la línea 54-56:

```gdscript
# ANTES:
# Buscar al jugador
player_ref = get_tree().get_first_node_in_group("player")

# DESPUÉS:
# Buscar al jugador
player_ref = get_tree().get_first_node_in_group("player")
print("DEBUG: Player found = ", player_ref != null)
if player_ref:
    print("DEBUG: Player position = ", player_ref.global_position)
```

**Ejecuta Level 3 nuevamente y revela un TrueThreat**

Deberías ver:
```
True Threat revealed! Now firing projectiles...
DEBUG: Player found = true
DEBUG: Player position = (x, y)
```

- ✅ **Si player_ref es true:** El jugador se encuentra correctamente
- ❌ **Si player_ref es null:** El jugador no está en el grupo "player" en Level 3

### 3. Verificar que el FireTimer está funcionando
**Agrega print en el callback del timer**

Modifica la línea 66-69 en `true_threat.gd`:

```gdscript
func _on_fire_timer_timeout() -> void:
    """Dispara un proyectil hacia el jugador con predicción de movimiento"""
    print("DEBUG: Fire timer timeout! is_revealed=", is_revealed, " player_ref=", player_ref != null)

    if not is_revealed or not player_ref or not is_instance_valid(player_ref):
        print("DEBUG: Skipping shot - not ready")
        return
```

**Ejecuta Level 3 y espera 2-3 segundos después de revelar**

Deberías ver cada 2 segundos:
```
DEBUG: Fire timer timeout! is_revealed=true player_ref=true
```

- ✅ **Si aparece:** El timer funciona, el problema está en la creación del proyectil
- ❌ **Si NO aparece:** El timer no se está iniciando correctamente

### 4. Verificar creación del proyectil
**Agrega print en la creación del proyectil**

Modifica la línea 71-86 en `true_threat.gd`:

```gdscript
# Crear proyectil
print("DEBUG: Creating projectile from scene: ", projectile_scene)
var projectile = projectile_scene.instantiate() as Projectile
print("DEBUG: Projectile created: ", projectile != null)

# Posicionar en la posición del enemigo
projectile.global_position = global_position

# Calcular posición predicha del jugador
var target_position = _predict_player_position()
print("DEBUG: Target position: ", target_position)

# Calcular dirección hacia la posición predicha
var direction = (target_position - global_position).normalized()
projectile.set_direction(direction)
projectile.speed = projectile_speed

# FIX MEMORY LEAK: Usar ProjectileManager en lugar de root
print("DEBUG: Adding projectile to ProjectileManager")
ProjectileManager.add_projectile(projectile)
print("DEBUG: Projectile added successfully")
```

**Ejecuta Level 3 y revela TrueThreat**

Deberías ver:
```
DEBUG: Creating projectile from scene: [PackedScene:...]
DEBUG: Projectile created: true
DEBUG: Target position: (x, y)
DEBUG: Adding projectile to ProjectileManager
DEBUG: Projectile added successfully
```

### 5. Verificar ProjectileManager en Level 3
**Chequea que el container se crea correctamente**

Abre la consola de Godot cuando cargas Level 3. Deberías ver:
```
ProjectileManager: Container created in Level3
```

- ✅ **Si aparece:** ProjectileManager funciona
- ❌ **Si NO aparece:** ProjectileManager no se inicializó en Level 3

---

## Soluciones Posibles según los Resultados

### Caso 1: Enemigo no se revela
**Problema:** VeilComponent no funciona
**Solución:** Verificar que los TrueThreat en level_3.tscn tienen VeilComponent como hijo

### Caso 2: Player no se encuentra
**Problema:** El jugador no está en el grupo "player" en Level 3
**Solución:** Verificar que Player en level_3.tscn está en el grupo "player"

### Caso 3: Timer no funciona
**Problema:** FireTimer no se inicia o no está conectado
**Solución:**
- Verificar que `fire_timer.timeout.connect(_on_fire_timer_timeout)` se ejecuta
- Verificar que `fire_timer.start()` se llama en `_on_veil_torn()`

### Caso 4: Proyectil no se crea
**Problema:** projectile_scene es null
**Solución:** Verificar que la escena se carga correctamente en línea 42

### Caso 5: ProjectileManager falla
**Problema:** El container no existe en Level 3
**Solución:** Verificar que ProjectileManager está en autoloads

---

## Quick Fix: Asignar projectile_scene manualmente

Si el problema es que `projectile_scene` no se carga, puedes asignarlo manualmente en la escena:

1. Abre `scenes/characters/entities/true_threat.tscn` en Godot
2. Selecciona el nodo raíz "TrueThreat"
3. En Inspector, bajo "Combat", busca "Projectile Scene"
4. Arrastra `scenes/components/projectile.tscn` a ese campo
5. Guarda la escena

Esto asignará la escena directamente sin depender del fallback en código.

---

## Diferencia entre Level 1/2 y Level 3

Si funciona en Level 1 pero no en Level 3, las diferencias son:

1. **Tamaño del nivel:** Level 3 es más grande (7300 vs 3500)
   - Posible que el jugador esté fuera de rango cuando el enemigo se revela
   - Posible que la cámara no esté siguiendo al jugador correctamente

2. **Cantidad de enemigos:** Level 3 tiene 16 enemigos vs 7 en Level 1
   - Posible límite de nodos hijos en ProjectileManager
   - Posible problema de performance que previene disparos

3. **Orden de instanciación:** Los TrueThreat están en diferentes áreas
   - Posible que los enemigos en áreas específicas tengan problemas

---

## Prueba Rápida Final

**Crea un TrueThreat de prueba al inicio de Level 3:**

1. Abre `level_3.tscn` en Godot
2. Bajo "Entities", agrega un nuevo TrueThreat
3. Posiciónalo en (500, 540) - muy cerca del spawn
4. Ejecuta el nivel, muévete 2 pasos y revélalo inmediatamente
5. Espera a ver si dispara

- ✅ **Si este dispara:** El problema es específico a los TrueThreat en posiciones alejadas
- ❌ **Si tampoco dispara:** El problema es general en Level 3
