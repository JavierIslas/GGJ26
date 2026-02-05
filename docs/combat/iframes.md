# Sistema de iFrames (Invincibility Frames)

## ¿Qué son los iFrames?

Los **iFrames** (Invincibility Frames) son un periodo de invencibilidad temporal después de recibir daño. Es una mecánica estándar en juegos de acción que:

1. **Previene instant-kills** de ataques múltiples rápidos
2. **Da al jugador tiempo para reaccionar** después de ser golpeado
3. **Hace el juego más justo** al premiar el skill en lugar de solo la suerte

## Implementación en VEIL

### Mecánica

Cuando el jugador recibe daño:

1. **Primer hit:** Recibe el daño normalmente (-1 HP)
2. **iFrames activados:** 1 segundo de invencibilidad
3. **Feedback visual:** Sprite parpadea (alpha alterna 1.0 ↔ 0.3)
4. **Hits subsecuentes:** Bloqueados durante el periodo de iFrames
5. **iFrames expiran:** Jugador vulnerable nuevamente

### Parámetros

**En el Inspector del Player:**

```
Damage Group:
├─ Invincibility Duration: 1.0s (ajustable)
└─ Flash Frequency: 0.1s (ajustable)
```

**Valores recomendados:**
- **Easy Mode:** 1.5s de iFrames
- **Normal Mode:** 1.0s de iFrames (actual)
- **Hard Mode:** 0.6s de iFrames

## Casos de Uso

### Caso 1: TrueThreatBurst (Ráfagas)

**Antes:**
```
Ráfaga de 3 proyectiles:
├─ Proyectil 1: -2 HP
├─ Proyectil 2: -2 HP (0.2s después)
└─ Proyectil 3: -2 HP (0.4s después)
Total: -6 HP → Muerte instantánea (tenías 5 HP)
```

**Ahora:**
```
Ráfaga de 3 proyectiles:
├─ Proyectil 1: -1 HP ✅
├─ Proyectil 2: Bloqueado (iFrames) ⛔
└─ Proyectil 3: Bloqueado (iFrames) ⛔
Total: -1 HP → Sobrevives con 4 HP
```

### Caso 2: FalseFriend Contacto

**Antes:**
```
FalseFriend te atrapa:
├─ Frame 1: -1 HP
├─ Frame 2: -1 HP (contacto continuo)
├─ Frame 3: -1 HP
└─ Frame 4: -1 HP
Total: -4 HP en < 0.2s → Casi muerte instantánea
```

**Ahora:**
```
FalseFriend te atrapa:
├─ Frame 1: -1 HP ✅
├─ Frames 2-60: Bloqueado (iFrames activos) ⛔
├─ Frame 61: iFrames expiran
└─ Frame 62: -1 HP si aún en contacto ✅
Total: -1 HP + tiempo para escapar
```

### Caso 3: Múltiples Enemigos

**Escenario:** Proyectil + FalseFriend simultáneamente

**Antes:**
```
├─ Proyectil: -2 HP
└─ FalseFriend: -1 HP
Total: -3 HP de un solo error
```

**Ahora:**
```
├─ Proyectil: -1 HP ✅
└─ FalseFriend: Bloqueado (iFrames) ⛔
Total: -1 HP → Más perdonador
```

## Balance de Daño

### Nuevo Sistema

| Fuente de Daño | Daño | Frecuencia | Con iFrames |
|----------------|------|------------|-------------|
| Proyectil normal | 1 HP | 1 cada 2s | 1 HP cada 2s |
| Ráfaga (3 proyectiles) | 1 HP | 3 en 0.4s | 1 HP total ✅ |
| Láser continuo | 1 HP | Cada 0.1s | 1 HP inicial + 1 HP/s |
| FalseFriend contacto | 1 HP | Continuo | 1 HP inicial, luego 1 HP/s |

### Comparación

**Level 3 completo (17 verdades a revelar):**

**Sin iFrames:**
- Enemigos: 16 entidades
- Proyectiles esperados: ~50
- HP necesario estimado: 15+ HP
- **Resultado:** Imposible con 5 HP

**Con iFrames:**
- Enemigos: 16 entidades
- Hits bloqueados por iFrames: ~30-40
- Hits reales esperados: ~10-15
- HP necesario: 5 HP es suficiente ✅
- **Resultado:** Desafiante pero justo

## Código Técnico

### Método Principal

```gdscript
func take_damage(amount: int) -> void:
	"""Recibe daño y activa iFrames"""
	# Si ya está invencible, ignorar daño
	if is_invincible:
		print("Player is invincible, damage ignored")
		return

	# Aplicar daño
	GameManager.change_health(-amount)

	# Si murió, no activar iFrames
	if GameManager.player_hp <= 0:
		return

	# Activar invencibilidad temporal
	_activate_invincibility()
```

### Activación de iFrames

```gdscript
func _activate_invincibility() -> void:
	is_invincible = true
	invincibility_timer.start()  # 1.0s
	flash_timer.start()          # Parpadeo cada 0.1s
```

### Parpadeo Visual

```gdscript
func _on_flash_timeout() -> void:
	# Alternar entre visible (1.0) e invisible (0.3)
	sprite.modulate.a = 0.3 if sprite.modulate.a == 1.0 else 1.0
```

### Integración en Proyectiles

```gdscript
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Usa el sistema de iFrames
		if body.has_method("take_damage"):
			body.take_damage(damage)  # ✅ Respeta iFrames
		else:
			GameManager.change_health(-damage)  # Fallback
```

## Testing & Debug

### Verificar iFrames Funcionando

1. **Ejecuta el juego**
2. **Observa el comportamiento:**
   - Recibe daño de un proyectil
   - Sprite debe **parpadear** durante 1 segundo
   - Proyectiles subsecuentes **no hacen daño**
   - Después de 1s, sprite **deja de parpadear**

### Mensajes de Consola

Cuando funciona correctamente, verás:

```
Projectile hit player: -1 HP
Player invincible for 1.0 seconds
Projectile hit player: -1 HP
Player is invincible, damage ignored  ← iFrames bloqueando
Player is invincible, damage ignored
Player invincibility ended
```

### Ajustar Parámetros

Si el juego es:

**Muy fácil:**
- Reducir `invincibility_duration` a 0.6s
- Aumentar daño de proyectiles a 2
- Reducir HP a 3

**Muy difícil:**
- Aumentar `invincibility_duration` a 1.5s
- Mantener daño en 1
- Aumentar HP a 7

## Comparación con Otros Juegos

### Ejemplos de iFrames en Juegos Populares

| Juego | iFrames Duration | Feedback Visual |
|-------|------------------|-----------------|
| **Celeste** | 1.5s | Parpadeo blanco |
| **Hollow Knight** | 1.2s | Knockback + parpadeo |
| **Cuphead** | 1.0s | Parpadeo rosa |
| **VEIL** | 1.0s | Parpadeo alpha ✅ |

**VEIL sigue el estándar de la industria.**

## Beneficios del Sistema

### Para el Jugador

1. **Más justo:** Errores no son instant-kills
2. **Más skill-based:** Puedes recuperarte de errores
3. **Feedback claro:** Parpadeo indica invencibilidad
4. **Menos frustración:** Muertes son por errores repetidos, no mala suerte

### Para el Diseño del Juego

1. **Permite ráfagas:** Burst fire es viable sin ser OP
2. **Permite contacto:** Enemigos melee no son instant-kill
3. **Mejor balance:** 5 HP es suficiente para todo el juego
4. **Más opciones:** Futuros bosses pueden usar patrones complejos

## Limitaciones & Edge Cases

### No Protege Contra:

1. **Daño acumulativo lento:** Si recibes 1 hit cada 2 segundos, iFrames no ayudan mucho
2. **Caídas al vacío:** Muerte instantánea (no hay iFrames para esto)
3. **Ataques especiales futuros:** Bosses pueden tener ataques que ignoren iFrames

### Diseño Intencional:

- **iFrames no hacen invencible permanentemente**
- **Requiere skill para aprovecharlos bien**
- **Enemigos lentos siguen siendo peligrosos a largo plazo**

## Futuras Mejoras Posibles

### Alpha 0.7+

1. **iFrames escalables:** Reducir duración en niveles difíciles
2. **Knockback al recibir daño:** Empujar al jugador hacia atrás
3. **Sonido de hit:** SFX cuando recibes daño
4. **Partículas de hit:** Efecto visual en el punto de impacto
5. **iFrames variables:** Algunos ataques podrían dar más/menos iFrames

### Ideas Avanzadas

- **Dash con iFrames:** Presionar shift para dash invencible (cooldown)
- **Perfect dodge:** Esquivar en el último momento otorga iFrames extra
- **Escudo temporal:** Power-up que duplica duración de iFrames

---

**Sistema Status:** ✅ **IMPLEMENTED & TESTED**
**Versión:** Alpha 0.6.0
**Fecha:** 2026-01-31
