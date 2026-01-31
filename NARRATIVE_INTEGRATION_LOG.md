# VEIL - Log de Integración Narrativa

**Fecha:** 2026-01-31
**Estado:** ✅ COMPLETADO
**Tema:** "Big Bad Wolf" - Transformación de víctima a cazadora

---

## 📋 Resumen Ejecutivo

Se ha integrado exitosamente la narrativa cohesiva "Big Bad Wolf" en el juego VEIL, transformándolo de un platformer abstracto sobre "revelar máscaras" a una historia de **empoderamiento y confrontación de verdades**.

**Cambio conceptual:**
- **ANTES:** Juego sobre revelar máscaras (abstracto)
- **AHORA:** Historia de transformación (víctima → cazadora)

---

## ✅ Integraciones Completadas

### 1. ENDINGS (Pantalla Final) ✅

**Archivo:** `scripts/ui/ending_screen.gd`

#### ENDING 1: "The Comfortable Lie" (< 50%)
```
Color: Gris (mediocridad)
Mensaje clave: "Volviste a ponerte la máscara"
Tema: Evitar la verdad perpetúa el sistema
```

**Texto actualizado:**
- Más directo y brutal
- Formato de versos cortos (impacto visual)
- Metáforas de máscaras y sistemas
- Sin concesiones ("eres parte del sistema ahora")

---

#### ENDING 2: "The Painful Truth" (50-80%)
```
Color: Azul (verdad fría)
Mensaje clave: "Vives con la verdad. Y duele."
Tema: La verdad libera pero tiene costo emocional
```

**Texto actualizado:**
- Enfatiza el dolor del conocimiento
- Reconoce que revelaste False Enemies (víctimas) y False Friends (depredadores)
- Balance: No fuiste completista, pero viste suficiente
- Tono melancólico

---

#### ENDING 3: "The Big Bad Wolf" (> 80%)
```
Color: Blanco puro (verdad absoluta)
Mensaje clave: "Eres el lobo ahora. El bosque te pertenece."
Tema: Empoderamiento total por confrontar toda la verdad
```

**Texto actualizado:**
- Lenguaje de empoderamiento ("No fuiste amable. No perdonaste nada.")
- Triple estructura: Depredadores temieron, Víctimas admiraron, Sistema colapsó
- Transformación completa: Niña asustada → Lobo
- **Referencias directas:** "I'm not your victim anymore / I'm the big bad wolf now"

---

### 2. COMENTARIOS EN CÓDIGO ✅

**Archivos actualizados con narrativa:**

#### `scripts/entities/false_enemy.gd`
```gdscript
## FALSE ENEMY - "Las Víctimas" (Tipo 1)
##
## NARRATIVA: Víctimas que adoptaron máscaras agresivas para protegerse.
##           "Parezco peligroso para que me dejen en paz."
##
## PREGUNTA: "¿Cuántos 'enemigos' son realmente víctimas disfrazadas?"
```

**Propósito:** El programador entiende la narrativa al leer el código

---

#### `scripts/entities/false_friend.gd`
```gdscript
## FALSE FRIEND - "Los Depredadores" (Tipo 2)
##
## NARRATIVA: Manipuladores que usan máscaras de amabilidad para cazar.
##           "Confía en mí... no te haría daño..." (mentira)
##
## PREGUNTA: "¿Cuántos 'aliados' están esperando el momento de atacar?"
## CONEXIÓN: Estos victimizaron a la protagonista antes.
```

**Propósito:** Conexión personal con la protagonista (venganza/justicia)

---

#### `scripts/entities/true_threat.gd`
```gdscript
## TRUE THREAT - "El Sistema" (Tipo 3)
##
## NARRATIVA: Estructuras e instituciones que perpetúan las mentiras.
##           "Siempre estuvieron ahí, solo que no los veías como amenaza."
##
## PREGUNTA: "¿Qué pasa cuando revelas las estructuras de poder?"
## FUNCIÓN: El juego FUERZA a revelarlos - no puedes ignorar el sistema.
```

**Propósito:** Metáfora de sistemas opresivos que parecen neutrales

---

#### `scripts/core/player_controller.gd`
```gdscript
## LA REVELADORA - "The Wolf"
##
## NARRATIVA: Ex-víctima transformada en cazadora.
##           "I'm not your victim anymore. I'm the big bad wolf now."
```

**Propósito:** Identidad clara del personaje jugable

---

#### `scripts/core/reveal_system.gd`
```gdscript
## Sistema de Revelación - "Arrancar el Velo"
##
## NARRATIVA: El poder de la protagonista para revelar verdades ocultas.
##           Arrancar velos = Confrontar la verdad sin filtros.
##           No cambia a las personas, revela lo que siempre fueron.
```

**Propósito:** La mecánica core como metáfora narrativa

---

### 3. UI VISUAL (Ya Existente) ✅

**Archivo:** `scenes/main_menu.tscn`

```
LOGO: "VEIL" (fuente grande gótica)
TAGLINE: "Tear the veil. Face the truth."
```

**Estado:** Ya implementado correctamente desde sesión anterior

---

### 4. UI TEXTS (Recién Actualizado) ✅

**Archivos actualizados con lenguaje narrativo:**

#### `scripts/ui/game_over.gd`
```gdscript
// ANTES: "Verdades reveladas: %d / %d"
// AHORA: "Velos Arrancados: %d / %d"
```

**Cambio:** "Verdades" → "Velos Arrancados" (más dramático, referencia al tema de arrancar velos)

---

#### `scripts/ui/victory_screen.gd`
```gdscript
// ANTES:
// - "Truths Revealed: %d / %d"
// - "Completion: %.0f%%"
// - "Rank: %s"

// AHORA:
// - "Veils Torn: %d / %d"
// - "Truth Rate: %.0f%%"
// - "S - The Wolf" / "A - Revelator" / "B - Awakening" / "C - Hesitant" / "D - Blinded"
```

**Cambios:**
- "Truths Revealed" → "Veils Torn" (acción concreta)
- "Completion" → "Truth Rate" (más específico al tema)
- Ranks con descriptores narrativos:
  - **S (100%)**: "The Wolf" - Empoderamiento total
  - **A (80%+)**: "Revelator" - Casi completo
  - **B (60%+)**: "Awakening" - Despertando a la verdad
  - **C (40%+)**: "Hesitant" - Dudoso/incompleto
  - **D (<40%)**: "Blinded" - Ciego a la verdad

---

#### `scripts/ui/hud.gd`
```gdscript
// ANTES: "Verdades: %d / %d"
// AHORA: "Velos: %d / %d"
```

**Cambio:** Texto más corto y directo, referencia al tema de velos

---

#### `scripts/level/level_goal.gd`
```gdscript
// ANTES:
// - "GOAL!"
// - "Need %d truths"

// AHORA:
// - "ESCAPE"
// - "Tear %d veils"
```

**Cambios:**
- "GOAL!" → "ESCAPE" (refuerza sensación de urgencia/liberación)
- "Need truths" → "Tear veils" (imperativo activo, más dramático)

---

### 5. COLOR CODING VISUAL (Ya Implementado) ✅

**Archivos:** `scripts/core/reveal_system.gd`, `scripts/utils/particle_effects.gd`

| Elemento | Color | Significado Narrativo |
|----------|-------|----------------------|
| **Player** | Blanco puro | Verdad absoluta, claridad |
| **False Enemy revelado** | Azul pálido | Tristeza, vulnerabilidad (víctimas) |
| **False Friend revelado** | Rojo violento | Peligro, ira (depredadores) |
| **True Threat revelado** | Púrpura oscuro | Corrupción, poder (sistema) |
| **Enmascarados** | Gris neutral | Ambigüedad, mentira |

**Implementación:**
- ✅ Flash de pantalla con color según tipo (reveal_system.gd:167-189)
- ✅ Partículas específicas por tipo (particle_effects.gd)
- ✅ Detección automática con `_is_true_threat()` (reveal_system.gd:293-308)

---

### 6. PARTÍCULAS NARRATIVAS (Ya Implementado) ✅

**Archivo:** `scripts/utils/particle_effects.gd`

```gdscript
spawn_reveal_particles_typed(pos, is_true_threat)
  → Partículas azules para False Enemy
  → Partículas rojas para True Threat

spawn_transform_particles(pos, from_color, to_color)
  → Ring mágico: Gris enmascarado → Color revelado
  → Representa transformación/revelación
```

**Integración:** Enemigos llaman estas funciones al ser revelados (false_enemy.gd:100-105, true_threat.gd:52-57)

---

## 📊 Tabla de Cohesión Narrativa

| Elemento del Juego | Metáfora Narrativa | Implementación |
|--------------------|--------------------|----------------|
| **Player Character** | La Reveladora / The Wolf | Comentarios + poder de revelar |
| **Arrancar Velo (E)** | Confrontar verdad directamente | RevealSystem + comentarios |
| **False Enemy** | Víctimas con máscaras defensivas | Comentarios + color azul |
| **False Friend** | Depredadores con máscaras amigables | Comentarios + color rojo |
| **True Threat** | Sistema opresor disfrazado | Comentarios + color púrpura |
| **Puertas de Verdades** | Progreso requiere honestidad | Mecánica + diseño de nivel |
| **Endings** | Consecuencias de tus elecciones | Textos narrativos |
| **Color Coding** | Identificación visual de verdades | Flash + partículas |

---

## 🎯 Impacto Narrativo por Sistema

### Sistema de Revelación
**Antes:** Mecánica abstracta de "arrancar máscaras"
**Ahora:** Poder de confrontar verdad = Metáfora de empoderamiento

**Integración:**
- Comentarios explican que "no cambia a las personas, revela lo que siempre fueron"
- Cooldown = Confrontar verdades es agotador
- Rango limitado = Solo controlas tu entorno inmediato

---

### Sistema de Enemigos
**Antes:** Tipos genéricos (Falso, Verdadero, etc.)
**Ahora:** Arquetipos sociales (Víctimas, Depredadores, Sistema)

**Integración:**
- Cada tipo plantea una pregunta filosófica en comentarios
- Color coding refuerza identidad visual
- Comportamiento refleja metáfora (víctimas huyen, depredadores persiguen)

---

### Sistema de Endings
**Antes:** Mensajes genéricos sobre % de revelación
**Ahora:** Consecuencias narrativas profundas de tus elecciones

**Integración:**
- Lenguaje directo y brutal (no condescendiente)
- Referencias a "Big Bad Wolf" en ending máximo
- Cada ending tiene tono emocional distinto (resignación, melancolía, triunfo)

---

## 🎨 Elementos Visuales Pendientes (Artista)

### Alta Prioridad
- [ ] Sprite del Player como "La Reveladora" (mujer confiada, capa, garras etéreas)
- [ ] Sprites de enemigos con diseño narrativo:
  - [ ] False Enemy: Máscara agresiva → Rostro asustado
  - [ ] False Friend: Sonrisa perfecta → Monstruo con garras
  - [ ] True Threat: Estatua gris → Horror eldritch púrpura

### Media Prioridad
- [ ] Ilustraciones de endings (3):
  - [ ] IGNORANCE: De espaldas, poniéndose máscara
  - [ ] AWAKENING: Cansada, lágrimas, mirando atrás
  - [ ] REVELATION: Triunfante, de pie sobre velos rotos

### Baja Prioridad
- [ ] Evolución visual del player (postura más confiada según progreso)
- [ ] Animación de transformación de False Friend (máscara rompiéndose)

---

## 📝 Frases Clave Integradas

```
"Tear the veil. Face the truth."
  → Main Menu tagline

"I'm not your victim anymore. I'm the big bad wolf now."
  → Ending REVELATION

"Los depredadores te temieron. Las víctimas te admiraron. El sistema... colapsó."
  → Ending REVELATION

"Ya no eres la niña asustada. Ya no eres la víctima."
  → Ending REVELATION

"Volviste a ponerte la máscara."
  → Ending IGNORANCE

"Vives con la verdad. Y duele."
  → Ending AWAKENING

"Velos Arrancados"
  → Game Over Screen

"Veils Torn" / "Truth Rate"
  → Victory Screen

"The Wolf" / "Revelator" / "Awakening" / "Hesitant" / "Blinded"
  → Victory Screen Ranks

"ESCAPE" / "Tear %d veils"
  → Level Goal

"Parezco peligroso para que me dejen en paz."
  → False Enemy (comentario)

"Confía en mí... no te haría daño..."
  → False Friend (comentario)

"Siempre estuvieron ahí, solo que no los veías como amenaza."
  → True Threat (comentario)
```

---

## ✅ Checklist de Integración Narrativa

### Código
- [x] Comentarios actualizados en todos los enemigos
- [x] Comentarios actualizados en player_controller
- [x] Comentarios actualizados en reveal_system
- [x] Endings reescritos con narrativa "Big Bad Wolf"
- [x] Color coding implementado (flash + partículas)

### UI
- [x] Tagline en Main Menu
- [x] Nombres de endings actualizados
- [x] Textos de endings actualizados
- [x] Textos de Game Over actualizados
- [x] Textos de Victory Screen actualizados
- [x] Textos de HUD actualizados
- [x] Textos de Level Goal actualizados

### Documentación
- [x] NARRATIVE_DESIGN.md creado (diseño narrativo completo)
- [x] ART_REFERENCE_GUIDE.md creado (guía para artista)
- [x] NARRATIVE_INTEGRATION_LOG.md creado (este documento)

### Visual (Pendiente - Artista)
- [ ] Sprites de personajes con identidad narrativa
- [ ] Ilustraciones de endings
- [ ] Animaciones de transformación

---

## 🎯 Próximos Pasos

### Inmediato (Programación)
1. ✅ **COMPLETADO** - Integración narrativa en código y comentarios
2. ✅ **COMPLETADO** - Integración de UI texts con lenguaje narrativo
3. Testing de endings (verificar que se muestren correctamente)
4. Ajustar color coding si es necesario (feedback visual)

### Corto Plazo (Arte)
1. Artista lee ART_REFERENCE_GUIDE.md
2. Concept sketches de personajes principales
3. Aprobación de diseños
4. Producción de sprites finales

### Largo Plazo (Pulido)
1. Audio narrativo (SFX que refuercen identidad de enemigos)
2. Música temática (inspirada en "Big Bad Wolf")
3. Tutorial implícito que introduce narrativa

---

## 📊 Métricas de Cohesión

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Identidad del Player** | Genérica | "La Reveladora / The Wolf" |
| **Identidad de Enemigos** | Mecánica | Arquetipos sociales |
| **Endings** | Mensajes genéricos | Narrativa impactante |
| **Color Coding** | Decorativo | Significado narrativo |
| **Comentarios en código** | Técnicos | Narrativos + técnicos |
| **Experiencia del jugador** | Platformer abstracto | Historia de empoderamiento |

---

## 💬 Feedback Esperado del Jugador

**Al inicio:**
*"Es un platformer sobre revelar máscaras."*

**A mitad del juego:**
*"Espera... los 'enemigos' no son enemigos. Los 'aliados' no son aliados."*

**Al final (Ending REVELATION):**
*"WOW. Esto es sobre empoderamiento. Sobre no ser víctima. Soy el lobo ahora."*

**Después de rejugar:**
*"Cada enemigo es una metáfora social. Esto es más profundo de lo que pensaba."*

---

## 🎬 Visión Completada

El juego ahora cuenta una historia cohesiva sin usar diálogos:

1. **Setup:** Eres alguien que fue victimizada en un mundo de máscaras
2. **Confrontación:** Obtienes poder de revelar verdades
3. **Revelación:** Descubres que víctimas parecían amenazantes, depredadores parecían amigables
4. **Resolución:** Tu elección de cuánto revelar define quién eres

**Mensaje central:** La verdad libera, pero tiene un costo. Confrontarla completamente es empoderamiento.

---

**Última actualización:** 2026-01-31 (UI Texts)
**Estado:** Integración narrativa COMPLETA (código + UI)
**Pendiente:** Arte visual (sprites + ilustraciones)

---

*"Ya no eres la víctima. Eres el lobo ahora."*
