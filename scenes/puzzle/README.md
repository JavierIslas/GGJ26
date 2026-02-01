# Puzzle System - VEIL

## Prefabs Disponibles

### 1. PuzzleSwitch
**Archivo**: `puzzle_switch.tscn`

Interruptor activable por:
- Veil Shards (proyectiles)
- Interacción directa (E)
- Ambos

### 2. SyncRevealDoor
**Archivo**: `sync_reveal_door.tscn`

Puerta que requiere revelar múltiples enemigos simultáneamente.
- Timing generoso: 3.5s por defecto
- Configurable desde Inspector

### 3. TimedPuzzleController
**Archivo**: `timed_puzzle_controller.tscn`

Controlador para puzzles complejos con:
- Múltiples condiciones
- Timing generoso con coyote time
- Monitoreo de switches y enemigos

## Cómo Usar

1. Arrastra el prefab a tu escena
2. Configura en Inspector:
   - `enemy_group` / `switch_group` para grupos específicos
   - `time_window` para ventana de tiempo
   - `coyote_time` para buffer generoso
3. Conecta señales si es necesario (ej: `puzzle_completed`)

## Documentación Completa

Ver `PUZZLE_INTEGRATION_GUIDE.md` en la raíz del proyecto para:
- Diseños específicos de puzzles por nivel
- Valores de timing recomendados
- Instrucciones paso a paso de integración
- Testing checklist
