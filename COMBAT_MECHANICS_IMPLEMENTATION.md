# VEIL - Implementación de Mecánicas de Combate
**Fecha:** 2026-01-31
**Estado:** ✅ Veil Shards + Wolf's Howl IMPLEMENTADOS

---

## 🎮 Mecánicas Implementadas

### 1. ⚔️ Veil Shards (Fragmentos de Velo)

**NARRATIVA:** "Tu máscara rota es MI arma ahora"

#### ¿Cómo funciona?
- **Generación:** Cada vez que revelas un enemigo, obtienes 1 shard (máximo 3 almacenados)
- **Visual:** Los shards orbitan alrededor del jugador (radio 32px)
- **Lanzamiento:** Click derecho del mouse / Botón R (gamepad)
- **Comportamiento:**
  - Vuelan a 250 px/s en la dirección del cursor/movimiento
  - Destruyen proyectiles de True Threats
  - Dañan False Friends (3 hits para eliminar)
  - **Atraviesan** False Enemies sin dañarlos (son víctimas)

#### Archivos creados/modificados:
- ✅ `scripts/components/veil_shard.gd` - NUEVO
- ✅ `scenes/components/veil_shard.tscn` - NUEVO
- ✅ `scripts/core/player_controller.gd` - Sistema de shards
- ✅ `scripts/core/reveal_system.gd` - Generación al revelar
- ✅ `scripts/ui/hud.gd` - Contador de shards
- ✅ `scripts/entities/false_friend.gd` - Recibir daño de shards

#### Feedback visual:
- Shards orbitando con rotación
- Partículas al lanzar
- Partículas de impacto (blanco brillante)
- Partículas de destrucción de proyectiles (azul/blanco)

---

### 2. 🐺 Wolf's Howl (Grito de Lobo)

**NARRATIVA:** "Ya no tengo miedo - ahora TODOS escucharán la verdad"

#### ¿Cómo funciona?
- **Activación:** Mantener tecla E por 1.5 segundos
- **Radio:** 96px (doble del rango de reveal)
- **Efecto:** Aturde a TODOS los enemigos revelados en área por 2 segundos
- **Cooldown:** 8 segundos
- **Efectos específicos:**
  - **False Friends:** Se quedan congelados, vulnerables
  - **True Threats:** Dejan de disparar temporalmente
  - **False Enemies:** Huyen el doble de rápido (terror extremo)

#### Archivos modificados:
- ✅ `scripts/core/reveal_system.gd` - Sistema de carga y howl
- ✅ `scripts/entities/false_friend.gd` - Método stun()
- ✅ `scripts/entities/false_enemy.gd` - Método stun() con terror
- ✅ `scripts/entities/true_threat.gd` - Método stun()
- ✅ `scripts/entities/true_threat_shield.gd` - Método stun()

#### Feedback visual:
- Carga: Sprite del jugador pulsa, partículas de implosión
- Ejecución: Freeze frame intenso, screen shake fuerte, flash blanco
- Partículas: Onda expansiva radial blanca
- Enemigos: Partículas de stun (estrellas amarillas para False Friends, lágrimas azules para False Enemies)

---

## ⚙️ Configuración Requerida

### 1. Input Map (Project Settings > Input Map)

**Necesitas agregar estas acciones de input:**

```
launch_shard:
  - Mouse Button Right (Click derecho)
  - Gamepad Button 9 (R1/RB en Xbox/PS)
  - Keyboard: R (opcional)
```

**Nota:** La acción `reveal` (tecla E) ya existe y se usa tanto para reveal rápido como para cargar howl.

### 2. Collision Layers

Verifica que estén configurados correctamente:

```
Layer 1: World (plataformas, suelo)
Layer 2: Player
Layer 3: Entities (enemigos)
Layer 4: Enemy Projectiles
Layer 5: Player Projectiles (NUEVO - para shards)
```

**Veil Shard:**
- collision_layer = 16 (Layer 5)
- collision_mask = 4 | 8 (Layers 3 y 4 - detecta enemigos y proyectiles)

### 3. Sonidos (Opcionales pero recomendados)

Agregar estos SFX al AudioManager:

```
"shard_collect" - Al obtener un shard (actualmente -8 dB)
"shard_launch" - Al lanzar un shard (actualmente -6 dB)
"wolf_howl" - Al ejecutar el howl (actualmente 0 dB)
```

Si no existen, el juego funcionará pero sin sonidos específicos.

---

## 🎯 Loop de Combate Resultante

### Nuevo Gameplay Loop:

1. **Revelar enemigo** (E rápido) → Generas 1 shard
2. **Shards orbitan** alrededor tuyo (visual de poder acumulado)
3. **Decisión táctica:**
   - **Opción A:** Lanzar shard (Click derecho) para:
     - Destruir proyectiles enemigos (defensa)
     - Dañar False Friends (ofensa)
   - **Opción B:** Mantener E por 1.5s para cargar Howl y aturdir grupo
4. **Cooldown de Howl** - Usar shards mientras esperas
5. **Repetir**

### Sinergias:

- **Howl + Shards:** Aturdir enemigos con Howl, luego eliminarlos con shards mientras están vulnerables
- **Shards defensivos:** Destruir proyectiles de True Threats para sobrevivir
- **Shards ofensivos:** Eliminar False Friends (3 hits cada uno)
- **Howl en emergencias:** Aturdir grupo cuando estás rodeado

---

## 🧪 Testing Checklist

### Veil Shards:
- [ ] Revelar enemigo genera 1 shard (visual de órbita aparece)
- [ ] Máximo 3 shards almacenados
- [ ] Click derecho lanza shard hacia cursor
- [ ] Shard daña False Friend revelado
- [ ] Shard atraviesa False Enemy revelado sin dañarlo
- [ ] Shard destruye proyectil de True Threat
- [ ] HUD muestra contador "Shards: X/3"
- [ ] Partículas de lanzamiento e impacto funcionan

### Wolf's Howl:
- [ ] Mantener E por 1.5s carga el howl (sprite pulsa)
- [ ] Soltar E antes de completar cancela carga
- [ ] Al completar: freeze frame, screen shake, flash blanco
- [ ] Enemigos revelados en área (96px) son aturdidos
- [ ] False Friend congelado con estrellas amarillas
- [ ] False Enemy huye el doble de rápido con lágrimas azules
- [ ] True Threat deja de disparar y se oscurece
- [ ] Cooldown de 8s después de usar
- [ ] No puede usar howl durante cooldown

---

## 🐛 Posibles Problemas y Soluciones

### Problema: "Los shards no se lanzan"
**Solución:** Configurar input `launch_shard` en Project Settings

### Problema: "Los shards no dañan enemigos"
**Solución:** Verificar que False Friends estén revelados (solo dañan enemigos revelados)

### Problema: "El howl no aturde"
**Solución:**
- Verificar que enemigos estén revelados
- Verificar que estén dentro del radio de 96px
- Asegurarse de mantener E por 1.5s completos

### Problema: "Crash al lanzar shard"
**Solución:** Verificar que existe `scenes/components/veil_shard.tscn`

### Problema: "Contador de shards no aparece en HUD"
**Solución:** El label se crea dinámicamente, debería aparecer automáticamente

---

## 📊 Valores de Balanceo

### Veil Shards:
```gdscript
max_shards: 3
shard_orbit_radius: 32.0
shard_orbit_speed: 2.0
speed: 250.0
damage: 1 (False Friends tienen 3 HP)
lifetime: 3.0 segundos
```

### Wolf's Howl:
```gdscript
howl_charge_time_required: 1.5 segundos
howl_radius: 96.0 px
howl_stun_duration: 2.0 segundos
howl_cooldown: 8.0 segundos
```

**Ajustables en Inspector:**
- Player: Veil Shards group
- RevealSystem: Wolf's Howl Parameters group

---

## 🎨 Mejoras Visuales Futuras (Opcional)

### Shards:
- [ ] Sprite custom para shard (actualmente ColorRect blanco)
- [ ] Trail particles detrás del shard en vuelo
- [ ] Efecto de "carga" cuando tienes 3 shards (brillo intenso)

### Howl:
- [ ] Animación de howl específica para jugador
- [ ] Ondas de sonido visuales expandiéndose
- [ ] Distorsión de pantalla tipo "grito sónico"

---

## 🔜 Próxima Mecánica (Opcional)

Si quieres agregar **Moonlight Dash**, las bases están listas:
- Shards ya implementados (genera más al atravesar enemigos)
- Enemigos tienen método stun() (aplicar micro-stun en dash)
- Sistema de iFrames existe (reusar para invencibilidad durante dash)

**Tiempo estimado:** 4-5 horas

---

## 📝 Notas Técnicas

### Prevención de Memory Leaks:
- Todos los Timer usan cleanup automático
- Partículas se auto-destruyen con Timer
- Shards se destruyen al salir de pantalla

### Optimizaciones:
- Shards usan ProjectileManager (evita acumulación en root)
- Partículas one-shot con lifetime corto
- Stun no crea timers infinitos

### Accesibilidad:
- Funciona con mouse (cursor para apuntar shards)
- Funciona con gamepad (lanza en dirección del sprite)
- Funciona solo con teclado (lanza en dirección del sprite)

---

---

## 🔧 Bugfixes Posteriores

### False Enemy Patrol System (2026-01-31)
- ✅ **Fix:** Raycast de detección de suelo corregido
- ✅ **Fix:** Velocidad aumentada (50→120 px/s) para visibilidad
- ✅ **Fix:** Collision layers - Doors separadas de World
- ✅ **Resultado:** False Enemies ahora patrullan visiblemente sin chocar con puertas

Ver: `FALSE_ENEMY_PATROL_FIX.md` para detalles completos.

---

**Última actualización:** 2026-01-31 (Patrol Fix)
**Estado:** Listo para testing completo
**Pendiente:** Configurar input `dash` (pressed:false issue)

---

*"Ya no eres la víctima. Eres el lobo ahora."* 🐺
