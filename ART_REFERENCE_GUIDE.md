# VEIL - Guía de Referencia para Artista

**Fecha:** 2026-02-05
**Estilo:** Bocetos góticos a lápiz/tinta (blanco y negro + acentos de color)
**Técnica:** Papel y lápiz → Escaneo 300dpi → Procesamiento
**Inspiración:** Darkest Dungeon, Tim Burton, grabados góticos
**Resolución Base:** 1080p (1920×1080) - Escala hacia abajo automático

---

## 📐 Especificaciones Técnicas

### Resolución y Escalado

**IMPORTANTE:** Todos los assets están diseñados para **1080p como resolución base**. El juego escala automáticamente hacia abajo (720p, 576p, 480p) sin perder proporciones.

| Resolución | Jugador en Pantalla | Proporción |
|------------|---------------------|------------|
| 1080p (base) | ~108px | 10% de altura ✅ |
| 720p | ~72px | 10% de altura ✅ |
| 576p | ~58px | 10% de altura ✅ |
| 480p | ~48px | 10% de altura ✅ |

**La proporción se mantiene constante** independientemente de la resolución del jugador.

### Formato de Entrega
- **Resolución:** 300dpi (escaneo)
- **Formato:** PNG con transparencia (después de procesamiento)
- **Líneas:** Negras gruesas (tinta), alto contraste
- **Estilo:** Asimétrico, orgánico, NO pixel art perfecto

### Configuración de Cámara (Estilo Darkest Dungeon)

```gdscript
zoom = Vector2(0.75, 0.75)      # Zoom alejado cinematográfico
position_smoothing_speed = 1.8  # Movimiento lento y pesado
drag_horizontal_enabled = true  # La cámara "se queda atrás"
drag_horizontal_offset = 80.0   # Offset horizontal en píxeles
drag_vertical_enabled = false   # Sin arrastre vertical
anchor_mode = 1                 # Centro del jugador
```

**Estilo Resultante:**
- Personajes ocupan ~10% de altura de pantalla (estilo DD)
- Movimiento de cámara cinematográfico y pesado
- El personaje está "inmerso" en el entorno, no en close-up
- Mucho espacio negativo para mostrar contexto del nivel

### Pipeline
1. Dibujar en papel (lápiz + tinta negra)
2. Escanear/fotografiar (300dpi, buena luz)
3. Procesar en GIMP (ajustar niveles, recortar, transparencia)
4. Exportar PNG individual por sprite

---

## 🎯 PRIORIDAD 1: PERSONAJES JUGABLES

### 1.1 LA REVELADORA (Player Character)

**Concepto:** Mujer empoderada, ex-víctima convertida en cazadora
**Inspiración:** "Big Bad Wolf" - confiada, desafiante, poderosa

#### Descripción Visual Completa

**Cuerpo Base:**
```
SILUETA:
- Altura SPRITE: 144×144px (base definitiva)
- Altura en pantalla (1080p): ~108px (10% de altura)
- Figura femenina estilizada, delgada pero fuerte
- Postura erguida, hombros hacia atrás (confianza)
- Piernas largas (ágil, cazadora)
- Hitbox real: ~72×90px dentro del sprite (área de colisión)

ROSTRO:
- Mandíbula definida (no delicada)
- Ojos grandes y brillantes (ve la verdad)
- Sin sonrisa (seria, determinada)
- Cabello corto/medio, despeinado (movimiento)
- Opcional: Máscara de lobo colgando del cinturón (ironía)

VESTIMENTA:
- Capa/velo flotante detrás (blanco, etéreo)
- Top simple ajustado (movilidad)
- Pantalones/falda rasgada (combate)
- Descalza o botas simples
- Manos con "garras" etéreas (poder de revelar)
  → Dedos alargados con trazos de energía blanca

PALETA:
- Base: Blanco puro (claridad/verdad)
- Detalles: Negro (líneas, sombras)
- Aura: Blanco brillante (overbright)
```

#### Hojas de Sprites Necesarias

**HOJA 1: IDLE & WALK (Prioridad CRÍTICA)**
```
Dimensiones sugeridas: 720×144px (5 frames horizontal)

[Idle - 2 frames]
Frame 1: Postura neutral, capa flotando suavemente
Frame 2: Respiración leve, capa ondea

[Walk - 3 frames]
Frame 1: Pierna izquierda adelante, capa hacia atrás
Frame 2: Centro (contacto con suelo)
Frame 3: Pierna derecha adelante, capa hacia atrás

DETALLES CRÍTICOS:
- Capa siempre en movimiento (viento)
- Postura confiada (cabeza alta)
- Paso decidido (NO tímida)
```

**HOJA 2: JUMP & FALL (Prioridad ALTA)**
```
Dimensiones sugeridas: 576×144px (4 frames horizontal)

[Jump - 1 frame]
- Impulso hacia arriba
- Piernas flexionadas (salto)
- Brazos hacia arriba
- Capa extendida hacia abajo (aire)

[Fall - 1 frame]
- Cayendo, piernas extendidas
- Brazos a los lados
- Capa flotando hacia arriba

[Squash (aterrizaje) - 1 frame]
- Comprimida verticalmente
- Impacto en suelo
- Capa aplastada

[Stretch (rebote) - 1 frame]
- Estirada verticalmente
- Rebote después de aterrizar
- Capa expandiéndose
```

**HOJA 3: TEAR VEIL (Prioridad ALTA)**
```
Dimensiones sugeridas: 864×144px (6 frames horizontal)

[Secuencia de revelación]
Frame 1: Brazos extendidos hacia adelante (alcanzando)
Frame 2: Manos agarran velo invisible
Frame 3: Cuerpo hacia atrás, tensión (tirando)
Frame 4: Momento de ruptura (garras brillan)
Frame 5: Velo arrancado, brazos abiertos (triunfo)
Frame 6: Vuelta a idle (recuperación)

DETALLES CRÍTICOS:
- Garras etéreas brillan en frames 3-5
- Expresión determinada → satisfecha
- Capa ondeando dramáticamente
```

**HOJA 4: DAMAGE & DEATH (Prioridad MEDIA)**
```
Dimensiones sugeridas: 432×144px (3 frames horizontal)

[Damage - 1 frame]
- Retroceso (knockback)
- Expresión de dolor
- Mano en pecho/costado
- Capa agitada

[Death Start - 1 frame]
- Cayendo de rodillas
- Mano en suelo
- Cabeza baja

[Death End - 1 frame]
- Acostada en suelo
- Capa cubriendo parcialmente
- Fade to black (implementación en código)
```

---

## 🎯 PRIORIDAD 2: ENEMIGOS PRINCIPALES

### 2.1 FALSE ENEMY (Tipo 1) - "Las Víctimas"

**Concepto:** Víctimas con máscaras agresivas para protegerse

#### ENMASCARADO (Antes de revelar)

**Descripción Visual:**
```
SILUETA:
- Altura SPRITE: 96×96px
- Altura en pantalla (1080p): ~72px (7% de altura)
- Forma humanoide, postura encorvada agresiva
- Puños cerrados, hombros tensos
- Caminata pesada (defensivo)

MÁSCARA:
- Rostro de "agresor" (dientes afilados, ceño fruncido)
- Ojos rojos pequeños (falsa amenaza)
- Grietas en la máscara (vulnerable bajo superficie)

CUERPO:
- Ropas rasgadas oscuras
- Postura de "mantén distancia"
- Brazos cruzados o puños cerrados

PALETA:
- Gris oscuro/negro
- Acentos rojos (ojos)
```

**Sprites Necesarios:**
```
[Idle Masked - 2 frames] (192×96px)
- Respiración agresiva
- Puños tensos

[Walk Masked - 3 frames] (288×96px)
- Patrulla pesada
- Mirada fija al frente
```

#### REVELADO (Después de revelar)

**Descripción Visual:**
```
TRANSFORMACIÓN:
- MISMO cuerpo, DIFERENTE postura
- Máscara cae/se rompe (visible en suelo)
- Rostro asustado, ojos llorosos

POSTURA:
- Encogido, manos cubriendo rostro
- Hombros hacia adelante (protección)
- Temblando visiblemente

EXPRESIÓN:
- Ojos grandes, asustados
- Boca temblando
- Lágrimas (opcional)

PALETA:
- Azul pálido (tristeza)
- Blanco en rostro (vulnerable)
```

**Sprites Necesarios:**
```
[Idle Revealed - 2 frames] (128x48px)
- Temblando
- Manos en rostro

[Flee - 3 frames] (192x48px)
- Corriendo asustado
- Mirando hacia atrás
- Brazos protectores
```

---

### 2.2 FALSE FRIEND (Tipo 2) - "Los Depredadores"

**Concepto:** Manipuladores con máscaras amigables

#### ENMASCARADO (Antes de revelar)

**Descripción Visual:**
```
SILUETA:
- Altura SPRITE: 112×112px
- Altura en pantalla (1080p): ~84px (8% de altura)
- Forma humanoide amigable
- Brazos abiertos (acogedor)
- Postura relajada

MÁSCARA:
- Sonrisa amplia (DEMASIADO perfecta)
- Ojos cerrados/medias lunas (falsa calidez)
- Expresión congelada (no natural)

CUERPO:
- Ropas cálidas (amarillo/naranja en concepto)
- Postura de "ven aquí"
- Puede sostener objeto brillante (cebo)

PALETA (CONCEPTO):
- Amarillo/naranja cálido
- Después procesado a blanco/negro + aura
```

**Sprites Necesarios:**
```
[Idle Masked - 2 frames] (224×112px)
- Brazos haciendo señas
- Balanceándose suavemente
- Sonrisa permanente
```

#### REVELADO (Después de revelar)

**Descripción Visual:**
```
TRANSFORMACIÓN DRAMÁTICA:
- Cuerpo se DEFORMA (horror corporal)
- Máscara se ROMPE (caída dramática)
- Monstruo emerge
- Crecimiento visible (112px → 144px de altura)

FORMA MONSTRUOSA:
- Altura SPRITE: 144×144px (transformado)
- Garras largas, afiladas (4-5 dedos)
- Dientes grandes, irregulares
- Boca abierta (rugido permanente)
- Ojos rojos brillantes, múltiples
- Cuerpo más grande (transformación)
- Postura agresiva (cazador)

DETALLES:
- Saliva goteando
- Músculos tensos
- Cola opcional (bestial)

PALETA:
- Rojo violento (ira/sangre)
- Negro profundo (sombras)
- Blanco en dientes/ojos (contraste)
```

**Sprites Necesarios:**
```
[Transformation - 4 frames] (Variable) - CRÍTICO
Frames 1-2: 224×112px (máscara agrietándose, cuerpo expandiéndose)
Frames 3-4: 288×144px (garras emergiendo, rugido final)

[Idle Revealed - 2 frames] (288×144px)
- Respiración agresiva
- Garras listas

[Chase - 3 frames] (432×144px)
- Corriendo a cuatro patas
- Saltando
- Garras hacia adelante
```

---

### 2.3 TRUE THREAT (Tipo 3) - "El Sistema"

**Concepto:** Estructuras que parecen objetos inanimados

#### ENMASCARADO (Antes de revelar)

**Descripción Visual:**
```
FORMA DE OBJETO:
- NO humanoide
- Opciones: Estatua, armadura vacía, monolito, maniquí
- Gris piedra, textura de mármol/metal
- Completamente estático (decoración)

SUGERENCIA: ESTATUA
- Figura humanoide rígida, brazos a los lados
- Sin rostro (liso) o máscara sin expresión
- Base de piedra
- Grietas sutiles (revelación futura)

PALETA:
- Gris neutral
- Textura de piedra
```

**Sprites Necesarios:**
```
[Idle Masked - 1 frame] (128×160px)
- Completamente estático
- Sin animación (es un objeto)
```

#### REVELADO (Después de revelar)

**Descripción Visual:**
```
DESPERTAR ELDRITCH:
- Estatua se "abre" (grietas expanden)
- Interior orgánico (horror cósmico)
- Tentáculos emergen de grietas
- Ojos múltiples aparecen (3-7 ojos)
- Boca abre en centro (sin dientes, vacío)

FORMA REVELADA:
- Base de estatua permanece (no se mueve)
- Parte superior orgánica, pulsante
- Tentáculos ondeando (2-4)
- Ojos parpadeando independientemente
- Respiración visible (expandir/contraer)

DETALLES:
- Textura orgánica (venas, músculos)
- Baba/líquido goteando
- Aura púrpura (implementada en código)

PALETA:
- Púrpura oscuro (corrupción)
- Negro (sombras profundas)
- Blanco en ojos (contraste)
- Gris piedra (base original)
```

**Sprites Necesarios:**
```
[Awaken - 4 frames] (128×192px) - CRÍTICO
Frame 1: Grietas aparecen
Frame 2: Grietas expanden, luz púrpura dentro
Frame 3: Tentáculos emergen
Frame 4: Ojos abren (forma final)

[Idle Revealed - 2 frames] (128×192px)
Frame 1: Contraído (inhala)
Frame 2: Expandido (exhala)
- Tentáculos ondean
- Ojos parpadean

[Attack - 2 frames] (128×192px)
Frame 1: Tensión (carga)
Frame 2: Disparo (proyectil sale de boca)
```

---

## 🎯 PRIORIDAD 3: VARIANTES DE ENEMIGOS (Opcional Día 2)

### 3.1 FALSE ENEMY FAST (Versión Rápida)

**Diferencias visuales:**
- MISMO diseño base que False Enemy
- Añadir: Líneas de velocidad en sprites
- Añadir: Postura más inclinada (aerodinámico)
- Color ligeramente más claro (distinción)

**Sprites:** Reutilizar False Enemy base + ajustes

---

### 3.2 FALSE FRIEND JUMPER (Versión Saltadora)

**Diferencias visuales:**
- MISMO diseño base revelado
- Añadir: Piernas más musculosas
- Añadir: Postura agachada (lista para saltar)

**Sprites Adicionales:**
```
[Jump Attack - 3 frames] (192x80px)
Frame 1: Agachado (carga)
Frame 2: Aire (saltando)
Frame 3: Caída (garras extendidas)
```

---

### 3.3 TRUE THREAT Variantes

**BURST (Ráfagas):**
- Color rojo en lugar de púrpura
- 3 bocas pequeñas en lugar de 1 grande

**TRACKING (Rotatoria):**
- Ojo central grande (apunta)
- Base rotatoria visible

**LASER (Láser Continuo):**
- Ojo único gigante
- Cristal en centro

**SHIELD (Con Escudo):**
- Escudo azul flotante (sprite separado)
- 2 capas de revelación

---

## 🎯 PRIORIDAD 4: ESCENARIOS Y TILESETS

### 4.1 Tileset Base (CRÍTICO)

**Concepto:** Minimalista, blanco/negro, plataformas flotantes

#### Tiles Necesarios (48×48px cada uno)

```
NOTA: Tiles base escalados 3x (antes 16×16px)
- Tile base: 48×48px (1/3 del tamaño del jugador)
- Proporción perfecta con sprites de 144px

PLATAFORMAS:
[1] Plataforma sólida - Centro
[2] Plataforma sólida - Borde izquierdo
[3] Plataforma sólida - Borde derecho
[4] Plataforma sólida - Esquina inferior izquierda
[5] Plataforma sólida - Esquina inferior derecha

PAREDES:
[6] Pared vertical
[7] Esquina superior izquierda
[8] Esquina superior derecha

DECORACIÓN:
[9] Grietas (overlay)
[10] Manchas/texturas
```

**Estilo Visual:**
- Líneas irregulares (orgánico, no geométrico)
- Textura de piedra/mármol
- Grietas y desgaste (mundo en decadencia)
- Alto contraste (negro sobre blanco)

**Dimensiones:** Hoja de 480×48px (10 tiles horizontal)

---

### 4.2 Assets de Nivel (Objetos Únicos)

#### PUERTAS DE VERDADES (CRÍTICO)

**Descripción Visual:**
```
PUERTA CERRADA:
- Marco de piedra vertical (96×192px)
- Centro bloqueado con velo/niebla
- Contador de verdades visible arriba
- Textura de piedra antigua

PUERTA ABIERTA:
- MISMO marco
- Centro transparente/vacío
- Contador completo (verde)
- Luz blanca emanando
```

**Sprites Necesarios:**
```
[Door Closed - 1 frame] (96×192px)
[Door Opening - 3 frames] (288×192px)
[Door Open - 1 frame] (96×192px)
```

---

#### LEVEL GOAL (Meta de Nivel)

**Descripción Visual:**
```
CONCEPTO: Portal/Vórtice de luz

DISEÑO:
- Círculo de luz blanca brillante (144×144px)
- Fragmentos de velo flotando hacia dentro
- Aura blanca pulsante (código)
- Base de piedra simple

ANIMACIÓN:
- 2 frames (pulso)
- Fragmentos rotando
```

---

### 4.3 Fondos (OPCIONAL - Día 2)

**Layer 1 (Muy atrás):**
- Niebla gris oscura
- Formas abstractas difusas
- Parallax lento

**Layer 2 (Medio):**
- Plataformas lejanas flotantes
- Siluetas de estatuas
- Parallax medio

**Estilo:** Minimalista, más sugerido que detallado

---

## 🎯 PRIORIDAD 5: INTERFAZ DE USUARIO

### 5.1 HUD (Heads-Up Display)

#### CORAZONES DE VIDA (CRÍTICO)

**Descripción Visual:**
```
CORAZÓN LLENO:
- Forma de corazón anatómico (NO cartoon)
- Blanco con borde negro
- Textura orgánica (venas sutiles)
- Tamaño: 24x24px

CORAZÓN VACÍO:
- MISMO diseño
- Solo contorno negro
- Interior transparente/gris oscuro
```

**Sprites:** 2 frames (lleno, vacío) - 48x24px total

---

#### CONTADOR DE VERDADES

**Descripción Visual:**
```
ICONO: Ojo abierto estilizado
- Forma de ojo con iris
- Blanco/negro
- Tamaño: 32x32px

TEXTO:
- Fuente gótica (Cinzel o Crimson Text)
- Formato: "X / Y" o solo "X"
- Color blanco sobre fondo semi-transparente
```

---

### 5.2 Menú Principal (CRÍTICO)

**Elementos Necesarios:**

```
LOGO DEL JUEGO:
- "VEIL" en fuente gótica grande
- Decoración: Velo desgarrado de fondo
- Tagline debajo: "Tear the veil. Face the truth."
- Tamaño: 400x200px

BOTONES:
[Play] - 200x60px
[Options] - 200x60px
[Quit] - 200x60px

DISEÑO DE BOTÓN:
- Rectángulo con borde irregular (papel rasgado)
- Texto centrado en fuente gótica
- Estados: Normal, Hover (brillante), Pressed
```

---

### 5.3 Pantallas de Ending (MEDIA PRIORIDAD)

**ENDING 1: IGNORANCE**
```
ILUSTRACIÓN:
- Protagonista de espaldas
- Máscara en mano (poniéndosela)
- Caminando hacia niebla
- Postura derrotada
- Tamaño: 400x300px
```

**ENDING 2: AWAKENING**
```
ILUSTRACIÓN:
- Protagonista mirando atrás
- Expresión cansada, lágrimas
- Velos rotos en suelo
- Postura exhausta
- Tamaño: 400x300px
```

**ENDING 3: REVELATION**
```
ILUSTRACIÓN:
- Protagonista de pie en cima de velos
- Postura triunfante, brazos abiertos
- Aura blanca brillante (código)
- Capa ondeando dramática
- Mirada desafiante
- Tamaño: 400x300px
```

---

### 5.4 Elementos UI Adicionales (BAJA PRIORIDAD)

```
[Pause Menu Background]
- Velo semi-transparente oscuro
- 640x480px (fullscreen)

[Victory Screen Banner]
- "NIVEL COMPLETO" en fuente gótica
- Decoración de velos rotos
- 400x100px

[Game Over Screen]
- "VEIL REMAINS" o similar
- Máscara rota
- 400x100px
```

---

## 📋 CHECKLIST DE ENTREGA POR PRIORIDAD

### ✅ CRÍTICO (Día 1 - Mínimo Viable)

**Personajes:**
- [ ] Player: Idle, Walk, Jump, Fall, Tear Veil (básico)
- [ ] False Enemy: Idle Masked, Walk Masked, Idle Revealed, Flee
- [ ] False Friend: Idle Masked, Transformation, Idle Revealed, Chase
- [ ] True Threat: Idle Masked, Awaken, Idle Revealed, Attack

**Escenarios:**
- [ ] Tileset base (10 tiles mínimo)
- [ ] Puerta de verdades (cerrada, abierta)
- [ ] Level Goal (portal)

**UI:**
- [ ] Corazones (lleno, vacío)
- [ ] Icono de verdades (ojo)
- [ ] Logo del juego
- [ ] Botones de menú (3 estados)

---

### 🟡 IMPORTANTE (Día 2 - Pulido)

**Personajes:**
- [ ] Player: Damage, Death, animaciones mejoradas
- [ ] Variantes de enemigos (Fast, Jumper, etc.)

**Escenarios:**
- [ ] Fondos con parallax (2 layers)
- [ ] Decoración adicional

**UI:**
- [ ] Pantallas de endings (3 ilustraciones)
- [ ] Victory/Game Over screens

---

### 🟢 OPCIONAL (Si hay tiempo)

**Personajes:**
- [ ] Evolución visual del player (3 versiones)
- [ ] Animaciones adicionales (emotes, idles variados)

**Escenarios:**
- [ ] Props decorativos (estatuas, columnas)
- [ ] Efectos visuales estáticos

**UI:**
- [ ] Transiciones animadas
- [ ] Cutscenes estáticas

---

## 🎨 Referencias Visuales Sugeridas

### Para el Player (La Reveladora)
- **Personajes:** Bayonetta (confianza), 2B (NieR Automata - capa), Hollow Knight (silueta simple)
- **Estética:** Grabados de brujas medievales, art nouveau femenino

### Para False Enemy
- **Transformación:** Jekyll & Hyde, The Babadook (amenaza → vulnerabilidad)
- **Postura revelada:** Gollum (LOTR), víctimas de Darkest Dungeon

### Para False Friend
- **Transformación:** The Thing (John Carpenter), Resident Evil transformaciones
- **Monstruo:** Wendigo, criaturas de Silent Hill

### Para True Threat
- **Estatuas:** Weeping Angels (Doctor Who), SCP-173
- **Revelado:** Bloodborne bosses, Cthulhu mythos, Junji Ito

### Para Escenarios
- **Arquitectura:** M.C. Escher (imposible), Limbo (plataformas flotantes)
- **Estética:** Sin City (blanco/negro puro), Don't Starve

---

## 📐 Tabla de Dimensiones Rápida

**Resolución Base: 1080p (1920×1080) - Zoom de cámara: 0.75**

| Tipo | Dimensiones Sprite | En Pantalla (1080p) | Prioridad |
|------|-------------------|---------------------|-----------|
| **Player** | 144×144px | ~108px (10% altura) | CRÍTICA |
| **False Enemy** | 96×96px | ~72px (7% altura) | CRÍTICA |
| **False Friend (máscara)** | 112×112px | ~84px (8% altura) | CRÍTICA |
| **False Friend (revelado)** | 144×144px | ~108px (10% altura) | CRÍTICA |
| **True Threat** | 128×192px | ~96×144px | CRÍTICA |
| **Jefes** | 192-256×256px | ~144-192px | MEDIA |
| **Tileset** | 48×48px por tile | ~36px (1/3 player) | CRÍTICA |
| **UI Icons** | 48×48px | Escala UI separada | CRÍTICA |
| **Logo** | 600×300px | Escala UI separada | CRÍTICA |
| **Botones** | 300×90px | Escala UI separada | CRÍTICA |
| **Endings** | 800×600px | Escala UI separada | MEDIA |
| **Fondos** | 1920×1080px | Fullscreen | OPCIONAL |

**Sistema Modular:** Todos los sprites son múltiplos de 16, con 48px como unidad base (1 tile = 1/3 del jugador).

---

## 🛠️ Consejos de Producción

### Para Dibujo en Papel

1. **Usar plantilla:** Crear cuadrícula de 144×144px para jugador, 96×96px para enemigos normales
2. **Líneas gruesas:** Usar marcador/rotring (mín 0.5mm) para buen escaneo
3. **Alto contraste:** NO grises medios - solo negro puro o blanco
4. **Asimetría:** Hacer dibujos orgánicos, NO perfectamente simétricos
5. **Múltiples intentos:** Dibujar 2-3 versiones, escanear la mejor
6. **Considerar zoom:** Dibujar como si el personaje se viera a distancia (10% de altura)

### Para Escaneo

1. **Resolución:** Mínimo 300dpi (preferible 600dpi)
2. **Formato:** PNG o TIFF (NO JPG - pierde calidad)
3. **Iluminación:** Luz uniforme, sin sombras en papel
4. **Alineación:** Papel perfectamente recto (usar guías)

### Para Procesamiento (GIMP/Photoshop)

1. **Levels adjustment:** Empujar negros y blancos al extremo
2. **Threshold:** Convertir grises residuales a blanco/negro puro
3. **Alpha channel:** Eliminar fondo blanco, dejar solo líneas negras
4. **Recorte:** Crop ajustado a dimensiones especificadas
5. **Export:** PNG-8 con transparencia

---

## 📞 Comunicación con Programador

### Al Entregar Assets

Incluir archivo de texto con:
```
sprite_name.png
- Dimensiones: 64x64px
- Frames: 4 horizontal
- Uso: Player walk cycle
- Notas: Frame 2 es contacto con suelo
```

### Nomenclatura de Archivos

```
[tipo]_[nombre]_[estado]_[acción].png

Ejemplos:
player_idle.png
player_walk.png
player_tear_veil.png
enemy_false_masked_idle.png
enemy_false_revealed_flee.png
enemy_true_masked.png
enemy_true_revealed_attack.png
tileset_main.png
ui_heart_full.png
ui_heart_empty.png
```

---

## ✅ Aprobación de Concepto

Antes de dibujar en final:
1. Hacer bocetos rápidos (lápiz)
2. Mostrar al equipo para feedback
3. Iterar si necesario
4. LUEGO pasar a tinta y escaneo

**Regla:** "Sketch rápido > Feedback temprano > Tinta final"

---

**Última actualización:** 2026-02-05
**Versión:** 2.0
**Estado:** Arquitectura 1080p + Cámara DD - Listo para producción

---

## 📋 Historial de Cambios

**v2.0 (2026-02-05):**
- Actualización completa de arquitectura de assets para 1080p
- Nueva configuración de cámara estilo Darkest Dungeon
- Sistema modular base 48px (1/3 del jugador)
- Todas las dimensiones de sprites actualizadas
- Tabla de dimensiones rápida con proporciones de pantalla

**v1.0 (2026-01-31):**
- Versión inicial del documento
- Especificaciones base para arte del juego

---

*"Cada sprite cuenta una historia. Cada línea revela una verdad."*
