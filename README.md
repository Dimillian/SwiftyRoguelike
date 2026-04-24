# Swifty Roguelike

![Swifty Roguelike screenshot](swifty-roguelike-screenshot.png)

Swifty Roguelike is a native macOS dungeon crawler built with SwiftUI and SwiftPM. It renders a classic ASCII roguelike board inside a modern glassy macOS interface, with procedural rooms, turn-based movement, combat, loot, leveling, and descendable dungeon floors.

## Current Status

This is an early playable prototype. The app currently includes:

- A 64x38 procedural dungeon map with rooms, corridors, doors, stairs, water, and foliage.
- A centered ASCII viewport rendered with SwiftUI `Canvas`.
- Turn-based movement, bump-to-attack combat, monster movement, resting, waiting, and potion use.
- Loot pickup for gold, potions, and runic shards.
- Player stats, inventory, nearby loot, equipment, run metadata, and combat log side panels.
- A generated `.app` bundle workflow for local runs.

## Requirements

- macOS 26 or newer.
- Xcode 26.4 or newer, or an equivalent Swift 6.3 toolchain.

The package manifest currently declares `.macOS(.v26)`, and the generated app bundle sets `LSMinimumSystemVersion` to `26.0`.

## Build

```sh
swift build
```

## Run

Use the helper script to build a local app bundle under `dist/` and launch it:

```sh
./script/build_and_run.sh
```

Other script modes:

```sh
./script/build_and_run.sh --verify
./script/build_and_run.sh --logs
./script/build_and_run.sh --telemetry
./script/build_and_run.sh --debug
```

The `dist/` directory is generated output and is intentionally ignored by git.

## Controls

- `W`, `A`, `S`, `D` or arrow keys: move.
- Bump into a monster: attack.
- `.`: wait.
- `R`: rest.
- `P`: use a Crimson Potion.
- `Command-N`: start a new run.
- Use the Descend toolbar or command bar action when standing on stairs.

## Project Layout

```text
Sources/SwiftyRoguelike/
  App/          macOS app entry point and window setup
  Game/         game state, procedural generation, and seeded RNG
  Models/       player, monsters, loot, map tiles, grid points, and actions
  Rendering/    ASCII dungeon rendering primitives
  Support/      keyboard notifications and window configuration
  Views/        SwiftUI panels, HUD, command bar, and main layout
script/         local build/run helpers
```

## Tests

There is no test target yet. Good first coverage would be deterministic dungeon generation, movement bounds, loot pickup, combat, and level-up behavior.
