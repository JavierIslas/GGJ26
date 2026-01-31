# VEIL - Game Design Document

**Global Game Jam 2026 | Tema: "Máscara"**

---

## 📋 Información del Proyecto

**Título:** VEIL
**Tagline:** *"Tear the veil. Face the truth."*
**Género:** Platformer 2D con mecánica de revelación
**Plataforma:** PC (Windows/Linux)
**Engine:** Godot 4.x
**Duración estimada:** 10-15 minutos (3 niveles)
**Timeframe:** 48 horas (Game Jam)

**Equipo:**
- 1 Programador (conocimiento avanzado)
- 1 Artista (papel y lápiz, estilo tradicional)
- 1 Diseñador (conocimiento básico)
- 0 Audio (usar assets gratuitos/generados)

---

## 🎯 Concepto Central

### Pitch de Una Línea
*Un platformer oscuro donde arrancas las máscaras de un mundo hipócrita para revelar la verdadera naturaleza de sus habitantes.*

### Concepto Extendido
En **VEIL**, el jugador posee el poder de "arrancar el velo" de las personas enmascaradas para revelar su verdadera naturaleza. Los enemigos aparentemente amenazantes pueden ser víctimas asustadas, mientras que los aliados amigables pueden ser monstruos disfrazados.

Cada revelación tiene consecuencias: puedes liberar un camino bloqueado, pero también crear nuevos enemigos. El juego explora temas de hipocresía, dualidad y el costo de confrontar la verdad.

### Inspiración Temática
- **Musical:** In This Moment (canciones "Whore", "The In-Between")
  - Temas: Empoderamiento, revelación de verdades ocultas, romper máscaras sociales
  - Estética: Gótica, oscura, confrontacional
- **Visual:** Darkest Dungeon, Limbo, Return of the Obra Dinn
- **Mecánica:** Celeste (platforming), Obra Dinn (revelación/deducción)

---

## 🎮 Mecánicas Core

### 1. Movimiento del Jugador

**Controles Básicos:**
- `A/D` o `←/→`: Caminar (izquierda/derecha)
- `Espacio` o `W` o `↑`: Saltar
- `E` o `Espacio` (cerca de entidad): Arrancar velo

**Características del Movimiento:**
- Velocidad de caminata: 150 px/s
- Velocidad de salto: -400 px/s (impulso inicial)
- Gravedad: 980 px/s²
- **Coyote Time:** 0.15s (perdón al salir de plataformas)
- **Jump Buffer:** 0.1s (registro de input antes de aterrizar)

### 2. Mecánica "Tear the Veil" (Arrancar el Velo)

**Condiciones para Activar:**
- Jugador presiona tecla de acción (`E` o `Espacio`)
- Debe estar dentro del rango de revelación: **32 píxeles** (~1 tile)
- Entidad debe tener componente `VeilComponent` (no revelada previamente)
- Cooldown global: **0.5 segundos** (evita spam)

**Secuencia de Revelación:**

```
[Frame 0]     Input detectado → Sistema verifica rango
[Frame 1-10]  Animación de "grab" del jugador (0.15 seg)
[Frame 11]    Jugador "arranca" el velo de la entidad
[Frame 12-25] Animación de revelación de la entidad (0.25 seg):
              ├── Particle effect: Fragmentos de máscara cayendo
              ├── Screen shake leve (trauma = 0.3)
              ├── SFX: Sonido de tela rasgándose + reverb
              └── Entidad cambia de sprite (masked → revealed)
[Frame 26+]   Entidad ejecuta su comportamiento "revelado"
```

**Feedback Visual al Jugador:**
- **Indicador de rango:** Aro blanco alrededor de entidades cercanas revelables
- **Cursor cambia:** Cuando está en rango (mano abierta → mano cerrada)
- **Al revelar:** Flash blanco en pantalla (0.1 seg, 30% opacity)
- **Jugador bloqueado:** No puede moverse durante 0.4s de animación total

---

## 👥 Tipos de Entidades Enmascaradas

### TIPO 1: "Falso Enemigo" (False Threat)

**Apariencia ENMASCARADA:**
- **Sprite:** Figura humanoide agresiva, postura amenazante
- **Colores:** Rojos/negros oscuros
- **Comportamiento:**
  - Patrulla de izquierda-derecha (velocidad: 50 px/s)
  - Si jugador se acerca (rango: 64px) → persigue lentamente
- **Daño:** NO puede dañar (pero jugador no lo sabe)
- **Audio:** Gruñidos bajos, pisadas pesadas

**Apariencia REVELADA:**
- **Sprite:** Persona asustada, encogida, manos en rostro
- **Colores:** Grises/azules pálidos
- **Aura:** Azul pálida
- **Comportamiento:**
  - Se detiene, tiembla en su lugar
  - Si jugador se acerca (32px) → huye en dirección opuesta
  - Velocidad de huida: 100 px/s
- **Audio:** Sollozos, respiración entrecortada
- **Partículas:** Lágrimas ocasionales

**Función en Puzzle:**
- Bloquean pasillos estrechos
- Al revelarlos, huyen y abren camino
- Si jugador intenta saltar sobre ellos sin revelar → knockback leve (asustan)

---

### TIPO 2: "Falso Aliado" (False Friend)

**Apariencia ENMASCARADA:**
- **Sprite:** Figura amigable, brazos abiertos
- **Colores:** Amarillos/naranjas cálidos
- **Comportamiento:**
  - Estático, hace señas de "ven aquí"
  - Puede sostener objeto brillante (cebo visual)
- **Diálogo:** Texto sobre cabeza: "¡Ayuda!" o "Por aquí"
- **Audio:** Voz amistosa, risa suave

**Apariencia REVELADA:**
- **Sprite:** Criatura monstruosa, dientes afilados, garras
- **Colores:** Rojos violentos, negros profundos
- **Aura:** Roja intensa, ojos brillantes
- **Comportamiento:**
  - Se convierte en enemigo agresivo real
  - Persigue al jugador (velocidad: 120 px/s)
  - **Daño por contacto:** -1 HP
  - **Ataque:** Melee, salta hacia jugador si está cerca (rango: 48px)
- **Audio:** Rugido, gruñidos agresivos
- **Animación:** Sacude cabeza al aparecer ("rugido")

**Función en Puzzle:**
- Guardando interruptores o items
- Revelarlos activa combate/peligro
- Decisión: ¿Vale la pena el riesgo por la recompensa?

---

### TIPO 3: "Verdadero Enemigo" (True Threat)

**Apariencia ENMASCARADA:**
- **Sprite:** Ambiguo, puede parecer objeto inanimado
  - Estatua, maniquí, armadura vacía
- **Colores:** Neutros, grises, piedra
- **Comportamiento:** Completamente estático (parece decoración)
- **Audio:** Silencio inquietante

**Apariencia REVELADA:**
- **Sprite:** Enemigo peligroso, aspecto eldritch
  - Tentáculos, ojos múltiples, formas imposibles
- **Colores:** Púrpuras oscuros, negros con brillo
- **Aura:** Púrpura pulsante
- **Comportamiento:**
  - Se "despierta" pero permanece estático (torreta biológica)
  - Dispara proyectiles lentos hacia jugador
  - Cadencia: 1 proyectil cada 2 segundos
  - **Daño por proyectil:** -2 HP
  - NO se mueve de su posición
- **Audio:** Pulsos orgánicos, sonidos viscerales
- **Animación Idle:** Respiración inquietante

**Función en Puzzle:**
- Peligros que el jugador crea al revelar
- Algunos niveles fuerzan revelaciones (puertas que requieren X verdades)
- Elección estratégica: ¿CUÁLES revelar para minimizar peligro?

---

### TIPO 4: "Inocente Real" (True Innocent)
**Aparece solo en niveles avanzados (Nivel 3 o stretch goal)**

**Apariencia ENMASCARADA:**
- **Sprite:** Similar a Falso Enemigo (amenazante)
- **Comportamiento:** Patrulla agresivamente, pero NO persigue

**Apariencia REVELADA:**
- **Sprite:** Niño o criatura indefensa
- **Colores:** Blancos, grises muy pálidos
- **Aura:** Sin aura (o blanca tenue)
- **Comportamiento:** Se sienta y llora, no interactúa
- **Audio:** Llanto suave

**Función:**
- **Narrativa:** Representan víctimas de hipocresía
- **Gameplay:** Revelarlos NO cambia nada mecánicamente
- **Meta:** Afecta "ending" del juego (ver Sistema de Verdades)

---

## 🧩 Sistemas de Juego

### Sistema de "Verdades" (Truth Counter)

**HUD Display:**
- Ubicación: Esquina superior derecha
- Icono: Ojo abierto
- Formato: `Verdades: X / Y`
  - X = Verdades reveladas en el nivel actual
  - Y = Total de entidades revelables en el nivel

**Mecánica:**
- Cada revelación incrementa el contador
- Algunas puertas/mecanismos requieren mínimo de verdades
  - Ejemplo: "Revela 5 verdades para activar la salida"
- **NO hay penalización directa** por revelar "mal"
  - Pero revelar Falso Aliado = crear enemigo
  - Revelar Verdadero Enemigo = activar peligro permanente

**Meta-Juego:**
- Contador total acumulado entre niveles
- Afecta ending final del juego:
  - < 50% verdades: Ending "Ignorancia" (sigue viviendo en la mentira)
  - 50-80%: Ending "Despertar" (conoces la verdad, pero a qué costo)
  - > 80%: Ending "Revelador" (confrontaste todas las verdades)

---

### Sistema de Salud (Opcional - Día 2)

**Implementación Básica:**
- **HP inicial:** 3 corazones
- **Fuentes de daño:**
  - Falso Aliado revelado (contacto): -1 HP
  - Verdadero Enemigo (proyectil): -2 HP
- **Checkpoints:** Mitad de niveles largos
- **Muerte:** Reinicio desde último checkpoint
- **Curaciones:** NO hay (scope limitado)

**Visual:**
- 3 corazones en esquina superior izquierda
- Corazón lleno / corazón vacío (sprites simples)

---

### Sistema de Power-Ups (Opcional - Stretch Goal)

#### Power-Up 1: "Visión Clara" (Clear Sight)
- **Sprite:** Objeto cristalino brillante
- **Obtención:** Áreas secretas, plataformas ocultas
- **Efecto:** Durante 10 segundos, TODAS las entidades enmascaradas muestran silueta de su forma revelada
- **Uso estratégico:** Planificar qué revelar antes de hacerlo
- **Visual:** Pantalla con efecto de "rayos X" tenue, tinte azul

#### Power-Up 2: "Grito de Revelación" (Revelation Scream)
- **Sprite:** Símbolo de onda sonora
- **Obtención:** Recompensa por revelar X verdades consecutivas
- **Efecto:** Uso único, revela TODAS las entidades en pantalla simultáneamente
- **Consecuencia:** Si hay muchos Verdaderos Enemigos, caos total
- **Visual:** Onda expansiva desde jugador, screen shake intenso (trauma = 0.8)

---

## 🗺️ Diseño de Puzzles

### Puzzle Tipo A: "Camino Bloqueado"

```
SETUP:
├── Pasillo estrecho (3 tiles de ancho)
├── 3 Falsos Enemigos patrullando
├── Jugador no puede pasar sin contacto

SOLUCIÓN:
├── Revelar a los 3 → Huyen → Camino despejado
├── Costo: 3 revelaciones del contador
└── Alternativa (día 2): Salto preciso sobre ellos (speedrun strat)
```

**Niveles que usan este puzzle:** Nivel 1 (tutorial implícito)

---

### Puzzle Tipo B: "Elección de Interruptores"

```
SETUP:
├── 4 pedestales con entidades enmascaradas
├── Plataformas móviles activadas por "peso" de entidades reveladas
├── Puerta requiere 2 interruptores activados simultáneamente

SOLUCIÓN:
├── Revelar 2 Falsos Aliados → Enemigos pesados (activan) + te atacan
├── Revelar Falso Enemigo → Huye, NO activa interruptor
├── Revelar Verdadero Enemigo → Activa + dispara proyectiles
└── Decisión: ¿Qué combinación minimiza peligro?
```

**Niveles que usan este puzzle:** Nivel 2

---

### Puzzle Tipo C: "La Verdad Oculta"

```
SETUP:
├── Sala con 5 NPCs enmascarados estáticos
├── Inscripción: "Solo uno dice la verdad"
├── Cada NPC tiene símbolo diferente sobre cabeza

SOLUCIÓN:
├── Revelar al NPC correcto → Puerta secreta aparece
├── Revelar a los demás → Activan trampas (pinchos, enemigos spawn)
├── Pista: Observar animaciones sutiles de sprites enmascarados
└── Requiere atención al detalle, no solo reflejos
```

**Niveles que usan este puzzle:** Nivel 3 (stretch goal)

---

## 🎨 Dirección de Arte

### Estilo Visual

**Estética General:**
- **Monocromático:** Blanco y negro puro (NO grises)
- **Técnica:** Bocetos a lápiz/tinta escaneados
- **Inspiración:** Grabados góticos, art de Darkest Dungeon meets Tim Burton

**Por qué este estilo:**
- ✅ Aprovecha habilidades del artista (papel y lápiz)
- ✅ Pipeline rápido (escanear/fotografiar → procesar → integrar)
- ✅ Diferenciador único en mercado indie
- ✅ Estética oscura alineada con tema del juego

### Comunicación Visual Post-Revelación

**Código de Color (Auras):**

| Tipo Revelado | Color de Aura | Comportamiento Visual |
|---------------|---------------|----------------------|
| Falso Enemigo (aliado) | Azul pálido | Partículas de alivio, sprite encogido |
| Falso Aliado (enemigo) | Rojo intenso | Ojos brillantes, postura agresiva |
| Verdadero Enemigo | Púrpura oscuro | Aura pulsante, respiración |
| Inocente Real | Blanco/sin aura | Sprite sentado/inmóvil |

**Elementos UI:**
- Fuente: Gótica de Google Fonts (ej: "Cinzel" o "Crimson Text")
- HUD minimalista (esquinas de pantalla)
- Indicadores de rango: Aros blancos sutiles

---

### Pipeline de Arte

**DÍA 1 - Placeholders:**
1. Usar sprites geométricos simples:
   - Jugador: Cuadrado blanco
   - Enemigos: Triángulos rojos (enmascarados) → azules (revelados)
   - Aliados: Círculos amarillos (enmascarados) → rojos (revelados)
2. Prefijo: `PLACEHOLDER_[nombre].png`
3. Enfoque: Mecánicas funcionales primero

**DÍA 2 - Arte Final:**
1. **Mañana (09:00-11:00):**
   - Artista dibuja sprites en papel (tamaño consistente)
   - Tinta negra, líneas gruesas
   - Diseños asimétricos para "antes/después"
2. **Mediodía (11:00-13:00):**
   - Escaneo a 300dpi (o fotografía con buena luz)
   - Procesamiento en GIMP/Photoshop:
     - Ajustar niveles (contraste blanco/negro máximo)
     - Recortar sprites individuales
     - Exportar como PNG con transparencia
3. **Tarde (13:00+):**
   - Integrar sprites en Godot
   - Ajustar tamaños y colliders

---

## 🎵 Audio

### Dirección Musical

**Estilo:**
- Ambiental oscuro, minimalista
- Inspiración: Soundtracks de Limbo, Inside, Silent Hill

**Capas dinámicas:**
- **Capa Base:** Piano + strings atmosféricos (siempre activa)
- **Capa Combate:** Drums + distorsión (activa cuando hay enemigos revelados activos)
- **Transiciones:** Crossfade de 1 segundo entre capas

**Fuentes (sin especialista de audio):**
- Freesound.org (CC0 / CC-BY)
- Generadores: Aiva.ai, Soundraw (marcar como PLACEHOLDER si no es comercial)
- Todos los archivos generados: prefijo `PLACEHOLDER_AUTOGEN_`

### SFX

| Acción | Descripción SFX | Fuente |
|--------|-----------------|--------|
| Salto | "Whoosh" suave | Freesound.org |
| Aterrizaje | Impacto seco | Freesound.org |
| Arrancar velo | Tela rasgándose + reverb | Generado/Freesound |
| Revelación enemigo | Rugido distorsionado | Freesound.org |
| Revelación aliado | Suspiro de alivio | Generado |
| Daño al jugador | Golpe + quejido | Freesound.org |
| Interruptor activado | Click mecánico | Freesound.org |
| Puerta abriendo | Chirrido metálico | Freesound.org |

---

## 🏗️ Arquitectura Técnica

### Estructura de Carpetas

```
res://
├── project.godot
├── scenes/
│   ├── main_menu.tscn              # Menú principal
│   ├── levels/
│   │   ├── level_template.tscn     # Template para diseño de niveles
│   │   ├── level_01.tscn           # Tutorial implícito
│   │   ├── level_02.tscn           # Complejidad media
│   │   └── level_03.tscn           # (Stretch goal)
│   ├── characters/
│   │   ├── player.tscn             # Jugador + mecánica reveal
│   │   └── entities/
│   │       ├── false_enemy.tscn    # Falso Enemigo
│   │       ├── false_friend.tscn   # Falso Aliado
│   │       ├── true_threat.tscn    # Verdadero Enemigo
│   │       └── true_innocent.tscn  # Inocente (stretch)
│   ├── ui/
│   │   ├── hud.tscn                # HUD (HP + Verdades)
│   │   ├── pause_menu.tscn         # Menú de pausa
│   │   └── ending_screen.tscn      # Pantalla de endings
│   └── components/
│       ├── veil_component.tscn     # Componente reutilizable
│       ├── health_component.tscn   # Componente de salud
│       └── reveal_detector.tscn    # Área de detección
├── scripts/
│   ├── autoloads/
│   │   ├── game_manager.gd         # Estado global, verdades acumuladas
│   │   └── audio_manager.gd        # Gestión de música dinámica
│   ├── core/
│   │   ├── player_controller.gd    # Movimiento + input
│   │   ├── reveal_system.gd        # Lógica de revelación
│   │   └── masked_entity.gd        # Clase base para entidades
│   └── utils/
│       ├── camera_shake.gd         # Efecto de screen shake
│       └── particle_manager.gd     # Pooling de partículas
├── assets/
│   ├── sprites/
│   │   ├── placeholder/
│   │   │   ├── PLACEHOLDER_player.png
│   │   │   ├── PLACEHOLDER_enemy_masked.png
│   │   │   └── PLACEHOLDER_enemy_revealed.png
│   │   └── scanned/                # Arte final día 2
│   │       ├── player_idle.png
│   │       ├── false_enemy_masked.png
│   │       └── ...
│   ├── audio/
│   │   ├── music/
│   │   │   ├── PLACEHOLDER_AUTOGEN_ambient_base.ogg
│   │   │   └── PLACEHOLDER_AUTOGEN_ambient_combat.ogg
│   │   └── sfx/
│   │       ├── jump.wav
│   │       ├── tear_veil.wav
│   │       └── ...
│   └── fonts/
│       └── gothic_font.ttf         # Google Fonts
└── resources/
    └── entity_data/                # Resources para tipos de entidades
        ├── false_enemy_data.tres
        └── ...
```

---

## ⏱️ Roadmap de 48 Horas

### VIERNES NOCHE (4 horas) - 18:00-22:00

**[18:00-19:00] Setup del Proyecto**
- [ ] Crear proyecto Godot 4.x
- [ ] Configurar .gitignore
- [ ] Inicializar Git + GitHub repo
- [ ] Crear estructura de carpetas

**[19:00-20:30] Arquitectura Base**
- [ ] Configurar autoloads (GameManager, AudioManager)
- [ ] Scene template básica
- [ ] Sistema de escenas (Main Menu → Level)

**[20:30-22:00] Arte Placeholder + Concepto**
- [ ] Crear sprites geométricos placeholder
- [ ] Artista hace bocetos de concepto en papel (no integrados aún)
- [ ] Definir paleta (blanco/negro + acentos de color para auras)

---

### SÁBADO MAÑANA (4 horas) - 09:00-13:00

**[09:00-11:00] Controlador del Jugador**
- [ ] Movimiento (izquierda/derecha)
- [ ] Salto con gravedad
- [ ] Coyote time
- [ ] Jump buffer
- [ ] Animaciones básicas (idle, walk, jump)

**[11:00-13:00] Cámara y Nivel de Prueba**
- [ ] Cámara que sigue al jugador (smoothing)
- [ ] Nivel de prueba simple (plataformas, suelo)
- [ ] Sistema de colisiones
- [ ] **PLAYTEST:** Movimiento se siente bien

---

### SÁBADO TARDE (4 horas) - 14:00-18:00

**[14:00-16:00] Sistema "Tear the Veil"**
- [ ] Detección de entidades cercanas (área de rango)
- [ ] Input de acción "reveal"
- [ ] Lógica de transformación (masked → revealed)
- [ ] Feedback visual básico:
  - [ ] Indicador de rango (aro blanco)
  - [ ] Flash de pantalla
  - [ ] Screen shake básico

**[16:00-18:00] Comportamientos de Entidades**
- [ ] Script Falso Enemigo:
  - [ ] Estado enmascarado (patrulla)
  - [ ] Estado revelado (huye)
- [ ] Script Falso Aliado:
  - [ ] Estado enmascarado (estático, señala)
  - [ ] Estado revelado (persigue, daña)
- [ ] **PLAYTEST:** Primera jugabilidad completa

---

### SÁBADO NOCHE (4 horas) - 19:00-23:00

**[19:00-21:00] Primer Nivel Completo**
- [ ] Diseñar Nivel 1 con:
  - [ ] 2 Falsos Enemigos (tutorial implícito)
  - [ ] 1 Falso Aliado (sorpresa)
  - [ ] Objetivo: Llegar al final
- [ ] Implementar condición de victoria (trigger de salida)
- [ ] HUD básico:
  - [ ] Contador de Verdades
  - [ ] HP (si tiempo permite)

**[21:00-23:00] Pulido de Mecánicas**
- [ ] Ajustar física del salto (feel)
- [ ] Mejorar feedback de revelación:
  - [ ] Partículas simples (fragmentos cayendo)
  - [ ] Mejor animación de jugador
- [ ] SFX placeholder generados
- [ ] **COMMIT:** "Core Mechanics Complete"

---

### SÁBADO NOCHE TARDÍA (2 horas, OPCIONAL) - 23:00-01:00

- [ ] Bug fixing del playtest
- [ ] Diseñar Nivel 2 (borrador)
- [ ] Integrar música ambiental placeholder

---

### DOMINGO MAÑANA (4 horas) - 09:00-13:00

**[09:00-11:00] Pipeline de Arte Tradicional**
- [ ] Artista dibuja sprites finales en papel:
  - [ ] Jugador (idle, walk, tear, jump)
  - [ ] Falso Enemigo (masked, revealed)
  - [ ] Falso Aliado (masked, revealed)
- [ ] Escaneo/fotografía de alta calidad (300dpi)
- [ ] Procesamiento en GIMP:
  - [ ] Ajustar niveles (blanco/negro puro)
  - [ ] Recortar sprites individuales
  - [ ] Exportar PNG con transparencia

**[11:00-13:00] Integración de Arte + Nivel 2**
- [ ] Reemplazar placeholders con arte real
- [ ] Ajustar tamaños y colliders si necesario
- [ ] Diseñar Nivel 2:
  - [ ] Puzzle de interruptores
  - [ ] Introducir Verdadero Enemigo
- [ ] **PLAYTEST:** Experiencia con arte final

---

### DOMINGO TARDE (4 horas) - 14:00-18:00

**[14:00-15:00] Verdadero Enemigo (Tipo 3)**
- [ ] Script de torreta (estático, dispara proyectiles)
- [ ] Proyectiles con colisión y daño
- [ ] Integrar en Nivel 2

**[15:00-16:00] UI y Transiciones**
- [ ] Menú principal simple (Play, Quit)
- [ ] Pantalla de pausa (Resume, Restart, Menu)
- [ ] Transiciones entre niveles (fade simple)

**[16:00-18:00] Polish (Juice)**
- [ ] Mejorar partículas de revelación
- [ ] Screen shake en eventos clave
- [ ] Animaciones de UI (fade in/out)
- [ ] Mejor integración de música (capas dinámicas si tiempo)
- [ ] **PLAYTEST:** Experiencia completa

---

### DOMINGO NOCHE (2 horas) - 18:00-20:00

**[18:00-19:00] Testing + Balanceo**
- [ ] Playtest completo de 2 niveles
- [ ] Ajustar dificultad
- [ ] Corregir bugs críticos
- [ ] Build de prueba (Windows)

**[19:00-20:00] Build Final + Submission**
- [ ] Optimizar assets (comprimir texturas)
- [ ] Build para Windows + Linux
- [ ] Test de builds
- [ ] Screenshots del juego (3-5)
- [ ] GIF animado de mecánica principal
- [ ] Escribir descripción para itch.io
- [ ] Upload a plataforma de la jam
- [ ] **GIT TAG:** "v1.0-submission"

---

## 🎯 Alcance y Prioridades

### Mínimo Viable (MUST HAVE - Día 1)

- [x] 1 nivel jugable (3-5 minutos)
- [x] Mecánica de movimiento + salto funcional
- [x] Mecánica de "Tear the Veil" con feedback básico
- [x] 2 tipos de entidades (Falso Enemigo + Falso Aliado)
- [x] Arte placeholder geométrico
- [x] Sin audio o placeholders generados

### Objetivo Realista (TARGET - Día 2)

- [ ] 2-3 niveles (10-12 minutos total)
- [ ] 3 tipos de entidades (incluye Verdadero Enemigo)
- [ ] Sistema de Verdades funcional
- [ ] HP básico (3 corazones)
- [ ] Arte escaneado procesado (estilo sketch)
- [ ] SFX básicos + música ambiental

### Metas Estirables (STRETCH GOALS - Si hay tiempo)

- [ ] 4º tipo de entidad (Inocente Real)
- [ ] Sistema de endings múltiples
- [ ] Power-ups (Visión Clara, Grito de Revelación)
- [ ] Nivel 3 con puzzle complejo
- [ ] Particle effects avanzados
- [ ] Boss fight final (entidad con "múltiples capas")
- [ ] Cutscenes estáticas entre niveles

---

## 🚨 Riesgos y Mitigaciones

### Riesgos Técnicos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Sistema de revelación buggy | Media | Alto | Implementar primero, testear constantemente |
| Física de platformer no se siente bien | Media | Alto | Usar valores probados (gravity=980, jump=-400) |
| Colisiones inconsistentes | Baja | Medio | Usar CollisionShapes simples (rectángulos) |

### Riesgos de Alcance

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Demasiados niveles planeados | Alta | Alto | Máximo 3 niveles, cada uno 3-4 minutos |
| Muchos tipos de entidades | Media | Medio | Empezar con 2, expandir solo si hay tiempo |
| Over-engineering de sistemas | Media | Alto | Implementación más simple primero, pulir después |

### Riesgos de Equipo

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Pipeline de arte tradicional lento | Media | Alto | Día 1 completo con placeholders funcionales |
| Sin especialista de audio | Certeza | Bajo | Usar Freesound.org + generadores, marcar PLACEHOLDER |
| Fatiga/burnout en 48h | Alta | Medio | Descansos programados, alcance realista |

### Riesgos de Diseño

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Mecánica de revelación no es clara | Media | Alto | Tutorial implícito en Nivel 1, feedback visual obvio |
| Puzzles demasiado difíciles/fáciles | Media | Medio | Playtest frecuente, ajustar en tiempo real |
| Tema no conecta con jugadores | Baja | Bajo | Enfocarse en gameplay primero, narrativa segundo |

---

## 📊 Criterios de Éxito

### Criterios Técnicos
- ✅ Juego completable de principio a fin sin crashes
- ✅ Build funcional para Windows (Linux opcional)
- ✅ Framerate estable (60 FPS en hardware moderno)

### Criterios de Gameplay
- ✅ Mecánica de revelación se siente satisfactoria (juice)
- ✅ Al menos 1 "momento sorpresa" (Falso Aliado revelado)
- ✅ 10 minutos de contenido jugable

### Criterios de Arte
- ✅ Estética coherente (blanco/negro + auras de color)
- ✅ Arte final integrado (aunque sea parcialmente)
- ✅ UI legible y funcional

### Criterios de Tema
- ✅ Conexión clara con tema "Máscara"
- ✅ Mecánica única que diferencia de otros platformers
- ✅ Mensaje/subtexto sobre hipocresía y verdad

---

## 🎁 Diferenciadores Únicos

1. **Mecánica de Revelación Como Puzzle Social**
   - No es solo combate ni evitación
   - Es decidir qué verdades confrontar
   - Metáfora: Revelar hipocresía tiene consecuencias

2. **Inversión de Dinámica Enemigo-Aliado**
   - La identificación ES el puzzle
   - Sistema de "crear tus propios enemigos"

3. **Estética de Arte Tradicional Oscuro**
   - Bocetos góticos escaneados (único en indie)
   - Blanco/negro + auras de color (minimalista pero expresivo)

4. **Narrativa Ambiental Sin Diálogos**
   - Historia inferida mediante diseño de entidades
   - Mundo donde hipocresía es la norma

5. **Rejugabilidad Emergente**
   - Speedrun (mínimas revelaciones)
   - Completista (todas las verdades)
   - Diferentes endings según % revelado

---

## 📝 Marketing y Presentación

### Descripción para Itch.io

```
VEIL

Tear the veil. Face the truth.

En un mundo de hipocresía, tú posees el poder de revelar verdades ocultas.

Arranca los velos de personas enmascaradas para descubrir su verdadera naturaleza:
• Los amenazantes pueden ser víctimas asustadas
• Los amigables pueden ser monstruos disfrazados
• Cada revelación tiene consecuencias

Un platformer oscuro con mecánica única y estética gótica dibujada a mano.

Confronta la verdad. Asume las consecuencias.

---

Controles:
• A/D o Flechas: Mover
• Espacio: Saltar
• E: Arrancar velo (cerca de entidades)

---

Creado en 48 horas para Global Game Jam 2026
Tema: "Máscara"
```

### Screenshots Clave (Para Capturar)

1. **Hero Shot:** Jugador arrancando velo de entidad (partículas, flash)
2. **Puzzle Shot:** Nivel con múltiples entidades enmascaradas
3. **Revelación Shot:** Antes/después de revelar Falso Aliado (transformación)
4. **Ambiente Shot:** Vista amplia de nivel con estética oscura

### GIF Animado (Para Redes Sociales)

- 5-10 segundos
- Mostrar secuencia completa de revelación
- Incluir transformación de enemigo
- Loop perfecto

### Hashtags

```
#VEILgame #GGJ2026 #GlobalGameJam #indiegame #platformer
#gothic #madewithgodot #gamedev #indiedev #ggj26
```

---

## 🔗 Referencias

### Juegos de Referencia (Mecánicas)
- **Celeste:** Platforming preciso, juice
- **Limbo/Inside:** Estética monocromática, ambiente oscuro
- **Return of the Obra Dinn:** Mecánica de revelación/deducción
- **Hollow Knight:** Enemigos con comportamientos únicos

### Inspiración Visual
- **Darkest Dungeon:** Arte de grabado gótico
- **Don't Starve:** Blanco/negro con acentos de color
- **Papers, Please:** Minimalismo expresivo

### Inspiración Narrativa
- **In This Moment (banda):** Temas de revelación, empoderamiento
- **Silent Hill:** Horror psicológico, verdades ocultas
- **The Picture of Dorian Gray:** Dualidad, máscara social

---

## ✅ Checklist Pre-Implementación

Antes de empezar a programar, confirmar:

- [ ] Godot 4.x instalado y funcional
- [ ] Git configurado, repositorio creado
- [ ] GDD leído y comprendido por todo el equipo
- [ ] Artista tiene materiales listos (papel, lápiz/tinta, scanner/cámara)
- [ ] Roles claramente definidos:
  - [ ] Programador: Mecánicas + integración
  - [ ] Artista: Sprites + concepto visual
  - [ ] Diseñador: Niveles + balanceo
- [ ] Comunicación establecida (Discord, chat, presencial)
- [ ] Descansos programados (cada 3-4 horas)

---

**Última actualización:** 2026-01-30
**Versión del documento:** 1.0
**Estado:** Listo para implementación

---

*"La verdad duele. Pero la mentira destruye."*
