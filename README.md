# VEIL

> *"Tear the veil. Face the truth."*

Un platformer oscuro creado para **Global Game Jam 2026** (Tema: "Máscara")

![Status](https://img.shields.io/badge/status-en_desarrollo-yellow)
![Engine](https://img.shields.io/badge/engine-Godot_4.x-blue)
![Jam](https://img.shields.io/badge/jam-GGJ_2026-orange)

---

## 🎮 Concepto

En **VEIL**, posees el poder de arrancar las máscaras de un mundo hipócrita para revelar la verdadera naturaleza de sus habitantes.

- Los enemigos amenazantes pueden ser víctimas asustadas
- Los aliados amigables pueden ser monstruos disfrazados
- Cada revelación tiene consecuencias

Un platformer con mecánica única, estética gótica dibujada a mano, y temas de hipocresía y empoderamiento.

---

## ✨ Características

- **Mecánica única de revelación:** Arranca velos para descubrir verdades
- **Sistema de consecuencias emergentes:** Tus revelaciones cambian el nivel
- **Estética gótica única:** Arte tradicional en papel escaneado (blanco/negro + auras)
- **Narrativa ambiental:** Sin diálogos, la historia se infiere del gameplay
- **Rejugabilidad:** Múltiples enfoques (speedrun vs completista)

---

## 🎯 Controles

| Acción | Tecla |
|--------|-------|
| Mover | `A` / `D` o `←` / `→` |
| Saltar | `Espacio` o `W` o `↑` |
| Arrancar Velo | `E` (cerca de entidades) |
| Pausa | `ESC` |

---

## 📁 Estructura del Proyecto

```
IntentoAgente/
├── assets/             # Sprites, audio (placeholders)
├── scenes/             # Escenas de Godot (.tscn)
│   ├── characters/     # Player, entidades
│   ├── level/          # Puertas, goals, managers
│   ├── levels/         # Level 1, Level 2
│   └── ui/             # HUD, menús, screens
├── scripts/            # Código GDScript
│   ├── autoloads/      # GameManager, AudioManager, SceneTransition
│   ├── core/           # Player controller, reveal system
│   ├── entities/       # Comportamientos de entidades
│   ├── level/          # Lógica de niveles
│   ├── components/     # VeilComponent, RangeIndicator, etc.
│   └── ui/             # Scripts de UI
├── GDD.md              # Game Design Document
├── ROADMAP.md          # Plan de 48 horas
├── CHANGELOG.md        # Historial de cambios
├── ADVANCED_TURRETS.md # Documentación técnica de torretas
├── AUDIO_REFERENCE.md  # Guía de audio
├── LEVEL_2_DESIGN.md   # Diseño de Level 2
└── README.md           # Este archivo
```

---

## 🛠️ Tecnologías

- **Engine:** Godot 4.x
- **Lenguaje:** GDScript
- **Arte:** Papel/lápiz → Escaneo → Procesamiento GIMP
- **Audio:** Freesound.org + generadores

---

## 👥 Equipo

- **Programador:** 1 (conocimiento avanzado)
- **Artista:** 1 (papel y lápiz, estilo tradicional)
- **Diseñador:** 1 (conocimiento básico)

---

## 📋 Documentación

### **Diseño:**
- **[Game Design Document](GDD.md)** - Diseño completo del juego
- **[Roadmap](ROADMAP.md)** - Plan de desarrollo de 48 horas
- **[Level 2 Design](LEVEL_2_DESIGN.md)** - Diseño específico de Level 2

### **Técnica:**
- **[Changelog](CHANGELOG.md)** - Historial completo de cambios y features
- **[Advanced Turrets](ADVANCED_TURRETS.md)** - Mecánicas detalladas de torretas avanzadas
- **[Audio Reference](AUDIO_REFERENCE.md)** - Guía de implementación de audio

### **Guía rápida:**
1. Lee **GDD.md** para entender el concepto
2. Lee **CHANGELOG.md** para ver el estado actual
3. Lee **ADVANCED_TURRETS.md** para entender las mecánicas complejas

---

## 🚀 Estado del Desarrollo

**Fase actual:** Alpha 0.3.1 (Producción)

### ✅ Completado:
- ✅ Core mechanics (movimiento, salto, revelación)
- ✅ Sistema de entidades (3 tipos base + 6 variantes)
- ✅ Level 1 (tutorial + puzzles básicos)
- ✅ Level 2 (torretas avanzadas + boss room)
- ✅ UI completa (main menu, HUD, pause, game over, victory)
- ✅ Sistema de audio (placeholders)
- ✅ Optimización de performance (~85% mejora)
- ✅ Polish & juice (transiciones, squash & stretch)

### 📊 Entidades Implementadas:
- **False Enemy** (huye) + Fast variant (2× velocidad)
- **False Friend** (persigue) + Jumper variant (salta)
- **True Threat** (torreta) + Burst variant (ráfagas)
- **True Threat Tracking** (rota para apuntar)
- **True Threat Laser** (láser continuo con telegraph)
- **True Threat Shield** (requiere 2 revelaciones)

### 🎮 Niveles:
- **Level 1:** Tutorial progresivo (7 entidades, 3 puertas)
- **Level 2:** Desafío avanzado (11 entidades/13 verdades, boss room)

### 🐛 Bugs conocidos:
- Ninguno actualmente

### 🔜 Próximos pasos:
1. Level 3 (final/boss fight)
2. Endings múltiples basados en % de verdades
3. Assets de audio reales
4. Arte final (sprites y animaciones)

Ver [CHANGELOG.md](CHANGELOG.md) para detalles completos de features implementadas.

---

## 📝 Licencia

Proyecto creado para Global Game Jam 2026.

---

## 🎵 Inspiración

**Temática:** In This Moment - "Whore", "The In-Between"
**Visual:** Darkest Dungeon, Limbo, Return of the Obra Dinn
**Mecánicas:** Celeste, Hollow Knight

---

**Última actualización:** 2026-01-31
**Versión:** Alpha 0.3.1
