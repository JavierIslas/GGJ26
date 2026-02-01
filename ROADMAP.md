# VEIL - Roadmap de 48 Horas

**Global Game Jam 2026 | Desarrollo: Viernes 18:00 → Domingo 20:00**

---

## 📊 Resumen Ejecutivo

| Fase | Duración | Horas | Prioridad |
|------|----------|-------|-----------|
| Viernes Noche | 18:00-22:00 | 4h | Setup + Arquitectura |
| Sábado Mañana | 09:00-13:00 | 4h | Mecánicas Core |
| Sábado Tarde | 14:00-18:00 | 4h | Sistema de Revelación |
| Sábado Noche | 19:00-23:00 | 4h | Primer Nivel + Polish |
| Domingo Mañana | 09:00-13:00 | 4h | Arte Final + Nivel 2 |
| Domingo Tarde | 14:00-18:00 | 4h | UI + Polish |
| Domingo Noche | 18:00-20:00 | 2h | Testing + Build |

**Total:** 26 horas de desarrollo efectivo (con descansos)

---

## 🟢 VIERNES NOCHE (4 horas)

### 18:00-19:00 | Setup del Proyecto

**Responsable:** Programador

**Tareas:**
- [ ] Crear proyecto Godot 4.x nuevo
  - Nombre: "VEIL"
  - Renderer: Forward+ (o Compatible si hardware limitado)
  - Resolución base: 1920x1080 (escalar a ventana)
- [ ] Configurar Git
  ```bash
  git init
  git remote add origin [URL_REPO]
  ```
- [ ] Crear `.gitignore` para Godot:
  ```
  .import/
  .godot/
  *.translation
  export_presets.cfg
  ```
- [ ] Crear estructura de carpetas (ver GDD)
- [ ] Commit inicial: "Initial project setup"

**Entregable:** Proyecto Godot vacío con estructura de carpetas

---

### 19:00-20:30 | Arquitectura Base

**Responsable:** Programador

**Tareas:**
- [ ] Crear autoloads:
  - [ ] `game_manager.gd`:
    ```gdscript
    extends Node

    var total_truths_revealed: int = 0
    var current_level: int = 1
    var player_hp: int = 3
    ```
  - [ ] `audio_manager.gd`:
    ```gdscript
    extends Node

    var ambient_layer: AudioStreamPlayer
    var combat_layer: AudioStreamPlayer
    ```
- [ ] Configurar autoloads en Project Settings
- [ ] Crear escenas básicas:
  - [ ] `main_menu.tscn` (placeholder con botón "Play")
  - [ ] `level_template.tscn` (TileMap vacío)
- [ ] Sistema básico de cambio de escenas
- [ ] Commit: "Base architecture setup"

**Entregable:** Estructura de proyecto funcional, cambio de escenas funciona

---

### 20:30-22:00 | Arte Placeholder + Concepto

**Responsable:** Programador (placeholders) + Artista (bocetos)

**Tareas Programador:**
- [ ] Crear sprites geométricos placeholder:
  - `PLACEHOLDER_player.png`: Cuadrado blanco 32x32px
  - `PLACEHOLDER_false_enemy_masked.png`: Triángulo rojo 32x32px
  - `PLACEHOLDER_false_enemy_revealed.png`: Triángulo azul 32x32px
  - `PLACEHOLDER_false_friend_masked.png`: Círculo amarillo 32x32px
  - `PLACEHOLDER_false_friend_revealed.png`: Círculo rojo con dientes 32x32px
- [ ] Importar a Godot (filter: Nearest para pixel-perfect)

**Tareas Artista:**
- [ ] Bocetos de concepto en papel:
  - Diseño del jugador (figura humanoide simple)
  - Falso Enemigo (antes/después)
  - Falso Aliado (antes/después)
  - Estilo: Líneas gruesas, asimétrico, gótico
- [ ] **NO integrar aún** (solo concepto)

**Tareas Diseñador:**
- [ ] Definir paleta de colores para auras:
  - Azul pálido: `#6BA3D0` (Falso Enemigo revelado)
  - Rojo intenso: `#D04848` (Falso Aliado revelado)
  - Púrpura oscuro: `#6C3B8C` (Verdadero Enemigo)

**Entregable:** Placeholders listos para usar, bocetos conceptuales en papel

---

## 🟢 SÁBADO MAÑANA (4 horas)

### 09:00-11:00 | Controlador del Jugador

**Responsable:** Programador

**Tareas:**
- [ ] Crear `player.tscn`:
  - CharacterBody2D
  - Sprite2D (placeholder)
  - CollisionShape2D (rectangular 28x30px)
- [ ] Implementar `player_controller.gd`:
  - [ ] Movimiento horizontal (velocidad: 150 px/s)
  - [ ] Salto (impulso: -400 px/s, gravedad: 980 px/s²)
  - [ ] Coyote time (0.15s)
  - [ ] Jump buffer (0.1s)
  - [ ] Flip del sprite según dirección
- [ ] Animaciones básicas (idle, walk):
  - Usar AnimationPlayer
  - Idle: Sin movimiento
  - Walk: Escalado sutil o traslación si es placeholder
- [ ] Commit: "Player movement implementation"

**Parámetros exactos:**
```gdscript
const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const COYOTE_TIME = 0.15
const JUMP_BUFFER = 0.1
```

**Entregable:** Jugador con movimiento y salto funcional

---

### 11:00-13:00 | Cámara y Nivel de Prueba

**Responsable:** Programador + Diseñador

**Tareas Programador:**
- [ ] Añadir Camera2D al jugador:
  - Position smoothing: Enabled (Speed: 5.0)
  - Limits: Configurar según tamaño del nivel
- [ ] Crear nivel de prueba `test_level.tscn`:
  - TileMap con tiles de 32x32px
  - Suelo, plataformas simples
  - CollisionShapes en tiles

**Tareas Diseñador:**
- [ ] Diseñar layout del nivel de prueba:
  - Zona inicial plana (aprender movimiento)
  - 2-3 plataformas elevadas (practicar salto)
  - Ancho: ~1500px, Alto: ~800px

**Testing:**
- [ ] Movimiento se siente responsivo
- [ ] Salto alcanza plataformas correctamente
- [ ] Coyote time funciona (saltar justo al salir de plataforma)
- [ ] Cámara sigue suavemente

**Entregable:** Nivel de prueba jugable con buen "feel"

---

## 🟢 SÁBADO TARDE (4 horas)

### 14:00-16:00 | Sistema "Tear the Veil"

**Responsable:** Programador

**Tareas:**
- [ ] Crear `veil_component.tscn` (componente reutilizable):
  - Node2D base
  - Variable: `is_revealed: bool = false`
  - Señal: `veil_torn(entity)`
- [ ] Crear `reveal_detector.tscn`:
  - Area2D adjunto al jugador
  - CollisionShape2D circular (radio: 32px)
  - Detecta entidades con VeilComponent
- [ ] Implementar `reveal_system.gd`:
  - [ ] Detectar input de revelación (tecla E)
  - [ ] Verificar rango (entidades dentro de Area2D)
  - [ ] Cooldown global (0.5s)
  - [ ] Llamar a `tear_veil()` en entidad detectada
- [ ] Feedback visual básico:
  - [ ] Indicador de rango: Sprite circular blanco alrededor de entidad cercana
  - [ ] Flash de pantalla: CanvasModulate con tween (blanco 30% opacity, 0.1s)
  - [ ] Screen shake básico: Añadir `camera_shake.gd`
    ```gdscript
    func shake(trauma: float):
        # Implementación simple de trauma-based shake
    ```
- [ ] Commit: "Reveal system core implementation"

**Entregable:** Sistema de revelación funcional con feedback básico

---

### 16:00-18:00 | Comportamientos de Entidades

**Responsable:** Programador

**Tareas:**
- [ ] Crear `false_enemy.tscn` (Tipo 1):
  - CharacterBody2D
  - Sprite2D (placeholder masked)
  - VeilComponent adjunto
  - Script `false_enemy.gd`:
    - Estado MASKED: Patrulla izq/der (50 px/s)
    - Estado REVEALED: Huye del jugador (100 px/s)
    - Al revelar: Cambiar sprite, emitir partículas

- [ ] Crear `false_friend.tscn` (Tipo 2):
  - CharacterBody2D
  - Sprite2D (placeholder masked)
  - VeilComponent adjunto
  - Script `false_friend.gd`:
    - Estado MASKED: Estático, animación de "llamar"
    - Estado REVEALED: Persigue jugador (120 px/s), daña por contacto (-1 HP)
    - Al revelar: Cambiar sprite, rugir (animación)

- [ ] Implementar sistema de daño básico:
  - [ ] `health_component.tscn` adjunto al jugador
  - [ ] Señal: `health_changed(old_hp, new_hp)`
  - [ ] Invulnerabilidad temporal al recibir daño (1s)

**Testing:**
- [ ] Falso Enemigo patrulla y huye al revelar
- [ ] Falso Aliado se vuelve hostil al revelar
- [ ] Daño se registra correctamente

**Entregable:** 2 tipos de entidades con comportamientos completos

**PLAYTEST 1:** Primera jugabilidad completa (colocar entidades en test_level)

---

## 🟢 SÁBADO NOCHE (4 horas)

### 19:00-21:00 | Primer Nivel Completo

**Responsable:** Diseñador + Programador

**Tareas Diseñador:**
- [ ] Diseñar `level_01.tscn` (Tutorial Implícito):
  - **Sección 1 (0-300px):** Zona de spawn, solo movimiento
  - **Sección 2 (300-600px):** 1 Falso Enemigo bloqueando pasillo
    - Jugador debe revelar para pasar
  - **Sección 3 (600-900px):** Plataformas + 1 Falso Aliado arriba
    - Parece útil, pero se vuelve enemigo
  - **Sección 4 (900-1200px):** Salida (trigger de victoria)
  - Total: ~4 minutos de juego

**Tareas Programador:**
- [ ] Implementar HUD básico `hud.tscn`:
  - Label "Verdades: X / Y" (esquina superior derecha)
  - 3 corazones (esquina superior izquierda) - Si tiempo permite
  - Conectar con GameManager
- [ ] Trigger de victoria:
  - Area2D al final del nivel
  - Al entrar: Cargar siguiente nivel o pantalla de victoria
- [ ] Sistema de contador de Verdades:
  - Incrementar en GameManager al revelar
  - Actualizar HUD
- [ ] Commit: "Level 01 complete with HUD"

**Entregable:** Nivel 1 jugable de principio a fin con HUD

---

### 21:00-23:00 | Pulido de Mecánicas (Juice)

**Responsable:** Programador

**Tareas:**
- [ ] Mejorar física del salto:
  - Ajustar JUMP_VELOCITY si no se siente bien
  - Variable gravity (subiendo vs bajando) - Opcional
- [ ] Partículas de revelación:
  - GPUParticles2D  simple
  - Forma: Pequeños cuadrados blancos
  - Dirección: Explosión radial
  - Lifetime: 0.5s
  - Pool para reutilización
- [ ] Mejorar animación de jugador:
  - Animación "tear_veil": 3-4 frames
  - Freeze del jugador durante animación (0.15s)
- [ ] SFX placeholders:
  - Buscar en Freesound.org:
    - Jump: "whoosh"
    - Land: "thud"
    - Tear veil: "fabric rip"
    - Enemy revealed: "growl"
    - Friend revealed: "sigh"
  - Descargar, renombrar con prefijo `PLACEHOLDER_`
  - Integrar con AudioStreamPlayer
- [ ] Commit: "Juice and polish pass 1"

**Testing:**
- [ ] Revelación se siente satisfactoria
- [ ] SFX ayudan a entender acciones

**Entregable:** Juego con mejor "game feel"

---

## 🟡 SÁBADO NOCHE TARDÍA (2 horas, OPCIONAL)

### 23:00-01:00 | Bug Fixing + Nivel 2 (Borrador)

**Responsable:** Programador + Diseñador

**Tareas:**
- [ ] Bug fixing del playtest:
  - Listar todos los bugs encontrados
  - Priorizar críticos (crashes, softlocks)
  - Resolver los críticos
- [ ] Diseñador: Borrador de Nivel 2 en papel
  - Introducir puzzle de interruptores
  - Planear posición de Verdadero Enemigo
- [ ] Música ambiental placeholder (si hay tiempo):
  - Buscar en Freepd.com o generador (Aiva.ai)
  - Loop simple, oscuro, minimalista
  - Marcar como `PLACEHOLDER_AUTOGEN_ambient.ogg`

**Entregable:** Bugs críticos resueltos, concepto de Nivel 2

**DESCANSO:** Dormir al menos 6 horas antes del domingo

---

## 🟢 DOMINGO MAÑANA (4 horas)

### 09:00-11:00 | Pipeline de Arte Tradicional

**Responsable:** Artista + Programador (asistencia)

**Tareas Artista:**
- [ ] Dibujar sprites finales en papel:
  - **Jugador:**
    - Idle (1 frame)
    - Walk (2-3 frames)
    - Tear veil (3 frames)
    - Jump (1 frame)
  - **Falso Enemigo:**
    - Masked idle (1 frame)
    - Revealed scared (1 frame)
  - **Falso Aliado:**
    - Masked friendly (1 frame)
    - Revealed monster (1 frame)
  - Tamaño: ~5cm x 5cm en papel
  - Tinta negra, líneas gruesas
  - Diseño: Asimétrico, gótico

- [ ] Escaneo/fotografía:
  - Scanner a 300 DPI (blanco/negro)
  - O fotografía con luz uniforme, fondo blanco

**Tareas Programador (asistencia):**
- [ ] Procesamiento en GIMP/Photoshop:
  1. Abrir imagen escaneada
  2. Colors → Levels → Ajustar para blanco puro y negro puro
  3. Recortar cada sprite individual
  4. Image → Scale → Resize a 64x64px (o tamaño apropiado)
  5. Filters → Alpha → Color to Alpha (blanco a transparente)
  6. Export as PNG: `player_idle.png`, etc.
- [ ] Importar a Godot (filter: Nearest)

**Entregable:** Sprites finales procesados y listos para integrar

---

### 11:00-13:00 | Integración de Arte + Nivel 2

**Responsable:** Programador + Diseñador

**Tareas Programador:**
- [ ] Reemplazar sprites placeholder con arte final:
  - Actualizar rutas en escenas
  - Ajustar tamaños de CollisionShapes si necesario
  - Verificar que animaciones funcionen
- [ ] Commit: "Final art integration"

**Tareas Diseñador:**
- [ ] Crear `level_02.tscn` (Puzzle de Interruptores):
  - **Setup:**
    - 4 pedestales con entidades enmascaradas:
      - 2 Falsos Enemigos
      - 1 Falso Aliado
      - 1 Verdadero Enemigo (nuevo tipo, placeholder por ahora)
    - 2 interruptores (activados por peso de entidades reveladas)
    - Puerta que abre con 2 interruptores activos
  - **Solución óptima:** Revelar 1 Falso Aliado + 1 Verdadero Enemigo
  - **Tamaño:** 1500x1000px aprox.
  - **Duración:** 5-6 minutos

**PLAYTEST 2:** Experiencia con arte final en Nivel 1

**Entregable:** Arte final integrado, Nivel 2 diseñado (sin Verdadero Enemigo aún)

---

## 🟢 DOMINGO TARDE (4 horas)

### 14:00-15:00 | Verdadero Enemigo (Tipo 3)

**Responsable:** Programador

**Tareas:**
- [ ] Crear `true_threat.tscn`:
  - StaticBody2D (no se mueve)
  - Sprite2D (placeholder: Cuadrado púrpura)
  - VeilComponent
  - Script `true_threat.gd`:
    - Estado MASKED: Completamente estático, parece decoración
    - Estado REVEALED: Torreta biológica
      - Dispara proyectiles hacia jugador cada 2 segundos
      - Proyectil: Area2D con velocidad constante
      - Daño: -2 HP por proyectil

- [ ] Crear `projectile.tscn`:
  - Area2D
  - Sprite2D (círculo pequeño)
  - Script: Movimiento lineal hacia dirección, despawn después de 3s

- [ ] Integrar en Nivel 2:
  - Reemplazar placeholder de Verdadero Enemigo

**Testing:**
- [ ] Verdadero Enemigo no se mueve pero dispara
- [ ] Proyectiles dañan correctamente
- [ ] Jugador puede esquivar proyectiles

**Entregable:** Tipo 3 funcional, Nivel 2 completo

---

### 15:00-16:00 | UI y Transiciones

**Responsable:** Programador

**Tareas:**
- [ ] Mejorar `main_menu.tscn`:
  - Fondo oscuro (ColorRect negro)
  - Título "VEIL" con fuente gótica
  - Botones: "Play", "Quit"
  - Animación de fade in al cargar
- [ ] Crear `pause_menu.tscn`:
  - Input: ESC para pausar
  - Opciones: "Resume", "Restart Level", "Main Menu"
  - Pausar con `get_tree().paused = true`
- [ ] Transiciones entre niveles:
  - Fade out → Cambio de escena → Fade in
  - Usar CanvasLayer con ColorRect negro + AnimationPlayer
- [ ] Fuente gótica:
  - Descargar de Google Fonts (ej: "Cinzel" o "Crimson Text")
  - Importar a Godot, crear DynamicFont

**Entregable:** UI completa y transiciones suaves

---

### 16:00-18:00 | Polish Final (Juice)

**Responsable:** Programador + Diseñador

**Tareas:**
- [ ] Mejorar partículas de revelación:
  - Diferentes colores según tipo revelado
  - Más cantidad, mejor timing
- [ ] Screen shake en eventos clave:
  - Revelación: Trauma 0.3
  - Recibir daño: Trauma 0.5
  - Enemigo derrotado: Trauma 0.2
- [ ] Animaciones de UI:
  - HUD: Fade in al inicio del nivel
  - Verdades contador: Bump al incrementar
  - Corazones: Shake al perder HP
- [ ] Música dinámica (si hay tiempo):
  - Capa base siempre activa
  - Capa combate (activa cuando hay enemigos revelados cerca)
  - Crossfade suave (1 segundo)
- [ ] Ajustes finales de diseño:
  - Balanceo de dificultad (si muy difícil/fácil)
  - Posicionamiento de checkpoints
- [ ] Commit: "Final polish pass"

**PLAYTEST 3:** Experiencia completa (Menú → Nivel 1 → Nivel 2 → Victoria)

**Entregable:** Juego pulido y listo para testing

---

## 🔴 DOMINGO NOCHE (2 horas)

### 18:00-19:00 | Testing + Balanceo

**Responsable:** TODO EL EQUIPO

**Tareas:**
- [ ] Playtest completo por cada miembro del equipo:
  - Completar ambos niveles
  - Anotar bugs
  - Anotar frustraciones
  - Anotar momentos confusos
- [ ] Priorizar issues:
  - **P0 (Crítico):** Crashes, softlocks, imposible completar
  - **P1 (Alto):** Bugs visuales graves, mecánicas no funcionan
  - **P2 (Medio):** Polish, balanceo menor
  - **P3 (Bajo):** Nice to have
- [ ] Resolver P0 y P1:
  - Máximo 30 minutos para cada bug
  - Si no se puede resolver rápido, buscar workaround
- [ ] Ajustar balanceo:
  - Si Nivel 1 muy difícil: Reducir cantidad de enemigos
  - Si Nivel 2 muy fácil: Añadir 1 Verdadero Enemigo más
- [ ] Builds de prueba:
  - Exportar para Windows (64-bit)
  - Testear en otra PC si es posible

**Entregable:** Lista de bugs resueltos, balanceo ajustado

---

### 19:00-20:00 | Build Final + Submission

**Responsable:** Programador + TODO EL EQUIPO (asistencia)

**Tareas Build:**
- [ ] Optimizar assets:
  - Comprimir texturas si muy pesadas
  - Eliminar archivos no usados de `res://`
- [ ] Configurar export presets:
  - Windows Desktop (64-bit)
  - Linux/X11 (64-bit) - Opcional
  - Embed PCK: Enabled
- [ ] Exportar builds finales:
  - `VEIL_Windows.zip`
  - `VEIL_Linux.zip` (si hay tiempo)
- [ ] Testear builds exportados:
  - Descomprimir en carpeta limpia
  - Ejecutar, verificar funcionalidad completa

**Tareas Marketing:**
- [ ] Capturar screenshots (3-5):
  - Hero shot (jugador revelando)
  - Puzzle shot (múltiples entidades)
  - Revelación sorpresa (transformación)
  - Vista de nivel (ambiente)
- [ ] Crear GIF animado (5-10s):
  - Grabar con OBS o captura de pantalla
  - Convertir a GIF con ezgif.com
  - Mostrar revelación completa
- [ ] Escribir descripción para itch.io:
  - Copiar de GDD.md (sección "Marketing")
  - Ajustar según contenido final
- [ ] Preparar build notes:
  - Controles
  - Duración aproximada
  - Créditos del equipo

**Tareas Submission:**
- [ ] Subir a itch.io:
  - Crear página de juego
  - Subir builds (Windows + Linux)
  - Añadir screenshots y GIF
  - Publicar
- [ ] Subir a plataforma oficial de GGJ:
  - Registrar juego
  - Link a itch.io
  - Tags: platformer, puzzle, dark, gothic
- [ ] Git final:
  - Commit final: "Release build v1.0"
  - Tag: `v1.0-submission`
  - Push a GitHub

**Entregable:** Juego publicado, submission completa

**🎉 CELEBRACIÓN 🎉**

---

## 📋 Checklist de Entrega

Antes de dar por terminado, verificar:

### Build
- [ ] Juego se ejecuta sin crashes
- [ ] Ambos niveles completables
- [ ] Todos los controles funcionan
- [ ] Audio funciona (música + SFX)
- [ ] Transiciones funcionan (menú, niveles, pausa)

### Contenido
- [ ] Mínimo 2 niveles (10+ minutos de contenido)
- [ ] 2-3 tipos de entidades funcionando
- [ ] Mecánica de revelación clara y satisfactoria
- [ ] HUD funcional (verdades + HP)

### Arte
- [ ] Arte final integrado (aunque sea parcialmente)
- [ ] Estética coherente (blanco/negro + auras)
- [ ] UI legible

### Marketing
- [ ] 3+ screenshots de calidad
- [ ] 1 GIF animado mostrando mecánica
- [ ] Descripción clara en itch.io
- [ ] Controles explicados

### Submission
- [ ] Publicado en itch.io
- [ ] Registrado en plataforma de GGJ
- [ ] Git con tag v1.0-submission
- [ ] Créditos del equipo incluidos

---

## 🚨 Plan de Contingencia

### Si vas ADELANTADO del plan:

**Prioridades de Stretch Goals:**
1. **Nivel 3** (puzzle complejo con Inocente Real)
2. **Sistema de endings múltiples** (narrativa)
3. **Power-ups** (Visión Clara, Grito de Revelación)
4. **Partículas mejoradas** (más juice)
5. **Boss fight final** (entidad con múltiples capas)

### Si vas ATRASADO del plan:

**Cortar en este orden:**
1. ~~Nivel 3~~ (mantener 2 niveles)
2. ~~Sistema de HP~~ (juego sin daño, solo puzzles)
3. ~~Verdadero Enemigo~~ (solo Tipos 1 y 2)
4. ~~Música dinámica~~ (solo capa base)
5. ~~Arte final completo~~ (mix de placeholder + algunos sprites finales)

**Mínimo Absoluto para Submission:**
- 1 nivel completable (5 minutos)
- Mecánica de revelación funcional
- 2 tipos de entidades (Falso Enemigo + Falso Aliado)
- Placeholders aceptables
- Build funcional

---

## 📞 Comunicación del Equipo

### Puntos de Sincronización

**Checkpoints obligatorios:**
- **Viernes 22:00:** Revisión de setup, todos tienen proyecto corriendo
- **Sábado 13:00:** Playtest 1, decidir ajustes de movimiento
- **Sábado 18:00:** Playtest 2, validar mecánica de revelación
- **Domingo 13:00:** Playtest 3 con arte final, validar experiencia
- **Domingo 18:00:** Pre-submission check, todos testean build

### Herramientas
- **Chat:** Discord / WhatsApp (respuestas rápidas)
- **Compartir archivos:** Google Drive / Dropbox (bocetos, assets)
- **Código:** Git (commits frecuentes, pull antes de trabajar)

### Protocolo de Problemas
1. **Bug crítico encontrado:** Avisar inmediatamente en chat
2. **Atrasado en tarea:** Avisar 1 hora antes del checkpoint
3. **Necesito ayuda:** Pedir sin miedo, mejor temprano que tarde

---

## ⏰ Descansos Programados

**IMPORTANTE:** Respetar descansos para evitar burnout

- **Viernes:** 22:00 → Dormir (mínimo 7 horas)
- **Sábado:**
  - 13:00-14:00: Almuerzo + descanso
  - 18:00-19:00: Cena + descanso
  - 23:00 → Dormir (mínimo 6 horas)
- **Domingo:**
  - 13:00-14:00: Almuerzo + descanso
  - 18:00-19:00: Sprint final (alta energía)

**Micro-descansos:** Cada 2 horas, levantarse 5 minutos

---

**Última actualización:** 2026-01-30
**Versión:** 1.0
**Estado:** Listo para ejecutar

---

*"La planificación es esencial. El plan es inútil."* - Dwight D. Eisenhower

(Adaptarse según las circunstancias reales, pero tener una guía clara ayuda enormemente en 48h)
