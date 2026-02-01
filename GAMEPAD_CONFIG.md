# Gamepad Configuration

## Soporte de Gamepad Implementado

VEIL ahora tiene soporte completo para gamepad/controller. El juego detecta automáticamente el controlador conectado y permite jugar con él sin necesidad de configuración adicional.

## Controles por Defecto

### Xbox Controller Layout

```
┌─────────────────────────────────────┐
│  LT    LB          RB    RT         │
│                                     │
│    [D-Pad]      (Y)                 │
│   ←  ↑  →    (X)   (B)             │
│      ↓          (A)                 │
│                                     │
│   [Left Stick]   [Right Stick]     │
│                                     │
│   [View] [Xbox] [Menu]              │
└─────────────────────────────────────┘
```

**Controles de Juego:**
- **Left Stick / D-Pad:** Movimiento (izquierda/derecha)
- **A Button:** Salto
- **B Button / X Button:** Revelar velo (E)
- **Menu Button (Start):** Pausar/Resume

### PlayStation Controller Layout

```
┌─────────────────────────────────────┐
│  L2    L1          R1    R2         │
│                                     │
│    [D-Pad]      (△)                │
│   ←  ↑  →    (□)   (○)             │
│      ↓          (✕)                 │
│                                     │
│   [Left Stick]   [Right Stick]     │
│                                     │
│   [Share] [PS] [Options]            │
└─────────────────────────────────────┘
```

**Controles de Juego:**
- **Left Stick / D-Pad:** Movimiento (izquierda/derecha)
- **✕ (Cross):** Salto
- **○ (Circle) / □ (Square):** Revelar velo (E)
- **Options Button:** Pausar/Resume

### Nintendo Switch Pro Controller Layout

```
┌─────────────────────────────────────┐
│  ZL    L           R    ZR          │
│                                     │
│    [D-Pad]      (X)                 │
│   ←  ↑  →    (Y)   (A)             │
│      ↓          (B)                 │
│                                     │
│   [Left Stick]   [Right Stick]     │
│                                     │
│   [-] [Home] [+]                    │
└─────────────────────────────────────┘
```

**Controles de Juego:**
- **Left Stick / D-Pad:** Movimiento (izquierda/derecha)
- **B Button:** Salto
- **A Button / Y Button:** Revelar velo (E)
- **+ Button:** Pausar/Resume

## Mapeado Técnico

### Input Actions

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| `move_left` | A, Left Arrow | D-Pad Left, Left Stick Left |
| `move_right` | D, Right Arrow | D-Pad Right, Left Stick Right |
| `jump` | Space, W, Up Arrow | Button 0 (A/Cross/B) |
| `reveal` | E | Button 1, 2 (B+X/Circle+Square/A+Y) |
| `ui_cancel` | ESC | Button 6 (Start/Options/+) |

### Axis Configuration

**Left Stick Horizontal (Axis 0):**
- **Value -1.0:** Move Left
- **Value +1.0:** Move Right
- **Deadzone:** 0.5 (50%)

**Deadzone Explanation:**
- El deadzone de 0.5 significa que el stick debe moverse al menos 50% desde el centro para registrar input
- Previene drift (movimiento no intencional cuando el stick está en reposo)
- Ajustable en `project.godot` si es necesario

## Testing Gamepad

### Verificar Conexión

1. **Conecta tu gamepad** (USB o Bluetooth)
2. **Ejecuta VEIL**
3. En el main menu, intenta navegar con el stick/D-Pad
4. Presiona A/Cross para seleccionar

### Test de Controles

**En el juego:**
1. **Movimiento:** Mueve el Left Stick o D-Pad
   - Debe moverse suavemente
   - Sin drift cuando el stick está centrado
2. **Salto:** Presiona A/Cross
   - Debe saltar responsivamente
   - Mantener presionado = salto más alto
3. **Reveal:** Presiona B/Circle o X/Square
   - Debe revelar enemigos cercanos
   - Cooldown de 0.5s entre revelaciones
4. **Pause:** Presiona Start/Options
   - Debe pausar el juego
   - Presionar nuevamente para resumir

### Problemas Comunes

**El gamepad no responde:**
- Verifica que esté conectado (Windows: Settings > Devices > Bluetooth)
- Verifica que esté detectado (Windows: joy.cpl)
- Reinicia el juego después de conectar el gamepad

**Movimiento con drift:**
- Aumenta el deadzone en `project.godot`:
  ```ini
  move_left={
  "deadzone": 0.6,  # Aumentado de 0.5
  ...
  ```

**Botones invertidos:**
- Algunos gamepads genéricos pueden tener diferentes mappings
- Godot intenta detectar automáticamente el tipo de controlador
- Si falla, considera usar software como DS4Windows (PS4) o BetterJoy (Switch)

## Compatibilidad

### Controllers Soportados

✅ **Oficialmente Soportados:**
- Xbox One Controller
- Xbox Series X|S Controller
- PlayStation DualShock 4
- PlayStation DualSense
- Nintendo Switch Pro Controller
- Steam Controller

⚠️ **Compatibilidad Parcial:**
- Gamepads genéricos USB
- Controladores terceros (pueden requerir drivers)

❌ **No Soportados:**
- Teclados y ratones inalámbricos (usar conexión USB)
- Controles móviles

### Plataformas

| Platform | Soporte | Notas |
|----------|---------|-------|
| **Windows** | ✅ Full | Plug & play con XInput |
| **Linux** | ✅ Full | Requiere drivers (xpad, hid-sony) |
| **macOS** | ✅ Full | Soporte nativo en macOS 10.15+ |
| **Steam Deck** | ✅ Full | Controles nativos funcionan |

## Configuración Avanzada

### Ajustar Deadzone

Si experimentas drift o el control es poco responsivo:

1. Abre `project.godot` en un editor de texto
2. Busca `move_left` y `move_right`
3. Modifica el valor de `"deadzone"`:

```ini
move_left={
"deadzone": 0.6,  # Valores: 0.0 (muy sensible) a 1.0 (poco sensible)
...
```

**Recomendaciones:**
- **Stick desgastado/drift:** 0.6 - 0.7
- **Stick nuevo:** 0.4 - 0.5
- **Competitivo/speedrun:** 0.2 - 0.3

### Invertir Eje

Si el movimiento está invertido:

```ini
# Cambiar axis_value de -1.0 a 1.0 (y viceversa)
Object(InputEventJoypadMotion,"axis":0,"axis_value":1.0,"script":null)
```

### Agregar Botones Adicionales

Para agregar más botones (ej: RT para dash futuro):

```ini
dash={
"deadzone": 0.5,
"events": [Object(InputEventJoypadButton,"button_index":7,"pressed":true,"script":null)
]
}
```

**Índices de Botones:**
- 0: A (Xbox) / Cross (PS) / B (Switch)
- 1: B (Xbox) / Circle (PS) / A (Switch)
- 2: X (Xbox) / Square (PS) / Y (Switch)
- 3: Y (Xbox) / Triangle (PS) / X (Switch)
- 4: LB / L1 / L
- 5: RB / R1 / R
- 6: Back/Share / View / -
- 7: Start/Options / Menu / +
- 8: Left Stick Press (L3)
- 9: Right Stick Press (R3)
- 10: D-Pad Up
- 11: D-Pad Down
- 12: D-Pad Left
- 13: D-Pad Right

## Vibración (Rumble)

### Estado Actual

⚠️ **No implementado aún**

La vibración del gamepad está planeada para futuras versiones:
- Vibración al recibir daño
- Vibración al revelar enemigos
- Vibración al romper escudo (TrueThreatShield)

### Implementación Futura

```gdscript
# Ejemplo de código para vibración
Input.start_joy_vibration(0, 0.5, 0.0, 0.2)  # Weak motor, 0.2s
```

## UI Navigation con Gamepad

### Main Menu

- **D-Pad/Left Stick:** Navegar opciones
- **A/Cross:** Seleccionar
- **B/Circle:** Volver (cuando esté disponible)

### Pause Menu

- **D-Pad/Left Stick:** Navegar opciones
- **A/Cross:** Seleccionar
- **Start/Options:** Cerrar pause menu (resume)

### Game Over / Victory Screen

- **D-Pad/Left Stick:** Navegar opciones
- **A/Cross:** Seleccionar opción
- **B/Circle:** Retry level

## Tips para Jugar con Gamepad

### Ventajas del Gamepad

1. **Movimiento analógico:** Control más preciso de velocidad
2. **Ergonomía:** Más cómodo para sesiones largas
3. **Portabilidad:** Juega desde el sofá

### Desventajas del Gamepad

1. **Precisión:** Menos preciso que teclado para inputs frame-perfect
2. **Input lag:** Puede haber delay mínimo (especialmente Bluetooth)
3. **Batería:** Gamepads inalámbricos requieren recarga

### Recomendaciones

- **Para casual play:** Gamepad recomendado
- **Para speedrunning:** Teclado recomendado
- **Para accesibilidad:** Cualquiera, basado en preferencia personal

## Troubleshooting

### El gamepad se desconecta durante el juego

**Causa:** Modo de ahorro de energía
**Solución:**
- Desactiva sleep mode del controlador
- Usa conexión USB en lugar de Bluetooth
- Ajusta configuración de energía en Windows

### Input lag notable

**Causa:** Conexión Bluetooth con latencia alta
**Solución:**
- Usa conexión USB cableada
- Actualiza drivers del Bluetooth
- Reduce interferencia (aleja router WiFi, microondas)

### Botones no responden

**Causa:** Gamepad no detectado correctamente
**Solución:**
1. Abre Godot Editor
2. Ve a Project → Project Settings → Input Map
3. Verifica que los botones estén mapeados
4. Presiona botones en el gamepad para testear

---

**Status:** ✅ **FULLY IMPLEMENTED**
**Versión:** Alpha 0.6.1
**Fecha:** 2026-01-31
**Tested on:** Xbox Series X Controller, DualSense
