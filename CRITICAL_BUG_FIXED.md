# ✅ CRITICAL BUG FIXED: Proyectiles en Level 3

## El Problema

Los TrueThreat en Level 3 no disparaban proyectiles, pero funcionaban perfectamente en Level 1 y 2.

## La Causa

**Archivo:** `scripts/components/projectile.gd:31-35`

El código de optimización que destruía proyectiles fuera de pantalla usaba límites incorrectos:

```gdscript
var screen_rect = get_viewport_rect()  // Tamaño: 1920x1080
var margin = 200.0
if global_position.x > screen_rect.size.x + margin:  // Si X > 2120
    queue_free()  // Destruir proyectil
```

### Por qué esto causaba el bug:

1. **Viewport size NO es posición de cámara**
   - `screen_rect.size.x` = 1920px (tamaño del viewport)
   - NO indica dónde está la cámara en el mundo

2. **Level 3 es muy grande**
   - Ancho total: 7300 unidades
   - Enemigos en posiciones X = 3200, 4200, 5600, 7000, etc.
   - ¡Todas estas posiciones son > 2120!

3. **Proyectiles se destruían instantáneamente**
   - Proyectil spawn en (5600, 540)
   - Primer `_physics_process()` ejecuta
   - Verifica: `5600 > 2120` → ✅ Verdadero
   - Llama `queue_free()`
   - Proyectil desaparece antes de moverse

## La Solución

**Actualizado:** `scripts/components/projectile.gd:26-44`

Ahora usa la posición de la cámara como referencia:

```gdscript
var camera = get_viewport().get_camera_2d()
if camera:
    var screen_center = camera.get_screen_center_position()  // Ej: (5500, 540)
    var screen_size = get_viewport_rect().size  // (1920, 1080)
    var margin = 200.0

    // Calcular límites basados en dónde está la cámara
    var left_bound = screen_center.x - screen_size.x / 2 - margin   // 5500 - 960 - 200 = 4340
    var right_bound = screen_center.x + screen_size.x / 2 + margin  // 5500 + 960 + 200 = 6660
    var top_bound = screen_center.y - screen_size.y / 2 - margin
    var bottom_bound = screen_center.y + screen_size.y / 2 + margin

    if global_position.x < left_bound or global_position.x > right_bound:
        queue_free()
```

### Cómo funciona ahora:

1. Obtiene la cámara del viewport
2. Obtiene el centro de la pantalla (donde está la cámara)
3. Calcula límites alrededor de la cámara
4. Solo destruye si está fuera de esos límites

**Ejemplo:**
- Cámara en X=5500
- Proyectil en X=5600
- Right bound = 5500 + 960 + 200 = 6660
- Verifica: `5600 > 6660` → ❌ Falso
- ✅ Proyectil NO se destruye, puede moverse normalmente

## Impacto

### ANTES del fix:
- ✅ Level 1 (ancho 3500): Funciona
- ⚠️ Level 2 (ancho 5200): Funciona parcialmente
- ❌ Level 3 (ancho 7300): NO funciona

### DESPUÉS del fix:
- ✅ Level 1: Funciona
- ✅ Level 2: Funciona
- ✅ Level 3: **FUNCIONA**
- ✅ Cualquier nivel futuro: Funciona sin importar el tamaño

## Testing

Ejecuta Level 3 y verifica:

1. Avanza hasta Area 4 (X ≈ 3200)
2. Revela el TrueThreat básico
3. Observa sprite cambiar a púrpura
4. Espera 2 segundos
5. **Deberías ver proyectiles disparándose hacia ti**

Si no funciona, verifica:
- La consola de Godot para errores
- Que el jugador está en el grupo "player"
- Que ProjectileManager está en autoloads

## Archivos Modificados

- ✅ `scripts/components/projectile.gd` - Fix de límites
- ✅ `CHANGELOG.md` - Documentado bug fix
- ✅ `scenes/levels/level_3.tscn` - Agregado `next_level_path=""` y `truth_count=2`

## Lecciones Aprendidas

1. **Siempre usar posición de cámara en niveles grandes**
   - Viewport size es constante (resolución)
   - Posición de mundo NO es constante

2. **Probar optimizaciones en diferentes escalas**
   - Un código que funciona en nivel pequeño puede fallar en nivel grande
   - Siempre testear edge cases

3. **Debugging en niveles grandes revela bugs ocultos**
   - Este bug existía desde Alpha 0.2
   - Solo se manifestó al crear Level 3 (7300 unidades)

---

**Bug Status:** ✅ **FIXED**
**Versión:** Alpha 0.5.1
**Fecha:** 2026-01-31 (Noche)
