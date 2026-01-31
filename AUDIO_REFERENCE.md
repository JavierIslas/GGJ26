# VEIL - Audio Reference

Este documento lista todos los efectos de sonido (SFX) y música que el juego necesita.

## 📁 Estructura de Carpetas

```
assets/audio/
├── sfx/           # Efectos de sonido (.wav o .ogg)
└── music/         # Música de fondo (.ogg recomendado)
```

---

## 🔊 SFX Requeridos

### **Player Actions**
| Nombre del Archivo | Ubicación en Código | Descripción | Volumen (dB) |
|-------------------|-------------------|-------------|--------------|
| `jump.wav/ogg` | `player_controller.gd:129` | Sonido al saltar | -5.0 |
| `tear_veil.wav/ogg` | `reveal_system.gd:137` | Arrancar velo/máscara (efecto principal) | 0.0 |

### **Game Events**
| Nombre del Archivo | Ubicación en Código | Descripción | Volumen (dB) |
|-------------------|-------------------|-------------|--------------|
| `damage.wav/ogg` | `game_manager.gd:43` | Recibir daño | -3.0 |
| `death.wav/ogg` | `game_manager.gd:50` | Muerte del jugador | 0.0 |
| `door_open.wav/ogg` | `truth_door.gd:54` | Puerta abriéndose | -5.0 |
| `level_complete.wav/ogg` | `level_goal.gd:64` | Completar nivel | 0.0 |

### **Optional UI SFX** (no implementado aún)
- `ui_click.wav/ogg` - Click en botones
- `ui_hover.wav/ogg` - Hover sobre botones
- `pause.wav/ogg` - Abrir menú de pausa

---

## 🎵 Música Requerida

### **Sistema de Capas Dinámicas**
El AudioManager usa un sistema de 2 capas:
- **Ambient Layer**: Música ambiental constante
- **Combat Layer**: Se activa cuando hay enemigos cerca (crossfade)

### **Tracks Necesarios**

| Track | Uso | Formato Recomendado |
|-------|-----|---------------------|
| `menu_theme.ogg` | Main Menu | OGG, Loop |
| `level_ambient.ogg` | Capa base de niveles | OGG, Loop |
| `level_combat.ogg` | Capa de combate (opcional) | OGG, Loop |

---

## 🎨 Estilo de Audio Recomendado

**Género musical:** Dark ambient, industrial, gótico
**Instrumentos:** Sintetizadores oscuros, cuerdas tensas, percusión tribal
**Referencia:** Silent Hill, Darkest Dungeon, INSIDE

**SFX:**
- `tear_veil`: Tela rasgándose + reverb + cristal quebrándose (efecto dramático)
- `jump`: Suave, no invasivo
- `damage`: Impacto seco, doloroso
- `death`: Profundo, final
- `door_open`: Metálico, pesado
- `level_complete`: Triunfante pero oscuro

---

## 🔗 Recursos Gratuitos

### **SFX**
- [Freesound.org](https://freesound.org/) - CC0/CC-BY
- [OpenGameArt.org](https://opengameart.org/) - Varios assets gratuitos
- [JSFXR](https://sfxr.me/) - Generador de SFX 8-bit

### **Música**
- [Kevin MacLeod - Incompetech](https://incompetech.com/) - CC-BY
- [Purple Planet](https://www.purple-planet.com/) - Royalty Free
- [LMMS](https://lmms.io/) - Software libre para crear música

---

## ⚙️ Implementación Técnica

### **Cómo agregar SFX**
1. Colocar archivo en `assets/audio/sfx/`
2. El nombre del archivo debe coincidir con el usado en el código
3. Formatos soportados: `.wav` (sin compresión) o `.ogg` (comprimido)

### **Cómo agregar Música**
```gdscript
# En la escena o nivel:
AudioManager.play_music(
    "res://assets/audio/music/level_ambient.ogg",
    "res://assets/audio/music/level_combat.ogg"  # Opcional
)
```

### **Controlar capas de combate**
```gdscript
# Activar música de combate
AudioManager.activate_combat()

# Desactivar música de combate
AudioManager.deactivate_combat()
```

---

## 📝 Notas

- **Placeholder**: El juego funciona sin archivos de audio, solo mostrará warnings en consola
- **Volumen**: Los valores en dB son sugeridos, ajustar según sea necesario
- **Loops**: La música debe ser seamless loop para evitar cortes
- **Formato**: OGG recomendado para música (menor tamaño), WAV para SFX cortos

---

**Última actualización:** 2026-01-31
