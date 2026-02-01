# PROMPT PARA SIGUIENTE SESIÓN: Implementar Tutorial

## 📋 Contexto del Proyecto

**Proyecto:** VEIL - Platformer narrativo "Big Bad Wolf"
**Engine:** Godot 4.4
**Repo:** https://github.com/JavierIslas/GGJ26.git
**Branch:** master
**Último commit:** 28e7dba (False Enemy patrol fix)

---

## ✅ Estado Actual (100% Funcional)

### Mecánicas Implementadas:
1. **Movimiento:** Salto, coyote time, jump buffer
2. **Veil Shards:** Proyectiles del jugador (click derecho/R), max 3, generados al revelar
3. **Wolf's Howl:** Grito de área (hold E 1.5s), aturde enemigos revelados, 8s cooldown
4. **Moonlight Dash:** Dash invencible (Shift/B), atraviesa enemigos, genera shards extra
5. **Reveal System:** Arrancar velos (E), 48px range, 0.5s cooldown
6. **iFrames:** 1s invencibilidad tras daño

### Enemigos:
- **False Enemy:** Víctimas, patrullan 120 px/s, huyen cuando revelados
- **False Friend:** Depredadores, 3 HP, persiguen cuando revelados
- **True Threat:** Sistema, torretas que disparan (4 variantes)

### Sistemas:
- GameManager, AudioManager, ProjectileManager, ParticleEffects
- Truth Doors (requieren verdades reveladas)
- Level Goals
- 3 Endings narrativos

### Niveles:
- Level 1, 2, 3 (funcionales)
- HUD, Victory Screen, Game Over, Pause Menu

### Pendientes:
- ⚠️ Fix input `dash` (pressed:false en project.godot)
- 🎨 Arte (sprites, animaciones) - artista
- 🎵 Sonidos específicos (dash, howl, shards)
- ⏰ **TUTORIAL (PRÓXIMA TAREA)**

---

## 🎯 TAREA: Crear Tutorial/Onboarding

### Objetivo:
Crear un **nivel tutorial** que enseñe las mecánicas progresivamente sin texto explicativo innecesario. El tutorial debe sentirse orgánico y alineado con la narrativa "Big Bad Wolf".

### Scope Sugerido (2-3 horas):

**Nivel: Tutorial.tscn** (antes de Level 1)

#### Sección 1: Movimiento Básico (30s)
- Espacio abierto simple
- **Enseña:** Correr (A/D), Saltar (Space/A)
- **Diseño:** Plataformas bajas → medianas → altas
- **Sin texto:** El jugador explora naturalmente

#### Sección 2: Revelar (1 min)
- **Primer False Enemy** (enmascarado, bloqueando el camino)
- **Indicador visual:** Círculo pulsante alrededor del jugador cuando está en rango
- **Enseña:** Presionar E para revelar
- **Resultado:** False Enemy huye, camino libre
- **Texto mínimo:** "E" flotando sobre enemigo cuando está en rango

#### Sección 3: Veil Shards (1 min)
- **Segundo False Enemy** para generar primer shard
- **Visual:** Shard orbita → UI muestra "Shards: 1/3"
- **Primer False Friend** (revelado, persigue)
- **Indicador:** "Click Derecho" o ícono de botón R
- **Enseña:** Lanzar shard para eliminar False Friend
- **Diseño:** False Friend bloquea paso estrecho

#### Sección 4: Wolf's Howl (1 min)
- **Grupo de 3 False Friends** revelados
- **Situación:** Rodean al jugador
- **Indicador:** "Hold E" pulsante
- **Enseña:** Mantener E para cargar Howl
- **Resultado:** Todos aturdidos, jugador puede escapar o eliminarlos

#### Sección 5: Moonlight Dash (1 min)
- **Gap grande** (imposible de saltar)
- **Plataforma al otro lado con enemigos**
- **Indicador:** "Shift" o ícono de dash
- **Enseña:** Dash para cruzar + atravesar enemigos
- **Resultado:** Genera shards extra al atravesar

#### Sección 6: Truth Door (30s)
- **Primera Truth Door** (requiere 2 verdades)
- **Diseño:** 2 False Enemies cerca para revelar
- **Enseña:** Necesitas revelar para progresar
- **Transición:** Puerta abierta → Level Goal → Level 1

---

## 📐 Estructura Sugerida del Tutorial

```
Tutorial.tscn
├── Spawn Point (jugador)
├── Section1_Movement
│   ├── Platforms (3-4 plataformas progresivas)
│   └── Visual Guide (flechas opcionales)
├── Section2_Reveal
│   ├── FalseEnemy1 (bloqueando)
│   └── RangeIndicator (círculo pulsante)
├── Section3_Shards
│   ├── FalseEnemy2 (generar shard)
│   ├── FalseFriend1 (objetivo)
│   └── NarrowPassage (fuerza usar shard)
├── Section4_Howl
│   ├── FalseFriend Group (3 enemigos)
│   └── TightSpace (rodean al jugador)
├── Section5_Dash
│   ├── BigGap (requiere dash)
│   └── EnemyCluster (generar shards)
├── Section6_Door
│   ├── TruthDoor (2 verdades)
│   ├── FalseEnemy3 y 4
│   └── LevelGoal
└── Camera Limits
```

---

## 🎨 Diseño Narrativo del Tutorial

### Concepto:
**"El Despertar del Lobo"** - La protagonista descubre sus poderes

### Ambiente:
- Espacio minimalista (enfoque en mecánicas)
- Visual: Gris nebuloso → Blanco brillante (claridad)
- Enemigos aparecen progresivamente (no todos a la vez)

### Sin Diálogos:
- Todo se enseña por **diseño de nivel** y **indicadores visuales**
- No NPCs explicando
- No paneles de texto largos
- Solo íconos de inputs cuando es necesario

---

## 🔧 Implementación Técnica

### Archivos a Crear:
1. **scenes/levels/tutorial.tscn** - Escena del tutorial
2. **scripts/tutorial/tutorial_manager.gd** - Script para triggers y progresión
3. **scripts/tutorial/input_hint.gd** - Sistema de hints visuales (opcional)

### Archivos a Modificar:
1. **scenes/main_menu.tscn** - Botón "Play" carga tutorial en lugar de Level 1
2. **scripts/autoloads/game_manager.gd** - Reconoce tutorial como nivel especial

### Mecánicas de Tutorial:
```gdscript
# tutorial_manager.gd (básico)
- Detectar cuando jugador completa cada sección (Areas trigger)
- Activar siguiente sección
- Spawns progresivos de enemigos
- Transición a Level 1 al completar
```

### Input Hints (opcional):
```gdscript
# input_hint.gd
- Label flotante con tecla/botón
- Aparece cuando el jugador está en rango
- Fade out cuando ejecuta la acción
- Adapta a teclado/gamepad automáticamente
```

---

## 📊 Checklist de Implementación

### Paso 1: Crear Escena Base
- [ ] Crear tutorial.tscn
- [ ] Añadir TileMap/Plataformas
- [ ] Colocar spawn point del jugador
- [ ] Configurar Camera2D con límites

### Paso 2: Secciones Básicas
- [ ] Sección 1: Plataformas de movimiento
- [ ] Sección 2: Primer False Enemy + reveal
- [ ] Transición entre secciones (smooth)

### Paso 3: Mecánicas Avanzadas
- [ ] Sección 3: Shards (revelar + lanzar)
- [ ] Sección 4: Howl (grupo de enemigos)
- [ ] Sección 5: Dash (gap + atravesar)

### Paso 4: Completar Tutorial
- [ ] Sección 6: Truth Door final
- [ ] Level Goal → transición a Level 1
- [ ] Testing completo del flujo

### Paso 5: Polish (Opcional)
- [ ] Input hints visuales
- [ ] Partículas de introducción
- [ ] Música/ambiente específico
- [ ] Ajustar timing de apariciones

---

## 🎯 Criterios de Éxito

**El tutorial es exitoso si:**
1. Un jugador nuevo puede completarlo en **3-5 minutos**
2. Entiende las **4 mecánicas principales** sin texto
3. No se siente como "clase", sino como **parte del juego**
4. La dificultad escala suavemente
5. Transiciona naturalmente a Level 1

---

## 💡 Tips de Diseño

**DO:**
- ✅ Enseñar por diseño de nivel (situaciones que requieren mecánicas)
- ✅ Una mecánica a la vez, en orden de complejidad
- ✅ Hacer que el jugador "descubra" los poderes
- ✅ Usar feedback visual (círculos, highlights)
- ✅ Permitir fallar sin penalización (respawn cercano)

**DON'T:**
- ❌ Texto largo explicando todo
- ❌ Múltiples mecánicas a la vez
- ❌ Forzar lectura de tutoriales
- ❌ Hacer el tutorial muy largo (>5 min)
- ❌ Desconectar del tone narrativo

---

## 🚀 Prompt de Inicio para Siguiente Sesión

**Copiar y pegar esto al inicio:**

```
Hola! Vamos a implementar el tutorial para VEIL.

Contexto rápido:
- Juego: Platformer "Big Bad Wolf" sobre revelar verdades
- Mecánicas: Reveal (E), Shards (Click Der), Howl (Hold E), Dash (Shift)
- Estado: Gameplay 100% funcional, falta tutorial

Objetivo: Crear nivel tutorial.tscn que enseñe las 4 mecánicas progresivamente en 3-5 minutos, sin texto excesivo, alineado con narrativa.

Tengo el documento NEXT_SESSION_TUTORIAL.md con toda la info. ¿Empezamos con la estructura básica del nivel o preferís que diseñemos el flujo primero?
```

---

## 📁 Archivos de Referencia

**Para entender el proyecto:**
- `NARRATIVE_DESIGN.md` - Narrativa "Big Bad Wolf"
- `COMBAT_MECHANICS_IMPLEMENTATION.md` - Mecánicas completas
- `FALSE_ENEMY_PATROL_FIX.md` - Cómo funcionan los enemigos

**Para implementar:**
- `scenes/levels/level_1.tscn` - Ejemplo de nivel
- `scripts/entities/*.gd` - Scripts de enemigos
- `scripts/level/level_goal.gd` - Transición entre niveles
- `scripts/level/truth_door.gd` - Puertas de verdades

---

## ⏱️ Estimación de Tiempo

**Implementación básica:** 2-3 horas
- Escena del tutorial: 1h
- Secciones y enemigos: 1h
- Testing y ajustes: 1h

**Con polish:** +1-2 horas
- Input hints: 30min
- Transiciones suaves: 30min
- Partículas/efectos: 30min
- Balance y timing: 30min

---

**Última actualización:** 2026-01-31
**Prioridad:** Alta (mejora onboarding)
**Complejidad:** Media

---

*"El lobo despierta. Es hora de enseñarle a cazar."* 🐺
