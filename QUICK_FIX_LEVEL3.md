# Quick Fix: TrueThreat No Dispara en Level 3

## Problema
Los TrueThreat en Level 3 no están spawneando proyectiles.

## Soluciones Ordenadas por Probabilidad

### Fix #1: Verificar Grupos del Player (MÁS PROBABLE)

El problema más común es que el Player no está en el grupo correcto.

**Pasos:**
1. Abre `scenes/levels/level_3.tscn` en Godot
2. Selecciona el nodo "Player" en el árbol de escena
3. En el Inspector, busca la sección "Node" en la parte superior
4. Haz clic en el botón "Groups" (icono de personas)
5. Verifica que existe un grupo llamado "player" (en minúscula)
6. Si NO existe:
   - Escribe "player" en el campo de texto
   - Presiona "Add"
7. Guarda la escena
8. Prueba nuevamente

**Por qué esto arregla el problema:**
- El script `true_threat.gd:55` busca el jugador con `get_tree().get_first_node_in_group("player")`
- Si el Player no está en el grupo "player", `player_ref` será null
- Sin `player_ref`, los proyectiles no se disparan (línea 68)

---

### Fix #2: Verificar Instancias de Escena

Las instancias pueden haberse corrompido al crear el nivel.

**Pasos:**
1. Abre `scenes/levels/level_3.tscn`
2. Selecciona uno de los TrueThreat (ejemplo: "Area4_TrueThreat")
3. Haz clic derecho → "Editable Children" (debe estar DESMARCADO)
4. Si está marcado, desmárcalo
5. Repite para TODOS los TrueThreat en el nivel
6. Guarda y prueba

**Por qué esto arregla el problema:**
- Si "Editable Children" está activo, la instancia está "rota" de la escena padre
- Cambios en `true_threat.tscn` no se aplicarán
- Puede causar comportamiento impredecible

---

### Fix #3: Usar Script de Debug

He creado `true_threat_DEBUG.gd` que muestra mensajes detallados en la consola.

**Pasos:**
1. Abre `scenes/characters/entities/true_threat.tscn`
2. Selecciona el nodo raíz "TrueThreat"
3. En Inspector → Script, cambia de `true_threat.gd` a `true_threat_DEBUG.gd`
4. Guarda la escena
5. Ejecuta Level 3
6. Revela un TrueThreat
7. Mira la consola de Godot (bottom panel)

**Qué buscar en la consola:**

✅ **Si ves:** `✅ PLAYER FOUND!` → El player se encontró correctamente
❌ **Si ves:** `❌ PLAYER NOT FOUND!` → El player no está en el grupo "player" (usa Fix #1)

✅ **Si ves:** `✅ PROJECTILE ADDED TO MANAGER!` → Todo funciona bien
❌ **Si NO ves:** Ningún mensaje `FIRE TIMER TIMEOUT` → El timer no se inicia (problema en VeilComponent)

---

### Fix #4: Verificar ProjectileManager

Poco probable, pero el ProjectileManager podría no estar cargado.

**Pasos:**
1. Abre `Project → Project Settings → Autoload`
2. Verifica que existe una entrada "ProjectileManager"
3. El path debe ser: `res://scripts/autoloads/projectile_manager.gd`
4. El checkbox "Enable" debe estar marcado
5. Si falta, añádelo manualmente
6. Reinicia Godot

---

### Fix #5: Limpiar Cache de Godot

A veces Godot cachea versiones viejas de escenas.

**Pasos:**
1. Cierra Godot completamente
2. En el explorador de archivos, navega a tu proyecto
3. Elimina la carpeta `.godot/` (carpeta oculta)
4. Abre el proyecto nuevamente
5. Deja que Godot reimporte todo
6. Prueba Level 3

---

## Test Simple

Para verificar que el problema es específico de Level 3:

**Test A: TrueThreat funciona en Level 1**
1. Ejecuta Level 1
2. Avanza hasta encontrar un TrueThreat
3. Revélalo con E
4. Espera 2 segundos
5. ¿Dispara proyectiles?
   - ✅ SÍ → El problema es específico de Level 3
   - ❌ NO → El problema es global (TrueThreat roto en general)

**Test B: TrueThreat simple en Level 3**
1. Abre `level_3.tscn`
2. Bajo "Entities", agrega una nueva instancia de `true_threat.tscn`
3. Ponla en Position X=500, Y=540 (cerca del spawn)
4. Ejecuta Level 3
5. Da 2 pasos y revélala inmediatamente
6. ¿Dispara?
   - ✅ SÍ → Los TrueThreat existentes están corruptos, reemplázalos
   - ❌ NO → El problema es el Player o ProjectileManager

---

## Chequeo Final: Comparar con Level 1

Si nada funciona, compara las configuraciones:

**Level 1 (FUNCIONA):**
```
Abre level_1.tscn → Player → Groups → debe decir "player"
Abre level_1.tscn → Entities → Area4_TrueThreat1 → Inspector → debe tener script
```

**Level 3 (NO FUNCIONA):**
```
Abre level_3.tscn → Player → Groups → ¿dice "player"?
Abre level_3.tscn → Entities → Area4_TrueThreat → Inspector → ¿tiene script?
```

Si hay diferencias, ahí está el problema.

---

## Mi Apuesta: Es Fix #1

Basándome en que:
1. Funciona en Level 1 y 2
2. NO funciona en Level 3
3. Level 3 se creó recientemente
4. El código es idéntico

**La causa más probable es que el Player en level_3.tscn no está en el grupo "player".**

Esto pasa porque cuando copias/creates un nuevo nivel, a veces los grupos no se copian automáticamente.

Prueba Fix #1 primero. Si no funciona, prueba Fix #3 (debug script) para ver exactamente qué falla.
