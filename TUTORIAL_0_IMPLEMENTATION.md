# Tutorial 0: "Innocence" - Documentación de Implementación

**Fecha de inicio:** 2026-02-03
**Estado:** ✅ **COMPLETADO Y FUNCIONAL**
**Última actualización:** 2026-02-05

---

## 📖 Contexto Narrativo

### Concepto del Tutorial 0

**"Innocence"** - La muerte inevitable que desbloquea poderes

**Flujo narrativo:**
1. Jugador spawns sin habilidades (solo movimiento)
2. Ve enemigos "amenazantes" lejos en plataformas altas (inalcanzables)
3. Se acerca al False Friend → **Reveal automático** (no controlado)
4. False Friend ataca y daña al jugador (HUD aparece por primera vez)
5. False Friend **persigue inevitablemente** (más rápido que jugador)
6. False Friend **mata al jugador** (muerte scripted, no evitable)
7. **Transición cinemática:**
   - Fade to black
   - Texto: "Deceived."
   - Texto: "But you won't be fooled again."
   - **Grito primal** (referencia "Won't Get Fooled Again" - The Who)
   - Screen flash blanco
   - Fade to white
8. **Tutorial 1 carga** con reveal desbloqueado (renacimiento)

**Mensaje:** "Moriste víctima → Renaces como cazadora"

---

## ✅ Estado Actual - COMPLETADO

### Implementación Tutorial 0

```
Scripts:            ████████████████████ 100% ✅
Escenas:            ████████████████████ 100% ✅
Testing:            ████████████████████ 100% ✅
Transición T0→T1:   ████████████████████ 100% ✅
```

### Bugs Corregidos (2026-02-05)

1. ✅ **FalseEnemies visibles** - Agregado "cartelito" FALSE sobre cada enemigo
2. ✅ **Jugador puede morir** - `CATCH_RANGE` aumentado a 80px, `CHASE_SPEED` a 280
3. ✅ **Transición funciona** - Eliminado `get_tree().paused` que causaba freeze
4. ✅ **AudioManager** - Agregado método `play_music_immediate()`
5. ✅ **Texto centrado** - Arreglado `anchors_preset` en `_show_centered_text()`
6. ✅ **Goal eliminado** - Tutorial 0 no es "ganable", solo morir para avanzar

---

## 📁 Archivos Implementados

### Scripts Completados (100%)

#### 1. `scripts/autoloads/game_manager.gd`

**Variables agregadas:**
```gdscript
var tutorial_0_active: bool = false
var tutorial_0_one_life: bool = true
var reveal_unlocked: bool = false
var dash_unlocked: bool = false
```

**Funciones agregadas:**
```gdscript
func start_tutorial_0()
func start_tutorial_1()
func player_died_tutorial_0()
func _tutorial_0_death_sequence()
func _show_centered_text(text: String)
func _hide_centered_text()
```

**Modificaciones clave:**
- `player_died()` - Ahora detecta Tutorial 0 y llama a `player_died_tutorial_0()`
- **IMPORTANTE:** Eliminado `get_tree().paused = true` que causaba freeze de tweens/timers

---

#### 2. `scripts/autoloads/audio_manager.gd`

**Función agregada:**
```gdscript
func play_music_immediate(music_name: String) -> void
    # Reproduce música sin fade (para transiciones rápidas)
```

---

#### 3. `scripts/autoloads/scene_transition.gd`

**Funciones agregadas:**
```gdscript
func fade_to_black(duration: float = 0.5) -> void
func fade_to_white(duration: float = 0.5) -> void
```

---

#### 4. `scripts/core/player_controller.gd`

**Variables agregadas:**
```gdscript
var is_frozen: bool = false
var freeze_timer: float = 0.0
```

**Funciones agregadas:**
```gdscript
func freeze(duration: float)  # Congela jugador X segundos
func scripted_death()         # Muerte especial Tutorial 0
```

**Modificaciones:**
- `_physics_process()` - Maneja freeze timer (líneas 134-149)
- Cuando `is_dead = true`, retorna temprano (no se mueve)

---

#### 5. `scripts/tutorial/tutorial_0_false_friend.gd` ✨

**Archivo:** ~316 líneas

**Constantes clave (ACTUALIZADAS):**
```gdscript
const CHASE_SPEED: float = 280.0  # Más rápido que jugador (230)
const JUMP_FORCE: float = -450.0  # Salta más alto
const CATCH_RANGE: float = 80.0   # Aumentado para asegurar catch
const GRAVITY: float = 980.0
```

**Exports:**
```gdscript
@export var auto_reveal_range: float = 48.0
@export var auto_reveal_enabled: bool = true
```

**Trigger System (Area2D volumétrico):**
- RectangleShape2D de 20×200px
- Posicionado 200px adelante del personaje
- Detecta cuando jugador CRUZA la línea (no por proximidad)

**Secuencia de reveal automático:**
```
t=0.0s:  Jugador entra en trigger
         → Freeze player (2.5s)
         → Música corta

t=0.5s:  Máscara crujiendo (shake sprite)
         → SFX: mask_cracking

t=1.0s:  Máscara rompe
         → SFX: glass_shatter
         → Partículas

t=1.5s:  Transformación completa
         → SFX: false_friend_reveal
         → Screen shake (0.8)
         → Flash rojo (0.3s)
         → Sprite cambia a rojo

t=2.0s:  Ataque (lunge)
         → 1 HP de daño
         → HUD aparece (4/5 HP)

t=2.5s:  Jugador recupera control
         → Música panic
         → Persecución inicia
```

**Métodos principales:**
- `_setup_trigger_area()` - Crea Area2D volumétrico
- `_on_body_entered()` - Detecta jugador cruzando trigger
- `_cinematic_reveal_sequence()` - Cinemática completa
- `_start_chase()` - Inicia persecución
- `_chase_behavior()` - Persigue al jugador (con debug)
- `_catch_player()` - Mata al jugador (con debug)

---

#### 6. `scripts/tutorial/tutorial_0_manager.gd` ✨

**Archivo:** ~105 líneas

**Responsabilidades:**
- Inicializa Tutorial 0 (`GameManager.start_tutorial_0()`)
- Oculta HUD al inicio
- Configura cámara para seguir al jugador
- Maneja música ambiental (silencio)
- Muestra HUD cuando False Friend ataca
- Actualiza HUD con HP y verdades

---

#### 7. `scenes/levels/tutorial_1.gd` ✨

**Archivo:** ~64 líneas

**Responsabilidades:**
- Inicializa Tutorial 1 (`GameManager.start_tutorial_1()`)
- Spawnea jugador si no existe
- Muestra estado del jugador (HP, habilidades desbloqueadas)
- Label de bienvenida: "¡Revelación Desbloqueada!"

**Corrección:** Eliminadas referencias a `veil_shards_collected` y `veil_shards_needed` que no existen en GameManager.

---

### Escenas Creadas

#### 1. `scenes/levels/tutorial_0.tscn` ✅

**Estado:** COMPLETADO Y FUNCIONAL

**Estructura:**
```
Tutorial0 (Node2D) [script: tutorial_0_manager.gd]
├── Environment
│   ├── Floor (StaticBody2D) - 1200×48px
│   ├── HighPlatform1 (StaticBody2D) - x=300, y=110
│   └── HighPlatform2 (StaticBody2D) - x=450, y=110
├── Entities
│   ├── FalseEnemy1 (instance) - x=300, y=70
│   ├── FalseEnemy2 (instance) - x=450, y=70
│   ├── FalseFriendOptional - x=460 (no auto-reveal)
│   └── FalseFriendTrigger - x=659 (auto-reveal enabled)
├── Player (instance) - x=125, y=300
└── UI (CanvasLayer)
    └── HUD (visible=false)
        ├── HPLabel
        └── TruthsLabel
```

**Posiciones clave:**
- Player spawn: `(125, 300)`
- False Enemies: `(300, 70)` y `(450, 70)` - en plataformas altas
- FalseFriendTrigger: `(659, 305)` - **ESTE causa el reveal**
- **Goal eliminado** - Tutorial 0 no es "ganable"

**Cambios importantes:**
- ❌ Goal eliminado (jugador debe morir para avanzar)
- ✅ FalseEnemy tiene "cartelito" FALSE visible
- ✅ Trigger movido a X=659 (más temprano)

---

#### 2. `scenes/characters/entities/false_enemy.tscn` ✅

**Estado:** COMPLETADO

**Estructura:**
```
FalseEnemy (CharacterBody2D)
├── CollisionShape2D (RectangleShape2D 48×60)
├── Sprite2D (PLACEHOLDER_player.png)
├── VisualLabel (ColorRect rosa 40×25)
│   └── Label (texto "FALSE")
├── AnimationPlayer
├── VeilComponent
└── RangeIndicator
```

**Cambios importantes:**
- ✅ Agregado "cartelito" VisualLabel con texto "FALSE"
- ✅ UID corregido para placeholder sprite

---

#### 3. `scenes/levels/tutorial_1.tscn` ✅

**Estado:** COMPLETADO

**Estructura:**
```
Tutorial1 (Node2D) [script: tutorial_1.gd]
├── Environment
│   └── Floor (StaticBody2D)
├── PlayerSpawn (Marker2D) - x=125, y=300
├── Camera2D (zoom=0.75)
└── UI (CanvasLayer)
    └── WelcomeLabel ("¡Revelación Desbloqueada!")
```

---

## 🎮 Configuración Actual del Proyecto

### Autoloads Configurados

```
AudioManager    → scripts/autoloads/audio_manager.gd    ✅
GameManager     → scripts/autoloads/game_manager.gd     ✅
SceneTransition → scripts/autoloads/scene_transition.gd ✅
```

### Input Actions Requeridas

```
move_left      - Tecla A / Flecha Izquierda
move_right     - Tecla D / Flecha Derecha
jump           - Espacio / W
dash           - Shift (no disponible en T0)
reveal         - E (no disponible en T0)
ui_cancel      - ESC
```

---

## 🧪 Testing - FLUJO COMPLETO

### Test de Tutorial 0

**Escena:** `tutorial_0.tscn`

**Checklist validado:**

```
[✅] Player spawns correctamente en (125, 300)
[✅] HUD oculto al inicio
[✅] False Enemies visibles con "cartelito" FALSE
[✅] False Friend trigger (x=659):
    [✅] Reveal automático al cruzar trigger
    [✅] Player freeze 2.5s
    [✅] Transformación visual (rojo)
    [✅] Daño 1 HP
    [✅] HUD aparece (4/5 HP)
[✅] Persecución:
    [✅] False Friend más rápido (280) que jugador (230)
    [✅] No puedes usar reveal (bloqueado)
    [✅] Te alcanza eventualmente
[✅] Muerte:
    [✅] Scripted (no game over)
    [✅] Fade to black (2s)
    [✅] Texto "Deceived." centrado
    [✅] Texto "But you won't be fooled again." centrado
    [✅] Transición a Tutorial 1
[✅] Tutorial 1 carga:
    [✅] Jugador spawnea en posición correcta
    [✅] Reveal desbloqueado
    [✅] Texto de bienvenida visible
```

---

## 📝 Assets Requeridos

### Audio SFX (Placeholders OK)

```
assets/audio/sfx/
├── mask_cracking.wav/ogg    # Máscara crujiendo
├── glass_shatter.wav/ogg    # Máscara rompiéndose
├── false_friend_reveal.wav/ogg  # Rugido de transformación
└── awakening_scream.wav/ogg # Grito "Won't Get Fooled Again"
```

### Música

```
assets/audio/music/
├── tutorial_panic.ogg         # Persecución
└── tutorial_1_awakening.ogg   # Tutorial 1
```

**Nota:** Si no existen, el juego funcionará pero sin audio (warnings en consola).

---

## 🐛 Errores Conocidos y Soluciones

### Error 1: "Invalid call 'play_music_immediate'"

**Solución:** Ya agregado a `audio_manager.gd` (2026-02-05)

---

### Error 2: "Texto en esquina superior izquierda"

**Solución:** Ya arreglado usando `anchors_preset` directamente (2026-02-05)

---

### Error 3: "Juego se congela durante transición"

**Causa:** `get_tree().paused = true` detiene tweens/timers

**Solución:** Eliminado `get_tree().paused` de `player_died_tutorial_0()` (2026-02-05)

---

### Error 4: "Invalid access 'veil_shards_collected'"

**Causa:** `tutorial_1.gd` usaba propiedades inexistentes

**Solución:** Actualizado para usar `max_hp` y eliminar referencias a shards (2026-02-05)

---

## 🎯 Próximos Pasos - Tutorial 1

### Para la próxima sesión

**Tutorial 1 - "Awakening" (El renacimiento):**

1. **Objetivo:** Enseñar la mecánica de Reveal
   - Jugador puede usar Reveal (E) por primera vez
   - Crear enemigos que deban ser revelados
   - Enseñar que revelar revela la verdadera forma

2. **Elementos a implementar:**
   - [ ] FalseEnemies que pueden ser revelados
   - [ ] Tutorial de "presiona E para revelar"
   - [ ] Primer "tear the veil" del jugador
   - [ ] FalseFriends que huyen cuando son revelados
   - [ ] Meta del nivel (alcanzar Goal)

3. **Habilidades:**
   - ✅ Reveal: Desbloqueado
   - ❌ Dash: Bloqueado (se desbloquea al FINAL de Tutorial 1)

4. **Progresión narrativa:**
   - Texto: "Ya no eres víctima. Ahora eres la Cazadora."
   - Primer kill de un FalseEnemy revelado
   - El jugador siente poder por primera vez

---

## 📊 Estado del Proyecto

```
Tutorial 0:         ████████████████████ 100% ✅ COMPLETADO
Tutorial 1:         ░░░░░░░░░░░░░░░░░░░░   0% 🔄 PRÓXIMO
Nivel 1:            ░░░░░░░░░░░░░░░░░░░░   0% ❌
Nivel 2:            ░░░░░░░░░░░░░░░░░░░░   0% ❌
Nivel 3:            ░░░░░░░░░░░░░░░░░░░░   0% ❌
```

---

## 🗺️ Mapa de Archivos Finales

```
/home/ips/GGJ26/
├── scripts/
│   ├── autoloads/
│   │   ├── audio_manager.gd            [MODIFICADO] ✏️
│   │   ├── game_manager.gd             [MODIFICADO] ✏️
│   │   └── scene_transition.gd         [MODIFICADO] ✏️
│   ├── core/
│   │   └── player_controller.gd        [MODIFICADO] ✏️
│   └── tutorial/
│       ├── tutorial_0_manager.gd       [COMPLETADO] ✅
│       ├── tutorial_0_false_friend.gd  [COMPLETADO] ✅
│       └── tutorial_1.gd               [COMPLETADO] ✅
│
├── scenes/
│   ├── characters/
│   │   └── entities/
│   │       └── false_enemy.tscn        [MODIFICADO] ✏️
│   └── levels/
│       ├── tutorial_0.tscn             [COMPLETADO] ✅
│       ├── tutorial_0_minimal.tscn     [COMPLETADO] ✅
│       └── tutorial_1.tscn             [COMPLETADO] ✅
│
└── TUTORIAL_0_IMPLEMENTATION.md        [ESTE ARCHIVO] 📄
```

---

## ✅ Checklist para Tutorial 1

**Setup inicial:**
```
[ ] Revisar diseño narrativo de Tutorial 1
[ ] Definir objetivo del nivel (enseñar Reveal)
[ ] Listar enemigos y puzzles a implementar
```

**Implementación:**
```
[ ] Crear diseño del nivel Tutorial 1
[ ] Colocar FalseEnemies revelables
[ ] Agregar tutorial hints (presiona E)
[ ] Implementar meta del nivel
[ ] Desbloquear Dash al final del nivel
```

**Testing:**
```
[ ] Verificar que Reveal funciona correctamente
[ ] Verificar que enemigos se revelan
[ ] Verificar que jugador puede ganar Tutorial 1
[ ] Transición a Nivel 1
```

---

## 💡 Notas Importantes

1. **Tutorial 0 está 100% funcional** - Se puede probar de principio a fin
2. **La transición a Tutorial 1 funciona** - El jugador "renace" con poderes
3. **Audio placeholders aceptables** - El juego funciona sin audio
4. **Placeholders visuales OK** - "Cartelito" FALSE funciona bien
5. **Debug messages presentes** - Fácil de identificar problemas

---

**Fin de la documentación de Tutorial 0. Tutorial 0 COMPLETADO! 🎮🐺✅**
