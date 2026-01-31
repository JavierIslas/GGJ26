# VEIL - Level 2 Design Document

## 🎯 Concepto

**Nombre:** "Advanced Threats"
**Objetivo:** Introducir todas las variantes avanzadas de True Threat
**Dificultad:** Media-Alta
**Verdades totales:** 12 (4 dobles por Shield)

---

## 📐 Layout del Nivel

```
[Spawn] → [Tracking] → [Laser] → [Fast+Burst] → [Shield] → [BOSS ROOM] → [Goal]
  150      800-1000     1600       2200-2600      3200        4000-5000    5100
```

**Longitud total:** ~5000px (3.3x más largo que Level 1)
**Fondo:** Azul oscuro (0.08, 0.08, 0.12) - más oscuro que Level 1

---

## 🗺️ Áreas Detalladas

### **Área 1: Spawn + Introducción**
**Posición:** X: 0-650

**Elementos:**
- Spawn point (150, 500)
- Texto introductorio:
  ```
  LEVEL 2: ADVANCED THREATS
  Nuevas torretas avanzadas
  ¡Ten cuidado!
  ```

**Entidades:** Ninguna
**Puertas:** Door1 (650, 530) - Requiere 1 verdad

**Propósito:** Dar al jugador tiempo para prepararse

---

### **Área 2: True Threat Tracking**
**Posición:** X: 650-1900

**Elementos:**
- 2 plataformas (800, 1000) para esquivar
- Hint: "TRACKING TURRET - Rota para seguirte"

**Entidades:**
- 1× True Threat Tracking (900, 540)

**Puertas:** Door2 (1900, 530) - Requiere 3 verdades

**Mecánica introducida:**
- Torreta que ROTA para seguir al jugador
- Laser sight visible (línea roja)
- Solo dispara cuando apuntado correctamente

**Desafío:**
- Jugador debe moverse constantemente
- Usar plataformas para romper línea de visión
- Timing para revelar sin ser disparado

---

### **Área 3: True Threat Laser**
**Posición:** X: 1900-2900

**Elementos:**
- 1 plataforma (1600, 400)
- Hint: "LASER TURRET - Telegraph → Láser continuo"

**Entidades:**
- 1× True Threat Laser (1600, 360)

**Puertas:** Door3 (2900, 530) - Requiere 6 verdades

**Mecánica introducida:**
- Telegraph (línea naranja pulsante, 1.5s)
- Láser continuo (1 segundo de daño)
- Daño continuo si te atrapa

**Desafío:**
- Observar el telegraph
- Esquivar cuando cambie a rojo
- Timing preciso para cruzar

---

### **Área 4: Fast Enemies + Burst**
**Posición:** X: 2900-3800

**Elementos:**
- 1 plataforma (2400, 450)
- Mix de amenazas

**Entidades:**
- 2× False Enemy Fast (2200, 2600) - Patrullan rápido
- 1× True Threat Burst (2400, 410) - Ráfagas

**Puertas:** Door4_Boss (3800, 530) - Requiere 8 verdades (warning: Boss ahead)

**Mecánica combinada:**
- Enemigos rápidos en el suelo
- Torreta disparando ráfagas desde arriba
- Requiere priorizar amenazas

**Desafío:**
- Gestión de múltiples enemigos
- Evitar enemigos terrestres mientras esquivas proyectiles
- Decisión: ¿Revelar a quién primero?

---

### **Área 5: Shield Challenge**
**Posición:** X: 3800-4000

**Elementos:**
- 1 plataforma (3200, 400)
- Hint: "SHIELDED TURRET - Requiere 2 revelaciones"

**Entidades:**
- 1× True Threat Shield (3200, 360) - **Requiere 2 revelaciones**
- 1× False Friend Jumper (3350, 540) - Distracción

**Mecánica introducida:**
- Escudo que debe romperse primero
- Dos fases (Escudo → Torreta activa)
- Jumper añade presión

**Desafío:**
- Primera revelación: Romper escudo
- Esquivar proyectiles del Jumper
- Segunda revelación: Destruir torreta
- Mini-boss antes del boss real

---

### **Área 6: BOSS ROOM**
**Posición:** X: 4000-5000

**Elementos:**
- 2 plataformas superiores (4200, 4800) a altura 300
- Espacio amplio para maniobrar
- Hint: "¡¡¡ BOSS ROOM !!! - Múltiples torretas"

**Entidades:**
- 1× True Threat Shield (4500, 540) - **Centro (2 revelaciones)**
- 2× True Threat Tracking (4200, 4800) - **Esquinas superiores**
- 1× True Threat Laser (4050, 540) - **Lateral**

**Total verdades necesarias:** 6
- Shield: 2
- Tracking L: 1
- Tracking R: 1
- Laser: 1

**Puertas:** DoorFinal (5000, 530) - Requiere 12 verdades

**Estrategia recomendada:**
1. Eliminar Tracking laterales primero (menos amenaza)
2. Esquivar láser usando telegraph
3. Romper Shield del centro
4. Eliminar Laser (peligro continuo)
5. Destruir Shield central

**Desafío:**
- Gestión de 4 torretas simultáneas
- Cada una con mecánica única
- Requiere dominio de todas las mecánicas
- Boss fight épico

---

### **Área 7: Victory**
**Posición:** X: 5000-5200

**Elementos:**
- Goal (5100, 530) - Requiere 12 verdades

**Victoria:** Muestra Victory Screen con ranking

---

## 📊 Estadísticas del Nivel

### **Entidades Totales:** 12
- **False Enemy Fast:** 2
- **False Friend Jumper:** 1
- **True Threat Tracking:** 3 (1 intro + 2 boss)
- **True Threat Laser:** 2 (1 intro + 1 boss)
- **True Threat Burst:** 1
- **True Threat Shield:** 2 (1 + 1 boss) - **Cuentan como 4 verdades**

### **Verdades Revelables:** 12
- Área 2 (Tracking): 1
- Área 3 (Laser): 1
- Área 4 (2 Fast + Burst): 3
- Área 5 (Shield + Jumper): 2 + 1 = 3 (Shield cuenta doble)
- Boss (Shield + 2 Tracking + Laser): 2 + 2 + 1 = 5 (Shield cuenta doble)
- **Total:** 1 + 1 + 3 + 3 + 5 = 13 verdades

### **Puertas:** 5
1. Door1 → 1 verdad (acceso a Tracking)
2. Door2 → 3 verdades (acceso a Fast+Burst)
3. Door3 → 6 verdades (acceso a Shield)
4. Door4_Boss → 8 verdades (acceso a Boss Room)
5. DoorFinal → 12 verdades (acceso a Goal)

### **Ranking Perfecto:**
- 100% verdades = Rank S
- Requiere revelar TODOS los enemigos incluyendo escudos

---

## 🎨 Elementos Visuales

### **Colores de Puertas:**
```gdscript
Door1:      Color(1.0, 0.2, 0.2, 1.0)  // Rojo
Door2:      Color(1.0, 0.4, 0.1, 1.0)  // Naranja
Door3:      Color(0.8, 0.6, 0.1, 1.0)  // Amarillo-dorado
Door4_Boss: Color(0.8, 0.1, 0.8, 1.0)  // Púrpura (warning!)
DoorFinal:  Color(0.8, 0.6, 0.1, 1.0)  // Dorado (victoria)
```

### **Hints en Pantalla:**
- **Tracking:** Rojo (1, 0.3, 0.3)
- **Laser:** Cyan (0.2, 0.8, 1)
- **Shield:** Azul (0.2, 0.6, 1)
- **Boss:** Púrpura (0.8, 0.1, 0.8)

---

## 🎮 Curva de Dificultad

```
Dificultad
    ^
    |                          ┌─────┐ BOSS
    |                         /       \
    |                   ┌────┘         └─┐
    |              ┌───┘                 └─→ Victory
    |         ┌───┘
    |    ┌───┘
    └────┴──────────────────────────────→ Progreso
    Spawn  Track  Laser  Fast  Shield  Boss  Goal
```

### **Progresión de Habilidades:**
1. **Tracking** - Movimiento evasivo
2. **Laser** - Timing y observación
3. **Fast+Burst** - Multitasking
4. **Shield** - Persistencia (2 revelaciones)
5. **Boss** - Maestría de todo lo anterior

---

## 💡 Consejos de Diseño

### **Por qué este orden:**
1. **Tracking primero:** Enseña movimiento constante
2. **Laser segundo:** Añade timing preciso
3. **Fast+Burst:** Combina habilidades previas
4. **Shield:** Introduce mecánica nueva (multi-fase)
5. **Boss:** Prueba final de todo

### **Balanceo:**
- HP del jugador: 3 (mismo que Level 1)
- Daño promedio de torretas: 1-2 HP
- Margen de error: 1-3 golpes antes de muerte
- Checkpoints implícitos: Puertas actúan como checkpoints

### **Accesibilidad:**
- Todas las mecánicas tienen telegraph visual
- Hints explican cada nueva torreta
- Progresión gradual de dificultad
- Boss puede completarse con estrategia, no solo reflejos

---

## 🔗 Conexión con otros Niveles

### **Desde Level 1:**
```gdscript
// level_1.tscn - LevelGoal
next_level_path = "res://scenes/levels/level_2.tscn"
```

### **Hacia Level 3 (futuro):**
```gdscript
// level_2.tscn - LevelGoal
next_level_path = "res://scenes/levels/level_3.tscn"  // Cuando exista
```

---

## 📝 Notas de Implementación

### **Optimización:**
- Todas las entidades usan cacheo de player_ref
- Range indicators optimizados (Timer 100ms)
- Laser usa Area2D para detección de daño

### **Testing:**
- Tiempo estimado de completado: 3-5 minutos
- Skill level requerido: Intermedio-Avanzado
- Muertes esperadas (primera vez): 2-4

### **Bugs conocidos:**
- Ninguno reportado aún

---

## 🎯 Objetivos de Aprendizaje

Al completar Level 2, el jugador habrá aprendido:
1. ✅ Evasión de torretas con tracking
2. ✅ Timing contra láser con telegraph
3. ✅ Gestión de múltiples amenazas
4. ✅ Estrategia de priorización
5. ✅ Mecánicas multi-fase (Shield)
6. ✅ Coordinación compleja (Boss)

**Preparación para:** Niveles finales, puzzles complejos, boss fights avanzados

---

**Última actualización:** 2026-01-31
**Versión:** 1.0
**Estado:** Implementado y listo para testing
