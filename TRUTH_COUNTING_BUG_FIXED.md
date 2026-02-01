# ✅ Bug Fix: Truth Double-Counting

## El Problema

Todas las torretas (excepto shield) daban **2 verdades** en lugar de 1 al revelarse, permitiendo obtener más del 100% de verdades en los niveles.

## La Causa

**Double-counting** en dos scripts de torretas:

```gdscript
// VeilComponent.gd:33 (CORRECTO)
func tear_veil() -> void:
    GameManager.reveal_truth()  // ✅ Primera llamada
    veil_torn.emit()

// true_threat_burst.gd:53 (INCORRECTO)
func _on_veil_torn() -> void:
    GameManager.reveal_truth()  // ❌ Segunda llamada - DUPLICADO!
```

### Flujo del bug:

1. Jugador presiona E para revelar
2. `VeilComponent.tear_veil()` se ejecuta
3. Llama `GameManager.reveal_truth()` → **+1 verdad** ✅
4. Emite señal `veil_torn`
5. Torreta recibe señal y ejecuta `_on_veil_torn()`
6. Llama `GameManager.reveal_truth()` OTRA VEZ → **+1 verdad** ❌
7. **Total: 2 verdades por revelación**

## Scripts Afectados

| Script | Estado Antes | Estado Ahora |
|--------|--------------|--------------|
| `true_threat.gd` | ✅ Correcto | ✅ Correcto |
| `true_threat_laser.gd` | ✅ Correcto (fix en Alpha 0.3.1) | ✅ Correcto |
| `true_threat_shield.gd` | ✅ Correcto (fix en Alpha 0.3.1) | ✅ Correcto |
| `true_threat_burst.gd` | ❌ Contaba 2x | ✅ **FIXED** |
| `true_threat_tracking.gd` | ❌ Contaba 2x | ✅ **FIXED** |

## La Solución

Removidas las llamadas duplicadas en ambos archivos:

**true_threat_burst.gd:**
```gdscript
// ANTES
func _on_veil_torn() -> void:
    sprite.modulate = Color(0.5, 0.1, 0.6, 1.0)
    GameManager.reveal_truth()  // ❌ REMOVIDO
    shoot_timer.start()

// DESPUÉS
func _on_veil_torn() -> void:
    sprite.modulate = Color(0.5, 0.1, 0.6, 1.0)
    // NOTA: VeilComponent ya contó esta verdad automáticamente
    shoot_timer.start()
```

**true_threat_tracking.gd:**
```gdscript
// ANTES
func _on_veil_torn() -> void:
    laser_sight.visible = true
    GameManager.reveal_truth()  // ❌ REMOVIDO
    shoot_timer.start()

// DESPUÉS
func _on_veil_torn() -> void:
    laser_sight.visible = true
    // NOTA: VeilComponent ya contó esta verdad automáticamente
    shoot_timer.start()
```

## Impacto

### ANTES del fix:

**Level 2 (ejemplo):**
- 11 entidades totales
- 2 TrueThreatShield (cuentan 2 cada una) = 4 verdades
- 2 TrueThreatBurst (contaban 2 cada una) = 4 verdades ❌
- 2 TrueThreatTracking (contaban 2 cada una) = 4 verdades ❌
- 5 otras entidades normales = 5 verdades
- **Total reportado: 17 verdades** (debería ser 12)
- **Porcentaje máximo: 142%** ❌

### DESPUÉS del fix:

**Level 2:**
- 11 entidades totales
- 2 TrueThreatShield (cuentan 2 cada una) = 4 verdades ✅
- 2 TrueThreatBurst (cuentan 1 cada una) = 2 verdades ✅
- 2 TrueThreatTracking (cuentan 1 cada una) = 2 verdades ✅
- 5 otras entidades normales = 5 verdades ✅
- **Total correcto: 12 verdades**
- **Porcentaje máximo: 100%** ✅

**Level 3:**
- 16 entidades totales
- 1 TrueThreatShield (cuenta 2) = 2 verdades ✅
- 2 TrueThreatBurst (cuentan 1 cada una) = 2 verdades ✅
- 2 TrueThreatTracking (cuentan 1 cada una) = 2 verdades ✅
- 11 otras entidades normales = 11 verdades ✅
- **Total correcto: 17 verdades**
- **Porcentaje máximo: 100%** ✅

## Testing

**Test 1: Verificar conteo correcto**
1. Ejecuta Level 2
2. Observa el contador de verdades en el HUD
3. Revela un TrueThreatBurst o TrueThreatTracking
4. El contador debe aumentar en **1** (no 2)

**Test 2: Verificar 100% máximo**
1. Ejecuta cualquier nivel
2. Revela TODAS las entidades
3. Al completar, la pantalla de victoria debe mostrar:
   - Level 1: 6/6 verdades (100%)
   - Level 2: 12/12 verdades (100%)
   - Level 3: 17/17 verdades (100%)
4. **NO debería ser posible obtener más del 100%**

**Test 3: Verificar endings correctos**
1. Completa los 3 niveles revelando todo
2. Total: 6 + 12 + 17 = **35 verdades**
3. Ending Screen debe mostrar: "35/35 (100%)"
4. Debería activarse el ending "El Revelador" (>80%)

## Archivos Modificados

- ✅ `scripts/entities/true_threat_burst.gd` - Removida línea 53
- ✅ `scripts/entities/true_threat_tracking.gd` - Removida línea 81
- ✅ `CHANGELOG.md` - Documentado fix (Alpha 0.5.2)

## Por Qué Ocurrió Este Bug

1. **Alpha 0.2:** Sistema de verdades implementado
2. **Alpha 0.3.0:** Variantes de TrueThreat creadas (Burst, Tracking, Laser, Shield)
3. **Alpha 0.3.1:** Bug detectado en Laser, se corrigió
4. **Alpha 0.3.1:** Bug detectado en Shield, se corrigió
5. **PERO:** Burst y Tracking NO se revisaron → Bug permaneció
6. **Alpha 0.5.2:** Usuario reporta >100% → Bug finalmente descubierto y corregido

## Lecciones Aprendidas

1. **Refactoring incompleto:** Al corregir un bug en un archivo, SIEMPRE revisar archivos similares
2. **Testing de límites:** Testear que los valores máximos sean exactamente lo esperado (no solo "funciona")
3. **Code review:** Scripts con patrones similares deben revisarse juntos

---

**Bug Status:** ✅ **COMPLETELY FIXED**
**Versión:** Alpha 0.5.2
**Fecha:** 2026-01-31 (Noche)
