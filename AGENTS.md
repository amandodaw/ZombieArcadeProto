# AGENTS.md
Operational guide for coding agents in this repository.

## 1) Project Context
- Project name: `ZombieArcadeProto`
- Engine style: Godot 3.x APIs (`KinematicBody2D`, `scancode`, `move_and_slide`)
- Language: GDScript
- Main scene: `res://World/World.tscn`
- Root path: `/home/servan/Proyectos/Godot/ZombieArcadeProto`

## 2) Rule Priority
If instructions conflict, follow this order:
1. Explicit user request.
2. Runtime system/developer instructions.
3. This `AGENTS.md`.
4. Local conventions in touched files.

## 3) Cursor/Copilot Rules
Checked locations:
- `.cursorrules`: not present.
- `.cursor/rules/`: not present.
- `.github/copilot-instructions.md`: not present.
If these files are added later, treat them as mandatory and update this doc.

## 4) Commands: Build, Lint, Test
Use repo root as working directory.

### Engine binary
- Prefer `godot3`.
- If unavailable, use `godot` and keep the same arguments.

### Run and smoke checks
- Run project (main scene):
`godot3 --path .`
- Run explicit scene:
`godot3 --path . "res://World/World.tscn"`
- Headless startup check:
`godot3 --path . --headless --quit`

### Build/export
- No `export_presets.cfg` is currently committed.
- If presets are later added, use:
`godot3 --path . --export "<PresetName>" <output-path>`
- Do not invent preset names; read them from `export_presets.cfg`.

### Lint/format
- No mandatory linter/formatter is configured in this repository.
- Optional lint (if installed locally):
`gdlint **/*.gd`
- Optional format check (if installed locally):
`gdformat --check .`
- Optional format write:
`gdformat .`
- If formatter output clashes with file-local style, preserve file-local style.

### Tests
- No automated unit/integration test framework is configured.
- Manual scene-based tests exist in `Test/`.

#### Single test (closest equivalent)
Run one test scene directly:
`godot3 --path . "res://Test/Test.tscn"`

#### Other test scenes
- `godot3 --path . "res://Test/Test2.tscn"`
- `godot3 --path . "res://Test/YSort.tscn"`

#### If a real test framework is added
Update this file with exact commands for:
- Full suite
- Single file
- Single case
- Required environment variables

## 5) Code Style Guidelines
These rules follow current repository patterns and should be used for new code.

### File and folder structure
- Keep script and scene together when possible (`Foo.gd` + `Foo.tscn`).
- Preserve current top-level structure: `World/`, `Player/`, `NPC/`, `Objects/`, `Test/`.
- Use `res://` absolute paths for loaded resources.
- Avoid renaming/moving resources unless the task explicitly needs it.

### Imports/resource loading
- Existing code frequently uses `onready var x = load('res://...')`.
- Prefer `preload()` for always-required resources.
- Keep one named variable per loaded resource.
- Avoid duplicate ad-hoc loads in hot paths.

### Formatting
- Use tabs for indentation (matches current `.gd` files).
- Keep one statement per line.
- Keep a blank line between function definitions.
- Avoid trailing whitespace.
- Match the formatting style of the touched file.

### Types
- Add explicit types where practical (`int`, `bool`, `Vector2`, `Node`, `Timer`).
- Type `onready` node references when obvious and low-friction.
- Use `const` for fixed values.
- Use `enum` for state machines.
- Prefer explicit function signatures on reusable/public helpers.

### Naming
- Scene and script filenames: PascalCase.
- Variables/functions/signals: snake_case.
- Constants: UPPER_SNAKE_CASE.
- Preserve existing entity tagging pattern: `TYPE = "PLAYER"`, `"ZOMBIE"`, etc.
- Prefer descriptive names (`knockback_timer`, `gun_controller`, `aim_dir`).

### State and control flow
- Use guard clauses for invalid state and null checks.
- Keep movement/physics behavior in `_physics_process`.
- Use `match state` for state-driven behavior.
- Centralize state transitions via helper/setter where possible.
- Ensure transitions return to stable states (commonly `Idle`).

### Error handling and defensive code
- Validate assumptions before property access.
- Filter overlap/collision bodies early (`self`, tilemap, static body, etc.).
- Do safe early returns instead of partial mutation.
- Guard signal `connect`/`disconnect` when object lifetime can vary.
- Prefer explicit checks over silent failure.

### Signals and node access
- Prefer signals for decoupled interactions.
- Keep callbacks thin; delegate to dedicated methods.
- Prefer cached/typed node refs over repeated deep `$path` access.
- Keep signal names action-oriented and clear.

### Comments and logging
- Add comments only when intent is not obvious.
- Match the language style of the file you are editing.
- Remove temporary `print()` debugging before finishing.
- Keep logs intentional and actionable.

## 6) Project-Specific Notes
- Input actions are defined in `project.godot`; keep names stable unless task requires migration.
- Existing action examples: `arriba`, `abajo`, `accion`, `disparar`, `recargar`.
- Preserve scene signal/timer wiring when changing gameplay scripts.
- Do not manually edit generated `.import` artifacts.

## 7) Validation Checklist
Before finalizing gameplay-affecting changes:
1. Run the relevant scene directly.
2. Run one headless startup check.
3. Verify all changed `res://` paths resolve.
4. Verify key state loops still recover correctly (shoot/reload/knockback/idle).
5. Remove accidental debug output.

## 8) Maintenance Rule
When adding CI/lint/format/test tooling, update this file in the same PR with:
- Setup/install steps
- Full run commands
- Single-test commands
- Environment requirements and platform caveats

Keep this file accurate: future agents will treat it as operational source of truth.
