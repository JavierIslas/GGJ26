# Sistema de Endings Múltiples - Configuración

## Overview

VEIL ahora tiene **3 endings diferentes** basados en el porcentaje de verdades reveladas a lo largo de todo el juego.

## Endings Disponibles

| Ending | Requisito | Color | Descripción |
|--------|-----------|-------|-------------|
| **Ignorancia** | < 50% | Rojo oscuro | El jugador evitó confrontar la mayoría de las verdades |
| **Despertar** | 50-80% | Azul brillante | El jugador reveló suficientes verdades, pero con costo |
| **El Revelador** | > 80% | Dorado | El jugador confrontó casi todas las verdades |

## Configuración

### Ajustar cantidad de niveles

En `scripts/autoloads/game_manager.gd`, línea ~18:

```gdscript
var max_levels: int = 4  # Cambiar según cuántos niveles totales tenga el juego
```

**IMPORTANTE:** Si actualmente solo tienes 2 niveles completos, cambia `max_levels = 2` para que el ending se muestre al completar Level 2.

### Ajustar rangos de porcentaje

En `scripts/ui/ending_screen.gd`, constante `ENDINGS` (líneas 18-47):

```gdscript
const ENDINGS = {
    "ignorance": {
        "threshold": 0.0,  # < 50%
        # ...
    },
    "awakening": {
        "threshold": 50.0,  # 50-80%
        # ...
    },
    "revelator": {
        "threshold": 80.0,  # > 80%
        # ...
    }
}
```

Puedes modificar los thresholds o el texto narrativo de cada ending.

## Testing

Para testear cada ending:

1. **Ending "Ignorancia"**: Revelar < 50% de las entidades en todos los niveles
2. **Ending "Despertar"**: Revelar 50-80% de las entidades
3. **Ending "Revelador"**: Revelar > 80% de las entidades

Puedes ver el porcentaje actual en la consola ejecutando:

```gdscript
print(GameManager.get_truth_percentage())
```

## Flujo del Sistema

```
Completar nivel → GameManager.complete_level()
    ↓
level_goal.gd verifica GameManager.is_final_level()
    ↓
SI es último nivel:
    → Buscar "ending_screen" group
    → ending_screen.show_ending()
    → Calcula % con GameManager.get_truth_percentage()
    → Muestra ending correspondiente

SI NO es último nivel:
    → Muestra victory_screen normal
    → Botón "Next Level" disponible
```

## Archivos Clave

- `scripts/ui/ending_screen.gd` - Lógica y textos de endings
- `scenes/ui/ending_screen.tscn` - UI de la pantalla de ending
- `scripts/autoloads/game_manager.gd` - Variables max_levels y get_truth_percentage()
- `scripts/level/level_goal.gd` - Detección de último nivel

## Expandir Endings

Para añadir un 4º ending (ej: "Perfect", 100%):

1. Añadir entrada en `ENDINGS` const en `ending_screen.gd`:
```gdscript
"perfect": {
    "name": "Perfecto",
    "color": Color(1.0, 1.0, 1.0),  # Blanco brillante
    "threshold": 100.0,
    "narrative": "Tu texto narrativo aquí..."
}
```

2. Actualizar `_get_ending_for_percentage()` para incluir la nueva condición:
```gdscript
if percentage >= 100.0:
    return ENDINGS["perfect"]
elif percentage >= ENDINGS["revelator"]["threshold"]:
    return ENDINGS["revelator"]
# ...
```

## Stats Mostrados en Ending

- Nombre del ending
- Texto narrativo (scroll si es largo)
- Verdades totales reveladas (X / Y)
- Porcentaje de completitud (con color del ending)
- Botones: "New Game" y "Main Menu"

## Notas

- El ending se muestra **una sola vez** al completar el último nivel
- Los stats son **acumulativos** de todos los niveles jugados
- El botón "New Game" resetea todo el progreso y vuelve a Level 1
- Cada nivel contribuye sus verdades al total global para calcular el %
