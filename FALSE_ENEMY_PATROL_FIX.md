# False Enemy Patrol System - Fix Documentation

**Fecha:** 2026-01-31
**Problema:** False Enemies no patrullaban visualmente
**Estado:** ✅ RESUELTO

---

## 🐛 Problema Original

Los False Enemies estaban configurados para patrullar pero **no se veían moviéndose** en el juego.

### Síntomas:
- Enemigos aparecían estáticos
- Código de patrullaje existía pero no era visible
- Algunos vibraban en el lugar

---

## 🔍 Diagnóstico (Debug Process)

### Debug Round 1: Raycast Detection
**Problema identificado:** `floor_ahead=false`
- El raycast `_is_floor_ahead()` no detectaba suelo adelante
- Causaba que dieran vuelta cada frame → vibración

**Causa raíz:**
Raycast mal posicionado - partía desde **16px debajo del centro**, dentro del suelo.

**Solución:**
```gdscript
// ANTES:
var from = global_position + Vector2(direction * 16, 16)  // Dentro del suelo

// DESPUÉS:
var feet_offset = 15.0  // A la altura de los pies
var from = global_position + Vector2(direction * 20, feet_offset)
```

### Debug Round 2: Velocidad Insuficiente
**Problema identificado:** `moved=1.33 px` por frame
- SÍ patrullaban pero a 50-80 px/s (muy lento)
- Player corre a 200 px/s → enemigos parecen estáticos en comparación

**Solución:**
```gdscript
patrol_speed: 50.0 → 120.0  // 60% de velocidad del player
flee_speed: 100.0 → 180.0   // 90% de velocidad del player
```

### Debug Round 3: Collision con Puertas
**Problema identificado:** `is_wall=true` al chocar con Truth Doors
- Truth Doors en Layer 1 (World) por defecto
- False Enemies detectan Layer 1 → chocan y vibran

**Solución:**
- Crear **Layer 5: Doors**
- Truth Doors: `collision_layer = 16` (Layer 5)
- Player: `collision_mask = 17` (detecta World + Doors)
- False Enemies: `collision_mask = 1` (solo World, NO Doors)

---

## ✅ Solución Final

### Archivos Modificados:

**1. scripts/entities/false_enemy.gd**
```gdscript
@export var patrol_speed: float = 120.0  // Velocidad visible
@export var flee_speed: float = 180.0

func _is_floor_ahead() -> bool:
    var feet_offset = 15.0
    var ahead_distance = 20.0
    var down_distance = 10.0

    var from = global_position + Vector2(direction * ahead_distance, feet_offset)
    var to = from + Vector2(0, down_distance)
    // ... raycast correctamente posicionado
```

**2. project.godot**
```ini
2d_physics/layer_5="Doors"  // Nuevo layer
```

**3. scenes/level/truth_door.tscn**
```gdscript
collision_layer = 16  // Layer 5: Doors
collision_mask = 2    // Detecta Player
```

**4. scenes/characters/player.tscn**
```gdscript
collision_mask = 17  // Detecta World (1) + Doors (16)
```

---

## 🎮 Resultado

**False Enemies ahora:**
- ✅ Patrullan visiblemente a 120 px/s
- ✅ Detectan bordes correctamente (no caen)
- ✅ Dan vuelta en paredes
- ✅ Atraviesan Truth Doors sin chocar
- ✅ Huyen a 180 px/s cuando son revelados

**Comportamiento correcto:**
1. **Enmascarados:** Patrullan defensivamente (velocidad media)
2. **Revelados:** Huyen del jugador (velocidad alta)

---

## 📊 Collision Layers Final

| Layer | Nombre | Uso |
|-------|--------|-----|
| 1 | World | Plataformas, suelo, paredes |
| 2 | Player | Jugador |
| 3 | Entities | Enemigos (False/True) |
| 4 | Projectiles | Proyectiles enemigos |
| 5 | Doors | Truth Doors (nuevas) |

**Configuración por Entidad:**

| Entidad | collision_layer | collision_mask | Significado |
|---------|-----------------|----------------|-------------|
| Player | 2 | 17 (1+16) | Está en layer Player, detecta World + Doors |
| False Enemy | 4 | 1 | Está en Entities, solo detecta World |
| False Friend | 4 | 1 | Está en Entities, solo detecta World |
| True Threat | 0 | 0 | StaticBody sin movimiento |
| Truth Door | 16 | 2 | Está en Doors, detecta Player |
| Projectiles | 8 | 2 | Está en Projectiles, detecta Player |

---

## 🧪 Testing Checklist

- [x] False Enemies patrullan visiblemente
- [x] Dan vuelta en bordes (no caen)
- [x] Dan vuelta en paredes
- [x] Atraviesan Truth Doors sin chocar
- [x] Huyen cuando son revelados
- [x] Player puede pasar por Truth Doors abiertas
- [x] Velocidad balanceada (ni muy lento ni muy rápido)

---

## 💡 Lecciones Aprendidas

1. **Raycast positioning is critical:** Usar coordenadas relativas al sprite size
2. **Speed matters:** 50 px/s es imperceptible, 120 px/s es visible
3. **Collision layers are powerful:** Separar Doors de World evita problemas
4. **Debug incrementally:** Floor detection → Speed → Collisions

---

**Última actualización:** 2026-01-31
**Estado:** Funcional y testeado ✅
