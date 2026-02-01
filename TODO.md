# VEIL - TODO List

## Estado del Proyecto: Alpha 0.6.1

### ✅ Completado (Core Gameplay)

**Mecánicas Fundamentales:**
- ✅ Movimiento del jugador (walk, jump, coyote time, jump buffer)
- ✅ Sistema de revelación de velos
- ✅ Sistema de daño y HP (5 HP + iFrames)
- ✅ Sistema de verdades y progresión
- ✅ Muerte y respawn

**Enemigos (9 tipos):**
- ✅ FalseEnemy (patrulla, huye al revelar)
- ✅ FalseEnemyFast (patrulla rápida)
- ✅ FalseFriend (parece amigo, te persigue al revelar)
- ✅ FalseFriendJumper (salta hacia ti)
- ✅ TrueThreat (torreta básica)
- ✅ TrueThreatTracking (torreta que te sigue)
- ✅ TrueThreatBurst (ráfagas de 3 proyectiles)
- ✅ TrueThreatLaser (láser continuo con telegraph)
- ✅ TrueThreatShield (requiere 2 revelaciones)

**Niveles:**
- ✅ Level 1 (tutorial, 6 verdades)
- ✅ Level 2 (advanced, 12 verdades)
- ✅ Level 3 (finale, 17 verdades)
- ✅ Todos los niveles con diseño completo de áreas

**UI & Screens:**
- ✅ Main Menu
- ✅ HUD (HP, verdades, indicador de rango)
- ✅ Pause Menu
- ✅ Game Over Screen
- ✅ Victory Screen (con ranking S/A/B/C/D)
- ✅ Ending Screen (3 endings basados en %)

**Sistemas:**
- ✅ GameManager (estado global)
- ✅ AudioManager (sistema, sin assets)
- ✅ SceneTransition (fade in/out)
- ✅ ProjectileManager (evita memory leaks)
- ✅ iFrames (invencibilidad temporal)
- ✅ Sistema de puertas de verdades
- ✅ Sistema de endings múltiples

**Controls:**
- ✅ Teclado (WASD + flechas + Space + E)
- ✅ Gamepad (Xbox, PS, Switch)

**Performance:**
- ✅ Optimizaciones de CPU (~85% reducción)
- ✅ Sistema de off-screen culling

---

## 🔴 CRÍTICO (Bloquea Release)

### 1. Audio Assets Reales

**Estado:** Usando placeholders que causan warnings

**Necesario:**
- [ ] Música de fondo (loop)
  - Main Menu theme
  - Level ambient track
  - Ending theme
- [ ] SFX esenciales:
  - Jump
  - Land
  - Reveal veil
  - Damage
  - Death
  - Door opening
  - Level complete
  - Projectile fire
  - Laser charge

**Recursos:**
- Freesound.org (CC0/CC-BY)
- OpenGameArt.org
- SFXR/Bfxr para SFX sintéticos

**Prioridad:** 🔴 ALTA

---

## 🟡 IMPORTANTE (Mejora Calidad)

### 2. Arte Visual

**Estado:** Usando placeholders (cuadrados de colores)

**Necesario:**
- [ ] Sprites del jugador
  - Idle animation
  - Walk cycle
  - Jump sprite
  - Reveal animation
- [ ] Sprites de enemigos (9 tipos)
  - Estados enmascarado/revelado
  - Animaciones básicas
- [ ] Sprites de proyectiles
- [ ] Backgrounds de niveles (parallax opcional)
- [ ] UI elements (corazones de HP, íconos)

**Recursos:**
- Aseprite/Piskel para pixel art
- OpenGameArt.org para assets CC0
- Considerar estilo minimalista para mantener coherencia

**Prioridad:** 🟡 MEDIA-ALTA

### 3. Polish & Juice

**Estado:** Básico implementado, falta refinamiento

**Nice to Have:**
- [ ] Partículas en revelaciones
  - Burst de partículas al revelar
  - Trail en proyectiles
  - Dust particles al aterrizar
- [ ] Screen shake mejorado
  - Shake al recibir daño
  - Shake al revelar enemigos
  - Shake en explosiones
- [ ] Chromatic aberration en revelaciones
- [ ] Freeze frames en momentos clave
- [ ] Vibración de gamepad
  - Al recibir daño
  - Al revelar
  - Al romper escudo

**Prioridad:** 🟡 MEDIA

### 4. Menú de Opciones Funcional

**Estado:** Botón "Options" deshabilitado

**Necesario:**
- [ ] Volume sliders
  - Master volume
  - Music volume
  - SFX volume
- [ ] Controls display/remapping
  - Mostrar controles actuales
  - Opción de remapear (opcional)
- [ ] Graphics settings (opcional)
  - Fullscreen toggle
  - Resolution
  - VSync
- [ ] Guardar settings (ConfigFile)

**Prioridad:** 🟡 MEDIA

---

## 🟢 OPCIONALES (Post-Launch)

### 5. Tutorial Mejorado

**Estado:** Level 1 funciona como tutorial básico

**Mejoras opcionales:**
- [ ] Pop-ups explicativos
- [ ] Tooltips en primera interacción
- [ ] Practice area sin consecuencias
- [ ] Skip tutorial option

**Prioridad:** 🟢 BAJA

### 6. Stats & Achievements

**Estado:** No implementado

**Ideas:**
- [ ] Stats tracking
  - Tiempo total jugado
  - Muertes totales
  - Perfect runs
  - Speedrun times
- [ ] Achievements simples
  - Completar cada nivel
  - 100% en cada nivel
  - No damage run
  - Speed completions

**Prioridad:** 🟢 BAJA

### 7. Save System

**Estado:** No hay saves, juego siempre empieza desde inicio

**Opcional:**
- [ ] Save progress (nivel desbloqueado)
- [ ] Save settings
- [ ] Save best times/scores

**Nota:** Para un juego de 3 niveles cortos, puede no ser necesario

**Prioridad:** 🟢 BAJA

### 8. Créditos

**Estado:** No hay pantalla de créditos

**Necesario:**
- [ ] Credits screen
  - Game by [Nombre]
  - Powered by Godot 4.4
  - Assets credits (si usas assets de terceros)
  - Special thanks

**Prioridad:** 🟢 BAJA-MEDIA

### 9. Content Adicional (Post-Launch)

**Ideas para expansión futura:**
- [ ] Boss fights
  - Boss en cada nivel
  - Patrones de ataque únicos
- [ ] Power-ups
  - Extra HP
  - Reveal range increase
  - Tiempo de iFrames extendido
- [ ] Challenge modes
  - Time attack
  - No damage mode
  - Limited reveals
- [ ] Más niveles (Level 4+)
- [ ] New Game+ con mayor dificultad

**Prioridad:** 🟢 POST-LAUNCH

---

## 🔧 TECHNICAL DEBT

### 10. Code Cleanup

**Tareas de mantenimiento:**
- [ ] Remover archivos de debug
  - `true_threat_DEBUG.gd`
  - `DEBUG_LEVEL3_SHOOTING.md`
  - Otros archivos *.md de troubleshooting
- [ ] Consolidar documentación
  - Un solo README completo
  - Mover docs técnicos a carpeta `/docs`
- [ ] Verificar TODOs en código
  - Buscar `# TODO` en todos los scripts
  - Completar o remover

**Prioridad:** 🟢 BAJA

### 11. Testing & QA

**Testing necesario antes de release:**
- [ ] Playtest completo de inicio a fin
  - Verificar todos los 3 niveles
  - Probar todos los endings
  - Verificar balance
- [ ] Bug testing
  - Colisiones raras
  - Soft locks
  - Crashes
- [ ] Performance testing
  - FPS en diferentes hardware
  - Memory leaks
- [ ] Input testing
  - Teclado completo
  - Cada tipo de gamepad
- [ ] Edge cases
  - Qué pasa si revelas todo muy rápido
  - Qué pasa si nunca revelas nada
  - Sequence breaking

**Prioridad:** 🔴 ALTA (antes de release)

---

## 📅 Roadmap Sugerido

### Milestone 1: "Playable Beta" (1-2 días)
**Objetivo:** Juego jugable de inicio a fin con audio básico

- [ ] Agregar audio assets (música + SFX básicos)
- [ ] Playtest completo y bug fixing
- [ ] Testing de gamepad

**Resultado:** Juego 100% funcional, pero con arte placeholder

---

### Milestone 2: "Visual Polish" (2-3 días)
**Objetivo:** Mejorar presentación visual

- [ ] Sprites del jugador
- [ ] Sprites de enemigos básicos
- [ ] UI elements mejorados
- [ ] Partículas básicas

**Resultado:** Juego con identidad visual propia

---

### Milestone 3: "Release Candidate" (1 día)
**Objetivo:** Preparar para release

- [ ] Menú de opciones funcional
- [ ] Créditos
- [ ] Testing exhaustivo
- [ ] Fix de bugs finales
- [ ] Vibración de gamepad (opcional)

**Resultado:** Listo para publicar

---

### Post-Launch (Opcional)
- [ ] Content updates
- [ ] Boss fights
- [ ] More levels
- [ ] Community feedback implementation

---

## 🎯 Mínimo Viable Product (MVP)

**Para considerar el juego "completo" y listo para publicar:**

✅ **Mecánicas Core:** Completadas
✅ **3 Niveles:** Completados
✅ **Sistema de Endings:** Completado
✅ **Controls (KB+Gamepad):** Completados
🔴 **Audio Real:** FALTA (crítico)
🟡 **Arte Visual:** FALTA (importante)
🟡 **Opciones:** FALTA (importante)
🟢 **Créditos:** FALTA (nice to have)

**Estimación para MVP completo:** 3-5 días de trabajo enfocado

---

## 💡 Recomendaciones

**Si tienes tiempo limitado (Game Jam style):**
1. **Prioridad absoluta:** Audio assets reales
2. **Segunda prioridad:** Arte pixel art simple
3. **Tercera prioridad:** Testing exhaustivo
4. **Omitir:** Stats, achievements, content extra

**Si quieres un producto pulido:**
1. Hacer todo en orden del roadmap
2. Invertir tiempo en polish (partículas, vibración)
3. Agregar menú de opciones completo
4. Considerar content adicional post-launch

**Mi recomendación personal:**
- Enfócate en **Milestone 1** primero (audio + testing)
- Luego **Milestone 2** (arte básico)
- Finalmente **Milestone 3** (opciones + créditos)
- Post-launch opcional según feedback

---

**Última actualización:** 2026-01-31
**Versión actual:** Alpha 0.6.1
**Estado:** Core gameplay completo, falta audio/arte
