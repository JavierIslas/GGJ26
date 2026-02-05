# VEIL - Torretas Avanzadas
## Documentación Técnica

Esta guía documenta las mecánicas, parámetros y comportamientos de las tres variantes avanzadas de True Threats implementadas para Level 2.

---

## 🎯 Índice

1. [Tracking Turret](#tracking-turret) - Torreta que rota para seguir al jugador
2. [Laser Turret](#laser-turret) - Láser continuo con telegraph y freeze
3. [Shield Turret](#shield-turret) - Torreta con escudo (2 revelaciones)

---

## 🔄 Tracking Turret

**Archivo:** `scripts/entities/true_threat_tracking.gd`
**Escena:** `scenes/characters/entities/true_threat_tracking.tscn`

### Concepto

Torreta estática que rota continuamente para apuntar al jugador. Solo dispara cuando está correctamente alineada.

### Parámetros Exportables

```gdscript
@export_group("Shooting")
@export var shoot_interval: float = 2.5      # Tiempo mínimo entre disparos
@export var projectile_speed: float = 200.0   # Velocidad del proyectil
@export var projectile_damage: int = 1        # Daño por proyectil

@export_group("Tracking")
@export var tracking_speed: float = 90.0      # Grados/segundo de rotación
@export var aim_threshold: float = 10.0       # Margen de error (grados)
```

### Mecánica de Rotación

1. **Cálculo del ángulo objetivo:**
   ```gdscript
   var direction_to_player = (player_ref.global_position - global_position).normalized()
   target_angle = direction_to_player.angle()
   ```

2. **Rotación gradual:**
   ```gdscript
   var angle_diff = _angle_difference(current_rotation, target_angle)

   if abs(angle_diff) > deg_to_rad(aim_threshold):
       is_aimed = false
       var rotation_step = deg_to_rad(tracking_speed) * delta
       current_rotation += sign(angle_diff) * min(rotation_step, abs(angle_diff))
   else:
       is_aimed = true
       current_rotation = target_angle
   ```

3. **Condición de disparo:**
   - Solo dispara si `is_aimed == true`
   - Requiere que `shoot_timer` haya completado su ciclo
   - Jugador debe estar en rango (limitado por velocidad del proyectil)

### Visual Feedback

- **Laser sight:** Line2D roja que muestra dirección actual
- **Color:**
  - Enmascarado: Gris (0.5, 0.5, 0.5, 0.8)
  - Revelado: Rojo brillante (0.8, 0.2, 0.2, 1.0)
  - Apuntando: Laser sight visible

### Uso en Niveles

**Posicionamiento:**
- Plataformas elevadas para mayor cobertura
- Esquinas para crear encrucijadas peligrosas
- Boss rooms en conjunto con otros tipos

**Counters:**
- Moverse constantemente para evitar que se alinee
- Usar plataformas y paredes como cover
- Revelar cuando está rotando (no alineada)

---

## ⚡ Laser Turret

**Archivo:** `scripts/entities/true_threat_laser.gd`
**Escena:** `scenes/characters/entities/true_threat_laser.tscn`

### Concepto

Torreta que dispara un láser continuo después de un telegraph visible. El láser rastrea al jugador durante el telegraph pero se congela 0.6s antes de disparar.

### Parámetros Exportables

```gdscript
@export_group("Laser")
@export var laser_interval: float = 4.0       # Tiempo entre ciclos de disparo
@export var telegraph_time: float = 2.0       # Duración del telegraph (warning)
@export var freeze_time: float = 0.6          # Tiempo de congelación antes de disparar
@export var laser_duration: float = 0.8       # Duración del láser activo
@export var laser_damage_rate: float = 0.2    # Intervalo entre ticks de daño
@export var laser_damage: int = 1             # Daño por tick
@export var laser_length: float = 800.0       # Alcance del láser

@export_group("Visual")
@export var telegraph_color: Color = Color(1.0, 0.5, 0.0, 0.3)  # Naranja
@export var laser_color: Color = Color(1.0, 0.1, 0.1, 0.9)      # Rojo
```

### Estados y Transiciones

```
IDLE → TELEGRAPHING → FIRING → IDLE
  ↑                              ↓
  └──────── laser_interval ──────┘
```

#### 1. IDLE
- Rota libremente siguiendo al jugador
- `is_angle_locked = false`
- Espera `laser_interval` antes de iniciar telegraph

#### 2. TELEGRAPHING
- **Fase de tracking (1.4s):**
  - Telegraph line visible (naranja pulsante)
  - Continúa rastreando al jugador
  - `is_angle_locked = false`

- **Fase de freeze (0.6s):**
  - Telegraph line se congela en posición actual
  - `is_angle_locked = true`
  - `locked_angle` = dirección actual
  - SFX de advertencia más agudo

#### 3. FIRING
- Láser visible (rojo brillante)
- Area2D activa para detección de colisión
- Aplica daño cada `laser_damage_rate` (0.2s)
- Duración total: `laser_duration` (0.8s)
- Ángulo fijo = `locked_angle`

### Mecánica de Freeze

**Timeline detallada:**

```
0.0s ────────────── 1.4s ─────── 2.0s ────── 2.8s
 ↓                   ↓            ↓           ↓
IDLE              FREEZE      FIRE START   FIRE END
 │                   │            │           │
 └─ Tracking ────────┴─ Locked ──┴─ Laser ───┴─→ IDLE
    (1.4s)            (0.6s)       (0.8s)

Telegraph visible: ├──────────────────────┤ (2.0s)
Laser visible:                      ├─────┤ (0.8s)
```

**Implementación:**

```gdscript
func _start_telegraph() -> void:
    current_state = State.TELEGRAPHING
    is_angle_locked = false

    # Iniciar timers
    freeze_timer.start()      # 1.4s → _freeze_angle()
    telegraph_timer.start()   # 2.0s → _fire_laser()

func _freeze_angle() -> void:
    # Congelar dirección actual
    locked_angle = calculate_player_angle()
    is_angle_locked = true

    # SFX de advertencia
    AudioManager.play_sfx("laser_charge", -3.0)

func _process(_delta: float) -> void:
    if not is_angle_locked:
        # Rastrear jugador
        angle = calculate_player_angle()
    else:
        # Usar ángulo congelado
        angle = locked_angle

    # Aplicar rotación a líneas y área
    telegraph_line.rotation = angle
    laser_line.rotation = angle
    laser_area.rotation = angle
```

### Sistema de Daño

**Detección:**
- Area2D rectangular (800 × 16 px)
- `collision_mask = 2` (solo Player layer)
- Solo activa durante FIRING

**Aplicación:**
```gdscript
func _apply_laser_damage() -> void:
    var bodies = laser_area.get_overlapping_bodies()
    for body in bodies:
        if body.is_in_group("player"):
            GameManager.change_health(-laser_damage)
            _flash_player(body)  # Visual feedback
```

**Rate de daño:**
- 1 daño cada 0.2s
- Máximo 4 daños por ciclo completo (0.8s ÷ 0.2s)
- Si el jugador permanece en el láser todo el tiempo: **-4 HP**

### Visual Feedback

**Telegraph:**
- Line2D naranja (20px width)
- Alpha oscila 0.2 ↔ 0.6 (cada 0.3s)
- Muestra dónde disparará el láser

**Laser:**
- Line2D rojo brillante (8px width)
- Sólido (alpha 0.9)
- Más delgado que telegraph para precisión

**Player hit:**
- Flash rojo en sprite del jugador (0.1s)
- Modulate: (1.5, 0.5, 0.5, 1.0)

### Audio

| Evento | Sound | Volume | Momento |
|--------|-------|--------|---------|
| Telegraph start | `laser_charge` | -5.0 dB | Inicio de TELEGRAPHING |
| Freeze | `laser_charge` | -3.0 dB | Al congelar ángulo (0.6s antes) |
| Fire | `laser_fire` | 0.0 dB | Inicio de FIRING |

### Uso en Niveles

**Posicionamiento:**
- Pasillos horizontales (maximiza alcance)
- Plataformas laterales apuntando al path principal
- Boss rooms como control de zona

**Counters:**
- Observar telegraph (línea naranja)
- Esperar el SFX de freeze
- Moverse perpendicular a la línea durante los 0.6s finales
- Usar plataformas para romper line-of-sight

**Dificultad:**
- 1 turret: Esquivable con timing
- 2+ turrets: Requiere planificación de movimiento
- Con Tracking turrets: Fuerza decisiones de prioridad

---

## 🛡️ Shield Turret

**Archivo:** `scripts/entities/true_threat_shield.gd`
**Escena:** `scenes/characters/entities/true_threat_shield.tscn`

### Concepto

Torreta protegida por un escudo que requiere **2 revelaciones** para ser destruida. Primera revelación rompe el escudo y activa la torreta; segunda revelación la destruye.

### Parámetros Exportables

```gdscript
@export_group("Shooting")
@export var shoot_interval: float = 2.0       # Cooldown entre disparos
@export var projectile_speed: float = 150.0   # Velocidad del proyectil
@export var projectile_damage: int = 2        # Daño (mayor que normal)

@export_group("Shield")
@export var shield_health: int = 1            # Reservado para futuro
@export var shield_color: Color = Color(0.2, 0.6, 1.0, 0.6)  # Azul

# Sistema de truth counting
@export var truth_count: int = 2              # Verdades que proporciona
```

### Estados y Fases

#### Fase 1: Escudo Activo (Enmascarado)

**Estado inicial:**
```gdscript
shield_active = true
is_revealed = false
shoot_timer.paused = true
```

**Visual:**
- Sprite principal: Gris (0.5, 0.5, 0.5, 0.8)
- Shield sprite: Azul pulsante (escala 1.4 ↔ 1.5)
- Rotación constante del escudo: 0.5 rad/s

**Comportamiento:**
- No dispara
- Invulnerable (escudo absorbe revelación)
- Parece estatua inofensiva

#### Fase 2: Escudo Roto (Primera Revelación)

**Transición:**
```gdscript
func _on_veil_torn() -> void:
    if shield_active:
        _break_shield()
```

**_break_shield() hace:**
1. `shield_active = false`
2. Oculta shield sprite con animación (fade + scale)
3. Cambia color a púrpura (0.6, 0.2, 0.8, 1.0)
4. `is_revealed = true`
5. **Resetea VeilComponent:** `veil_component.is_revealed = false`
6. Inicia `shoot_timer`
7. SFX: "shield_break"

**Visual:**
- Sprite púrpura (vulnerable)
- Shield desaparece con animación (0.5s)
- Dispara proyectiles predictivos

**Comportamiento:**
- Dispara cada 2.0s
- Predicción de movimiento del jugador
- Proyectiles más rápidos (150 vs 120) y potentes (2 HP vs 1 HP)

#### Fase 3: Destrucción (Segunda Revelación)

**Transición:**
```gdscript
func _on_veil_torn() -> void:
    if not shield_active:
        _destroy_turret()
```

**_destroy_turret() hace:**
1. Detiene `shoot_timer`
2. Animación de destrucción (fade + shrink + spin)
3. SFX: "enemy_destroyed"
4. `queue_free()` después de animación

**Animación:**
```gdscript
var tween = create_tween()
tween.set_parallel(true)
tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.5)
tween.tween_property(sprite, "rotation", PI * 2, 0.5)
```

### Sistema Truth Count

**Problema resuelto:**
- Antes: LevelManager contaba 1 verdad por shield
- Después: LevelManager detecta `truth_count = 2`

**Implementación:**
```gdscript
// En true_threat_shield.gd
@export var truth_count: int = 2

// En level_manager.gd
for node in get_tree().get_nodes_in_group("entities"):
    if node.has_node("VeilComponent"):
        if "truth_count" in node:
            total_truths += node.truth_count  // Shield = 2
        else:
            total_truths += 1  // Normal = 1
```

**Flujo de conteo:**
1. Primera revelación: VeilComponent cuenta 1 verdad
2. VeilComponent se resetea: `is_revealed = false`
3. Segunda revelación: VeilComponent cuenta 1 verdad más
4. Total: 2 verdades (correcto)

### Reset del VeilComponent

**Crítico para funcionamiento:**

```gdscript
func _break_shield() -> void:
    # ... romper escudo ...

    # IMPORTANTE: Resetear para segunda revelación
    if veil_component:
        veil_component.is_revealed = false
```

**Sin esto:**
- VeilComponent quedaría marcado como revelado
- No permitiría segunda interacción con E
- Torreta quedaría indestructible

### Mecánica de Predicción

```gdscript
func _predict_player_position() -> Vector2:
    var player_pos = player_ref.global_position
    var player_velocity = Vector2.ZERO

    if player_ref is CharacterBody2D:
        player_velocity = player_ref.velocity

    var distance = global_position.distance_to(player_pos)
    var time_to_hit = distance / projectile_speed
    var predicted_position = player_pos + player_velocity * time_to_hit

    return predicted_position
```

**Efectividad:**
- Muy preciso si el jugador mantiene dirección
- Falla si el jugador cambia dirección bruscamente
- Más peligroso que torretas normales

### Audio

| Evento | Sound | Volume | Momento |
|--------|-------|--------|---------|
| Shield break | `shield_break` | -3.0 dB | Primera revelación |
| Shoot | `projectile_shoot` | -8.0 dB | Cada disparo |
| Destroyed | `enemy_destroyed` | -3.0 dB | Segunda revelación |

### Uso en Niveles

**Posicionamiento:**
- Boss rooms (1-2 como tanques)
- Centros de arenas (obliga a revelar primero)
- Combinado con Laser/Tracking para presión múltiple

**Counters:**
- **Fase 1:** Revelar escudo consume 1 revelación
- **Fase 2:** Esquivar proyectiles predictivos cambiando dirección
- **Fase 2:** Revelar rápidamente antes de que dispare mucho
- Priorizar shields en boss fights (2 revelaciones = inversión)

**Estrategia:**
- No revelar shield si no puedes completar segunda revelación
- En grupos, revelar shield primero (se vuelve activo = más peligroso)
- Usar como cover temporal mientras está enmascarado

---

## 🎮 Comparativa de Torretas

| Feature | Tracking | Laser | Shield |
|---------|----------|-------|--------|
| **Revelaciones** | 1 | 1 | 2 |
| **Truth Count** | 1 | 1 | 2 |
| **Daño/hit** | 1 HP | 1 HP | 2 HP |
| **Rate** | 2.5s | 0.2s (durante láser) | 2.0s |
| **Max DPS** | 0.4 HP/s | 5 HP/s (burst) | 1 HP/s |
| **Alcance** | Limitado | 800px | Limitado |
| **Counter** | Moverse | Timing + posición | 2 revelaciones |
| **Dificultad** | Media | Alta | Media-Alta |
| **Uso ideal** | Control de zona | Pasillos | Boss, tanque |

---

## 📊 Balance Guidelines

### Composición de Encounters

**Solo Tracking (x2-3):**
- Cobertura de 360°
- Requiere movimiento constante
- Dificultad: Media

**Solo Laser (x1-2):**
- Telegraph staggering (no sincronizado)
- Timing crítico
- Dificultad: Alta

**Solo Shield (x1-2):**
- Inversión de revelaciones
- Fase 2 peligrosa
- Dificultad: Media

**Mixto (recomendado):**
- 1 Shield (centro/back)
- 2 Tracking (flancos)
- 1 Laser (lateral)
- **Total:** 4 entidades, 5 verdades
- Dificultad: Muy Alta (boss room)

### Timing Considerations

**Reveal System cooldown:** 0.5s
**Laser telegraph + freeze:** 2.0s
**Shield fase 2 activa:** Permanente hasta segunda revelación

**Secuencia óptima (boss room):**
1. Revelar Shield primero (0s)
2. Esquivar laser telegraph (0-2s)
3. Revelar Tracking más cercano (2.5s)
4. Completar Shield mientras torretas recargan (4s)
5. Revelar Laser mientras está en IDLE (6s)
6. Limpiar Tracking restante (8s+)

---

## 🔧 Parámetros Ajustables

### Para aumentar dificultad:

**Tracking:**
- `tracking_speed`: 90° → 120°/s (más rápido)
- `aim_threshold`: 10° → 5° (más preciso)
- `projectile_speed`: 200 → 250

**Laser:**
- `freeze_time`: 0.6s → 0.4s (menos reacción)
- `laser_duration`: 0.8s → 1.2s (más exposición)
- `laser_damage`: 1 → 2 HP/tick

**Shield:**
- `projectile_damage`: 2 → 3 HP
- `shoot_interval`: 2.0s → 1.5s (más spam)
- Fase 2: Activar inmediatamente sin resetear VeilComponent (indestructible hasta reinicio)

### Para reducir dificultad:

**Tracking:**
- `tracking_speed`: 90° → 60°/s
- `shoot_interval`: 2.5s → 3.5s

**Laser:**
- `telegraph_time`: 2.0s → 2.5s
- `freeze_time`: 0.6s → 0.8s
- `laser_damage`: 1 → 0 (solo knockback)

**Shield:**
- `projectile_damage`: 2 → 1 HP
- `projectile_speed`: 150 → 100 (más lento)

---

## 📝 Notas de Implementación

### Bugs Corregidos

1. **VeilComponent double-call** (2026-01-31)
   - Síntoma: Shield destruido en primera revelación
   - Causa: `veil_torn.emit()` + llamada directa
   - Fix: Eliminar llamada directa, solo usar signals

2. **Laser tracking durante telegraph** (2026-01-31)
   - Síntoma: Imposible esquivar láseres
   - Causa: Ángulo actualizado hasta el frame del disparo
   - Fix: Sistema de freeze con `is_angle_locked`

3. **Truth count incorrecto** (2026-01-31)
   - Síntoma: Game Over muestra "/ 11" en lugar de "/ 13"
   - Causa: Shield contado como 1 verdad en lugar de 2
   - Fix: Sistema `truth_count` en LevelManager

### Limitaciones Conocidas

- Shield no tiene animación de sprite real (solo modulación de color)
- Laser no tiene particle effects en el beam
- Tracking no tiene sonido de rotación (solo disparo)
- Todas usan placeholders visuales (sprites de color sólido)

### Extensiones Futuras

**Shield variants:**
- Multi-layer shield (3+ revelaciones)
- Regenerating shield (cada X segundos)
- Shield que protege entidades cercanas (área de efecto)

**Laser variants:**
- Sweeping laser (rota durante disparo)
- Multi-beam (3 láseres en abanico)
- Laser reflejado por espejos (puzzle element)

**Tracking variants:**
- Burst fire (3 proyectiles rápidos)
- Homing projectiles
- Sniper (largo wind-up, 1-shot kill)

---

**Última actualización:** 2026-01-31
**Autor:** Sistema de desarrollo VEIL
**Versión del documento:** 1.0
