# Guía de Integración de Puzzles - VEIL

## 📦 Componentes Creados

### Scripts Base
1. **`scripts/puzzle/puzzle_switch.gd`** - Interruptor activable por shards o interacción
2. **`scripts/puzzle/sync_reveal_door.gd`** - Puerta que requiere revelar enemigos simultáneamente
3. **`scripts/puzzle/timed_puzzle_controller.gd`** - Controlador de puzzles con timing

---

## 🎮 Level 2 - Puzzles a Integrar

### Puzzle 2.1: "Revelación Sincronizada" (Area 3 - ~1600px)

**Ubicación**: Entre Platform3_Area3 y Platform4_Area4

**Componentes necesarios:**

1. **3 False Enemies agrupados** (distancia <130px entre ellos)
   ```
   Posiciones sugeridas:
   - FalseEnemy1: (1550, 450)
   - FalseEnemy2: (1600, 430)
   - FalseEnemy3: (1650, 450)
   ```

2. **SyncRevealDoor**
   - Script: `res://scripts/puzzle/sync_reveal_door.gd`
   - Tipo: StaticBody2D
   - Configuración:
     ```gdscript
     required_reveals = 3
     time_window = 3.5  # Generoso
     enemy_group = "puzzle_sync_area3"
     door_color_locked = Color.RED
     door_color_unlocked = Color.GREEN
     open_direction = Vector2(0, -200)
     ```
   - Posición: (1700, 530)
   - Añadir Sprite2D + CollisionShape2D

3. **Agrupar los 3 enemigos:**
   - En el Inspector de cada enemigo, agregar al grupo: `puzzle_sync_area3`

**Instrucciones de uso:**
- Jugador debe usar **Howl AOE** (E hold 1.1s) para revelar los 3 enemigos simultáneamente
- Ventana de 3.5s (muy generosa)
- La puerta se abre y permite avanzar

---

### Puzzle 2.2: "Proyectiles Precisos" (Area 4 - ~2400px)

**Ubicación**: En Platform4_Area4

**Componentes necesarios:**

1. **PuzzleSwitch** (lejano, elevado)
   - Script: `res://scripts/puzzle/puzzle_switch.gd`
   - Tipo: Area2D
   - Configuración:
     ```gdscript
     activation_type = ActivationType.PROJECTILE  # Solo shards
     stays_active = true
     can_toggle = false
     ```
   - Posición: (2400, 300)  # Alto, fuera de alcance de Reveal
   - Añadir Sprite2D + CollisionShape2D (CircleShape2D, radius: 16)

2. **Plataforma que aparece al activar switch:**
   ```gdscript
   # En el script de una StaticBody2D:
   @onready var puzzle_switch = get_node("../PuzzleSwitch_Area4")
   @onready var collision_shape = $CollisionShape2D

   func _ready():
       collision_shape.disabled = true
       modulate.a = 0.3
       puzzle_switch.activated.connect(_on_switch_activated)

   func _on_switch_activated():
       collision_shape.disabled = false
       var tween = create_tween()
       tween.tween_property(self, "modulate:a", 1.0, 0.5)
   ```

3. **Enemigos para shards:**
   - Los FastEnemy actuales en Area4 son suficientes
   - El jugador debe revelarlos para obtener shards

**Instrucciones de uso:**
- Jugador revela enemigos → obtiene shards
- Apunta y lanza shard (R / Click Derecho) al switch elevado
- Plataforma aparece permitiendo avanzar

---

## 🎮 Level 3 - Puzzles a Integrar

### Puzzle 3.1: "Cascada de Verdades" (A lo largo del nivel)

**Concepto**: Puertas opcionales que se abren según verdades acumuladas

**Componentes necesarios:**

1. **Puertas secundarias (TruthDoor)** - Ya existen
   - Usar las puertas actuales pero hacerlas **opcionales**
   - Colocar recompensas detrás: Shards extra, HP

2. **Puertas de secreto:**
   ```gdscript
   # Nueva TruthDoor opcional
   truths_required = 10  # Requiere exploración
   door_color = Color(1.0, 0.8, 0.0, 1)  # Dorado para indicar secreto
   ```
   - Posiciones sugeridas: Ramificaciones del camino principal
   - Recompensas: 2-3 shards, Full HP restore

---

### Puzzle 3.2: "Control de Masas" (Area 4 - ~3000px)

**Ubicación**: Antes del Boss final

**Componentes necesarios:**

1. **4 False Friends revelables**
   ```
   Posiciones distribuidas:
   - FalseFriend1: (3800, 460)
   - FalseFriend2: (3850, 480)
   - FalseFriend3: (3900, 460)
   - FalseFriend4: (3950, 480)
   ```
   - Agrupar en: `puzzle_mass_control`

2. **3 PuzzleSwitches interactuables** (presionar E)
   - Script: `res://scripts/puzzle/puzzle_switch.gd`
   - Configuración:
     ```gdscript
     activation_type = ActivationType.INTERACTION  # Solo E
     stays_active = true
     ```
   - Posiciones:
     - Switch1: (3820, 520)
     - Switch2: (3900, 520)
     - Switch3: (3980, 520)
   - Agrupar en: `puzzle_mass_switches`

3. **TimedPuzzleController**
   - Script: `res://scripts/puzzle/timed_puzzle_controller.gd`
   - Tipo: Node
   - Configuración:
     ```gdscript
     required_switches = 3
     required_stunned_enemies = 4
     time_window = 3.0  # Generoso
     coyote_time = 0.5  # Buffer extra
     switch_group = "puzzle_mass_switches"
     enemy_group = "puzzle_mass_control"
     auto_start = false  # Se inicia cuando el jugador entra al área
     ```

4. **Puerta Final conectada:**
   ```gdscript
   # En script de TruthDoor o StaticBody2D personalizada:
   @onready var puzzle = get_node("../TimedPuzzleController")

   func _ready():
       puzzle.puzzle_completed.connect(_open_door)

   func _open_door():
       # Animación de apertura
       var tween = create_tween()
       tween.tween_property(self, "position:y", position.y - 200, 1.0)
       $CollisionShape2D.disabled = true
   ```

5. **Trigger Area para iniciar puzzle:**
   ```gdscript
   # Area2D que detecta al jugador
   func _on_body_entered(body):
       if body.is_in_group("player"):
           var puzzle = get_node("../TimedPuzzleController")
           puzzle.trigger_start()
   ```

**Instrucciones de uso:**
1. Jugador entra al área → Puzzle se inicia (ventana de 3s)
2. Jugador revela los 4 False Friends individualmente (E tap)
3. Jugador usa **Howl** para aturdirlos todos (2s stun)
4. Mientras están aturdidos, presionar E en los 3 switches
5. Si todo se completa en ~3s (+0.5s buffer), puerta se abre

---

## ⚙️ Valores de Timing (Generosos)

| Puzzle | Ventana Base | Coyote Time | Total Efectivo |
|--------|--------------|-------------|----------------|
| **Revelación Sincronizada** | 3.5s | - | 3.5s |
| **Control de Masas** | 3.0s | 0.5s | 3.5s |
| **Proyectiles Precisos** | - | - | Sin límite |

**Nota**: Los tiempos son deliberadamente generosos para evitar frustración "pixel-perfect".

---

## 🔧 Pasos de Integración en Godot

### Para cada puzzle:

1. **Crear nodos en la escena del nivel**
   - Añadir enemigos, switches, puertas según especificaciones
   - Asignar posiciones exactas

2. **Asignar scripts**
   - Arrastrar scripts desde `res://scripts/puzzle/` a los nodos
   - Configurar @export variables en el Inspector

3. **Agrupar elementos**
   - Seleccionar enemigos/switches → Inspector → Node → Groups → Add
   - Usar nombres de grupo especificados arriba

4. **Conectar señales** (si es necesario)
   - puzzle_completed → door_opened
   - switch_activated → platform_appeared

5. **Testear**
   - Play scene
   - Verificar timing y feedback visual
   - Ajustar `time_window` y `coyote_time` si es necesario

---

## 📊 Testing Checklist

### Level 2
- [ ] Puzzle 2.1: Howl revela 3 enemigos → Puerta abre
- [ ] Puzzle 2.1: Ventana de 3.5s es cómoda
- [ ] Puzzle 2.2: Shard activa switch lejano
- [ ] Puzzle 2.2: Plataforma aparece correctamente

### Level 3
- [ ] Puzzle 3.1: Puertas opcionales accesibles
- [ ] Puzzle 3.1: Recompensas valiosas
- [ ] Puzzle 3.2: Trigger inicia puzzle
- [ ] Puzzle 3.2: Howl aturde 4 enemigos
- [ ] Puzzle 3.2: 3s + 0.5s buffer es suficiente para activar 3 switches
- [ ] Puzzle 3.2: Puerta final abre al completar

---

## 🎨 Mejoras Visuales Opcionales

- **Partículas** en switches al activar
- **Tween de escala** en puertas al abrir
- **UI Timer** mostrando tiempo restante (para puzzles timed)
- **Hints visuales** (flechas apuntando a switches, glow en enemigos)
- **SFX específicos** para cada tipo de puzzle

---

## 💡 Tips de Balance

Si un puzzle es muy difícil:
1. Aumentar `time_window` (+0.5s)
2. Aumentar `coyote_time` (+0.2s)
3. Reducir `required_switches` o `required_stunned_enemies`
4. Acortar distancias entre elementos

Si un puzzle es muy fácil:
1. Reducir `time_window` (máximo -0.5s)
2. Aumentar cantidad de elementos requeridos
3. Aumentar distancias entre switches

**Regla de oro**: Si tú (developer) lo completaste en el primer intento, probablemente está bien balanceado.
