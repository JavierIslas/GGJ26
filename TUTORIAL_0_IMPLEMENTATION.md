# Tutorial 0: "Innocence" - Documentación de Implementación

**Fecha de inicio:** 2026-02-03
**Estado:** Scripts completados, escenas base creadas, requiere testing en Godot
**Última actualización:** 2026-02-03

---

## 📖 Contexto Narrativo

### Concepto del Tutorial 0

**"Innocence"** - La muerte inevitable que desbloquea poderes

**Flujo narrativo:**
1. Jugador spawns sin habilidades (solo movimiento)
2. Ve enemigos "amenazantes" lejos (inalcanzables)
3. Ve aliados "amigables" cerca (parecen seguros)
4. Se acerca a un False Friend → **Reveal automático** (no controlado)
5. False Friend ataca y daña al jugador (HUD aparece por primera vez)
6. False Friend **persigue inevitablemente** (más rápido que jugador)
7. False Friend **mata al jugador** (muerte scripted, no evitable)
8. **Transición cinemática:**
   - Fade to black
   - Texto: "Deceived."
   - Texto: "But you won't be fooled again."
   - **Grito primal** (referencia "Won't Get Fooled Again" - The Who)
   - Fade to white
9. **Tutorial 1 carga** con reveal desbloqueado (renacimiento)

**Mensaje:** "Moriste víctima → Renaces como cazadora"

---

## ✅ Archivos Implementados

### Scripts Completados (100%)

#### 1. `scripts/autoloads/game_manager.gd`

**Cambios realizados:**

```gdscript
// AGREGADO - Variables:
var tutorial_0_active: bool = false
var tutorial_0_one_life: bool = true
var reveal_unlocked: bool = false
var dash_unlocked: bool = false

// AGREGADO - Funciones:
func start_tutorial_0()
func start_tutorial_1()
func player_died_tutorial_0()
func _tutorial_0_death_sequence()
func _show_centered_text(text: String)
func _hide_centered_text()

// MODIFICADO - Funciones:
func player_died()  # Ahora detecta Tutorial 0
func change_health()  # Removido el ignore de daño en tutorial
```

**Responsabilidades:**
- Controla flags de Tutorial 0
- Maneja muerte especial (no game over)
- Ejecuta secuencia cinemática de transición
- Desbloquea habilidades progresivamente

---

#### 2. `scripts/core/player_controller.gd`

**Cambios realizados:**

```gdscript
// AGREGADO - Variables:
var is_frozen: bool = false
var freeze_timer: float = 0.0

// AGREGADO - Funciones:
func freeze(duration: float)  # Congela jugador X segundos
func scripted_death()  # Muerte especial Tutorial 0

// MODIFICADO - Funciones:
func _physics_process(delta)  # Maneja freeze timer
```

**Responsabilidades:**
- Permite congelar al jugador durante cinemáticas
- Muerte scripted que NO activa game over normal
- Bloquea input mientras está frozen

**Líneas modificadas:**
- **Líneas 134-154:** `_physics_process()` con manejo de freeze
- **Líneas 929-959:** Métodos freeze() y scripted_death()

---

#### 3. `scripts/tutorial/tutorial_0_false_friend.gd` ✨ NUEVO

**Archivo completo:** 272 líneas

**Características principales:**

```gdscript
// Constantes clave:
const CHASE_SPEED = 180.0  # Más rápido que jugador (150)
const JUMP_FORCE = -450.0  # Salta más alto
const CATCH_RANGE = 32.0   # Distancia para matar

// Exports:
@export var auto_reveal_range: float = 48.0
@export var auto_reveal_enabled: bool = true

// Estados:
enum State { IDLE, CHASING }
```

**Secuencia de reveal automático (timing exacto):**

```
t=0.0s:  Jugador entra en rango (48px)
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
         → HUD aparece (HP 4/5)

t=2.5s:  Jugador recupera control
         → Música panic
         → Persecución inicia
```

**Métodos principales:**
- `_check_auto_reveal()` - Detecta proximidad
- `_trigger_auto_reveal()` - Inicia secuencia
- `_cinematic_reveal_sequence()` - Cinemática completa
- `_start_chase()` - Inicia persecución
- `_chase_behavior()` - Persigue al jugador
- `_catch_player()` - Mata al jugador

---

#### 4. `scripts/tutorial/tutorial_0_manager.gd` ✨ NUEVO

**Archivo completo:** 96 líneas

**Responsabilidades:**
- Inicializa Tutorial 0 (llama `GameManager.start_tutorial_0()`)
- Oculta HUD al inicio
- Configura cámara para seguir al jugador
- Maneja música ambiental (silencio)
- Muestra HUD cuando False Friend ataca
- Actualiza HUD con HP y verdades

**Métodos principales:**
- `_ready()` - Setup inicial
- `_setup_camera()` - Config de cámara
- `on_first_attack()` - Muestra HUD
- `_update_hud()` - Actualiza valores

---

### Escenas Creadas

#### 1. `scenes/levels/tutorial_0.tscn` (Completa)

**Estado:** ⚠️ Requiere ajustes en editor (referencias rotas)

**Estructura:**
```
Tutorial0 (Node2D) [script: tutorial_0_manager.gd]
├── Camera2D
├── Environment
│   ├── Floor (StaticBody2D)
│   ├── HighPlatform1 (StaticBody2D) - y=110
│   └── HighPlatform2 (StaticBody2D) - y=110
├── Entities
│   ├── FalseEnemy1 (instance) - x=300, y=70
│   ├── FalseEnemy2 (instance) - x=450, y=70
│   ├── FalseFriendOptional - x=550 (no auto-reveal)
│   └── FalseFriendTrigger - x=700 (auto-reveal enabled)
├── Player (instance) - x=125, y=300
├── Goal (instance) - x=1150, y=280
└── UI (CanvasLayer)
    └── HUD (visible=false)
        ├── HPLabel
        └── TruthsLabel
```

**Posiciones clave:**
- Player spawn: `(125, 300)`
- False Enemies: `(300, 70)` y `(450, 70)` - en plataformas altas
- False Friend trigger: `(700, 310)` - ESTE causa el reveal
- Goal: `(1150, 280)`

---

#### 2. `scenes/levels/tutorial_0_minimal.tscn` (Funcional)

**Estado:** ✅ Lista para testing básico

**Incluye:**
- Floor simple
- PlayerSpawn marker
- Camera2D configurada
- HUD oculto

**Requiere agregar manualmente:**
- Instancia de Player
- Instancia de False Friend con script

---

## 🔧 Configuración Necesaria en Godot

### Paso 1: Crear Autoloads (si no existen)

**Project > Project Settings > Autoload:**

```
AudioManager    → scripts/autoloads/audio_manager.gd    (Enabled)
GameManager     → scripts/autoloads/game_manager.gd     (Enabled)
SceneTransition → scripts/autoloads/scene_transition.gd (Enabled)
```

Si alguno no existe, crear placeholder:

```gdscript
# scripts/autoloads/audio_manager.gd (placeholder)
extends Node

func play_sfx(sfx_name: String, volume: float = 0.0) -> void:
    print("AudioManager: play_sfx(%s)" % sfx_name)

func stop_music() -> void:
    print("AudioManager: stop_music()")

func play_music(track: String, combat_track: String = "", volume: float = 1.0) -> void:
    print("AudioManager: play_music(%s)" % track)

func play_music_immediate(track: String) -> void:
    print("AudioManager: play_music_immediate(%s)" % track)
```

```gdscript
# scripts/autoloads/scene_transition.gd (placeholder)
extends CanvasLayer

signal fade_finished

func change_scene(path: String) -> void:
    get_tree().change_scene_to_file(path)

func fade_to_black(duration: float) -> void:
    await get_tree().create_timer(duration).timeout
    fade_finished.emit()

func fade_to_white(duration: float) -> void:
    await get_tree().create_timer(duration).timeout
    fade_finished.emit()
```

---

### Paso 2: Ajustar tutorial_0.tscn

**Abrir:** `scenes/levels/tutorial_0.tscn`

#### Fix 1: Tutorial0Manager grupo

1. Seleccionar nodo raíz `Tutorial0`
2. Node tab (arriba derecha) > Groups
3. Add: `tutorial_0_manager`

#### Fix 2: False Friend Sprites (rotos)

**Para `FalseFriendOptional` y `FalseFriendTrigger`:**

1. Eliminar nodo `Sprite2D` existente (referencias rotas)
2. Add Child Node > Sprite2D:
   - Texture > New PlaceholderTexture2D
   - PlaceholderTexture2D > Size: `32x32`
   - Modulate: `Color(1, 1, 0, 1)` (amarillo)
3. Add Child Node > CollisionShape2D:
   - Shape > New RectangleShape2D
   - Size: `28x30`

#### Fix 3: Verificar instancias

- `FalseEnemy1/2`: Deben apuntar a `scenes/characters/false_enemy.tscn`
  - Si no existe, crear placeholder o usar otro enemigo
- `Player`: Debe apuntar a `scenes/characters/player.tscn`
- `Goal`: Debe apuntar a `scenes/level/level_goal.tscn`

---

### Paso 3: Crear Tutorial 1 (destino)

**Crear archivo:** `scenes/levels/tutorial_1.tscn`

**Mínimo necesario:**

```
Tutorial1 (Node2D)
├── Floor (StaticBody2D)
├── Player spawn
└── Texto: "Tutorial 1 - Reveal desbloqueado"
```

O simplemente crear escena vacía para evitar crash.

---

## 🧪 Testing

### Test Mínimo (Sin dependencias)

**Escena:** `tutorial_0_minimal.tscn`

**Setup rápido:**
1. Instanciar Player en `(125, 300)`
2. Crear CharacterBody2D en `(700, 310)`:
   - Attach script: `tutorial_0_false_friend.gd`
   - Add Sprite2D hijo (placeholder 32x32 amarillo)
   - Add CollisionShape2D (Rectangle 28x30)
3. Run Scene (F6)

**Comportamiento esperado:**
- Player puede moverse
- Al acercarse a False Friend → congela
- False Friend se transforma
- False Friend persigue
- False Friend mata → transición

---

### Test Completo

**Escena:** `tutorial_0.tscn` (después de fixes)

**Checklist:**

```
[ ] Player spawns correctamente
[ ] HUD oculto al inicio
[ ] False Enemies patrullan arriba (inalcanzables)
[ ] False Friend opcional no reacciona
[ ] False Friend trigger (x=700):
    [ ] Reveal automático a 48px
    [ ] Player freeze 2.5s
    [ ] Transformación visual
    [ ] Daño 1 HP
    [ ] HUD aparece (4/5 HP)
[ ] Persecución:
    [ ] False Friend más rápido que jugador
    [ ] No puedes usar reveal (bloqueado)
    [ ] Te alcanza eventualmente
[ ] Muerte:
    [ ] Scripted (no game over)
    [ ] Fade to black
    [ ] Textos aparecen
    [ ] Grito (si audio existe)
    [ ] Fade to white
    [ ] Tutorial 1 carga
```

---

## 📝 Assets Faltantes (Placeholders)

### Audio SFX

**Crear archivos vacíos o placeholders en:**

```
assets/audio/sfx/
├── mask_cracking.ogg       # Máscara crujiendo
├── glass_shatter.ogg       # Máscara rompiéndose
├── false_friend_reveal.ogg # Rugido de transformación
└── awakening_scream.ogg    # Grito "Won't Get Fooled Again"
```

**Placeholder rápido (silencio):**
- Usar Audacity: Generate > Silence (0.5s)
- Export as OGG

**O desactivar audio temporalmente:**

Comentar líneas en `tutorial_0_false_friend.gd`:
```gdscript
# Line 78: AudioManager.stop_music()
# Line 82: AudioManager.play_sfx("mask_cracking", -5.0)
# Line 87: AudioManager.play_sfx("glass_shatter", -3.0)
# Line 92: AudioManager.play_sfx("false_friend_reveal", 0.0)
# Line 129: AudioManager.play_music("tutorial_panic")
```

---

### Música

```
assets/audio/music/
├── tutorial_panic.ogg         # Persecución
└── tutorial_1_awakening.ogg   # Tutorial 1
```

**O comentar en scripts:**
- `tutorial_0_manager.gd` línea 54
- `tutorial_0_false_friend.gd` línea 129
- `game_manager.gd` línea 75

---

### Sprites (Opcionales)

Actualmente usa placeholders (ColorRect, PlaceholderTexture2D).

Para testing está bien. Para versión final:
- False Friend masked: Sprite amarillo/amigable
- False Friend revealed: Sprite rojo/monstruoso
- Animaciones de transformación

---

## 🐛 Errores Comunes y Soluciones

### Error 1: "Invalid get index 'has_method'"

**Causa:** Intentando llamar método en nodo null

**Solución:** Agregar verificaciones

```gdscript
# ANTES:
player.freeze(2.5)

# DESPUÉS:
if player and player.has_method("freeze"):
    player.freeze(2.5)
```

---

### Error 2: "Cannot call 'change_scene' on a freed object"

**Causa:** SceneTransition no existe como autoload

**Solución temporal:**

```gdscript
# En game_manager.gd línea ~75:
# REEMPLAZAR:
SceneTransition.change_scene("res://scenes/levels/tutorial_1.tscn")

# CON:
get_tree().change_scene_to_file("res://scenes/levels/tutorial_1.tscn")
```

---

### Error 3: "Attempt to call function 'play_sfx' in base 'null instance'"

**Causa:** AudioManager no existe

**Solución:** Crear autoload placeholder (ver arriba) O comentar llamadas

---

### Error 4: Player no se congela

**Verificar:**
1. `player_controller.gd` tiene métodos `freeze()` y manejo en `_physics_process()`
2. El script está guardado y recompilado
3. La instancia de Player en escena usa el script actualizado

**Debug:**
```gdscript
# En tutorial_0_false_friend.gd línea 73:
func _cinematic_reveal_sequence() -> void:
    print("=== CINEMATIC START ===")  # AGREGAR ESTO
    if player and player.has_method("freeze"):
        player.freeze(2.5)
        print("Player frozen!")  # AGREGAR ESTO
    else:
        print("ERROR: Player freeze not available!")  # AGREGAR ESTO
```

---

## 🎯 Próximos Pasos (Orden Sugerido)

### Sesión Inmediata (Esta sesión o próxima)

1. **Crear autoloads placeholders** (si no existen)
   - AudioManager
   - SceneTransition
   - Verificar GameManager

2. **Abrir `tutorial_0_minimal.tscn`**
   - Instanciar Player
   - Crear False Friend básico
   - **Run scene (F6)** → Verificar comportamiento

3. **Fix errores de runtime**
   - Revisar consola de Godot
   - Aplicar soluciones de "Errores Comunes"

4. **Testing básico**
   - Verificar freeze
   - Verificar persecución
   - Verificar muerte → transición

---

### Sesión de Refinamiento

5. **Ajustar `tutorial_0.tscn` completa**
   - Fix sprites de False Friends
   - Verificar instancias de enemigos
   - Agregar plataformas intermedias
   - Layout completo según diseño

6. **Crear Tutorial 1 básico**
   - Escena simple con suelo y spawn
   - Verificar que reveal funciona
   - Mensaje de "Reveal desbloqueado"

7. **Polish visual**
   - Partículas de transformación
   - Screen shake funcional
   - Flash de pantalla

---

### Sesión de Audio

8. **Crear/conseguir audio assets**
   - SFX básicos (Freesound.org)
   - Awakening scream (grabar o sample)
   - Música panic y awakening

9. **Integrar audio**
   - Descomentar líneas de audio
   - Testear sincronización
   - Ajustar volúmenes

---

### Sesión de Arte

10. **Sprites de False Friend**
    - Versión masked (amigable)
    - Versión revealed (monstruo)
    - Animación de transformación

11. **Sprites de Player**
    - Animación freeze/shocked
    - Animación muerte

---

## 📊 Estado del Proyecto

### Implementación Tutorial 0

```
Scripts:            ████████████████████ 100% ✅
Escenas (base):     ████████████████░░░░  80% ⚠️
Audio (placeholder):░░░░░░░░░░░░░░░░░░░░   0% ❌
Sprites (final):    ░░░░░░░░░░░░░░░░░░░░   0% ❌
Testing:            ░░░░░░░░░░░░░░░░░░░░   0% 🔄
```

### Dependencias

```
✅ GameManager actualizado
✅ Player Controller actualizado
⚠️ AudioManager (placeholder OK)
⚠️ SceneTransition (placeholder OK)
❌ Tutorial 1 (no existe aún)
❌ False Enemy scene (puede no existir)
❌ Level Goal scene (puede no existir)
```

---

## 🗺️ Mapa de Archivos Modificados

```
/home/ips/GGJ26/
├── scripts/
│   ├── autoloads/
│   │   └── game_manager.gd              [MODIFICADO] ✏️
│   ├── core/
│   │   └── player_controller.gd         [MODIFICADO] ✏️
│   └── tutorial/
│       ├── tutorial_0_manager.gd        [NUEVO] ✨
│       └── tutorial_0_false_friend.gd   [NUEVO] ✨
│
├── scenes/
│   └── levels/
│       ├── tutorial_0.tscn              [NUEVO] ✨
│       └── tutorial_0_minimal.tscn      [NUEVO] ✨
│
└── TUTORIAL_0_IMPLEMENTATION.md         [ESTE ARCHIVO] 📄
```

---

## 📖 Referencias

### Diseño Original
- Ver conversación anterior para layout pixel-perfect
- Secciones 1-5 del nivel (0-250px, 250-500px, etc.)
- Timing exacto de cinemática (2.5 segundos)

### Audio Reference
- `AUDIO_REFERENCE.md` - Especificaciones del Awakening Scream
- Referencia "Won't Get Fooled Again" - The Who

### Documentación Narrativa
- `NARRATIVE_DESIGN.md` - Contexto de "Big Bad Wolf"
- `NARRATIVE_INTEGRATION_LOG.md` - Integración narrativa

---

## ✅ Checklist de Continuación

**Para la próxima sesión, en orden:**

```
SETUP:
[ ] Abrir proyecto en Godot
[ ] Verificar que GameManager tiene cambios (buscar "tutorial_0_active")
[ ] Verificar que Player tiene método freeze() (buscar en script)

TESTING RÁPIDO:
[ ] Abrir tutorial_0_minimal.tscn
[ ] Instanciar Player en spawn point
[ ] Crear False Friend con script
[ ] Run scene (F6)
[ ] Verificar comportamiento básico

FIXES SI HAY ERRORES:
[ ] Crear autoloads placeholders si faltan
[ ] Comentar líneas de audio si AudioManager no existe
[ ] Usar get_tree().change_scene_to_file() si SceneTransition falla
[ ] Crear tutorial_1.tscn vacío si no existe

REFINAMIENTO:
[ ] Ajustar tutorial_0.tscn completa
[ ] Agregar todas las plataformas
[ ] Instanciar todos los enemigos
[ ] Testear flujo completo

POLISH:
[ ] Agregar audio placeholders
[ ] Screen shake funcional
[ ] Partículas de transformación
```

---

## 💡 Notas Importantes

1. **No necesitas audio para testear** - Los scripts tienen fallbacks
2. **tutorial_0_minimal.tscn es tu amigo** - Úsala para testing rápido
3. **Player y GameManager son críticos** - Verifica que tengan los cambios
4. **Tutorial 1 puede ser escena vacía** - Solo para evitar crash
5. **Placeholders son OK** - Sprites finales vienen después

---

## 🆘 Si Algo No Funciona

**Debugging paso a paso:**

1. **Abrir Godot Output Console** (ver errores)
2. **Run tutorial_0_minimal.tscn**
3. **Anotar TODOS los errores** que aparezcan
4. **Buscar error en "Errores Comunes"** arriba
5. **Si no está documentado:** Revisar línea específica del error

**Típicos problemas:**
- Autoload no existe → Crear placeholder
- Scene no existe → Crear vacía o comentar instancia
- Method not found → Verificar que script tiene el método
- Null reference → Agregar verificación `if obj and obj.has_method()`

---

## 📞 Información de Contacto para Siguiente Sesión

**Archivos clave para revisar:**
1. `scripts/autoloads/game_manager.gd` (líneas 11-20, 56-146)
2. `scripts/core/player_controller.gd` (líneas 134-154, 929-959)
3. `scripts/tutorial/tutorial_0_false_friend.gd` (completo)
4. `scenes/levels/tutorial_0_minimal.tscn`

**Comandos útiles:**
```bash
# Verificar que archivos existen:
ls scripts/tutorial/
ls scenes/levels/tutorial_0*

# Ver cambios en GameManager:
grep -n "tutorial_0" scripts/autoloads/game_manager.gd

# Ver cambios en Player:
grep -n "freeze\|scripted_death" scripts/core/player_controller.gd
```

---

**Fin de la documentación. Buena suerte con la implementación! 🎮🐺**
