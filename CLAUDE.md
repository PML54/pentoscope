# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Pentapol is a Flutter mobile game for pentomino puzzles. It supports two main game modes:
- **Pentoscope** (Speed Mode): Place 3–6 random pieces on smaller boards
- **Classical**: Complete 12-piece set on a 6×10 board (9356 known solutions)

Code comments and commit messages are in French.

## Commands

```bash
flutter pub get                       # Install dependencies
flutter analyze                       # Lint (flutter_lints)
flutter test                          # Run tests
flutter run                           # Run on device/emulator
dart run build_runner build           # Regenerate Drift + Freezed code
flutter pub run flutter_launcher_icons:main  # Regenerate app icons
```

## Architecture

### State Management — Riverpod Notifiers

Two large NotifierProviders drive the game:
- `pentoscopeProvider` → `PentoscopeNotifier`/`PentoscopeState` (`lib/pentoscope/pentoscope_provider.dart`, ~76KB)
- `pentominoGameProvider` → `PentominoGameNotifier`/`PentominoGameState` (`lib/classical/pentomino_game_provider.dart`, ~65KB)
- `settingsProvider` → `SettingsNotifier`/`AppSettings` (`lib/providers/settings_provider.dart`)

### Shared Logic — `PentominoGameMixin`

`lib/common/pentomino_game_mixin.dart` is mixed into both game providers. It centralizes:
- Isometric transformations (rotation CW/180°, mirror H/V)
- Coordinate normalization and mastercase remapping
- Cell selection and overlap validation

### Solver — `PentoscopeSolver`

`lib/pentoscope/pentoscope_solver.dart` implements an optimized backtracking solver:
- **Smallest Free Cell First (SFCF)** heuristic
- Isolated region pruning for early termination
- Piece ordering by constraint (fewer orientations = tried first)
- Returns `SolverResult` with solution count + all solutions (2-second timeout)

### Solution Matching

`lib/services/solution_matcher.dart` encodes board states as **BigInt** (360 bits: 60 cells × 6 bits/cell). The 9356 classical solutions are preloaded at startup via `loadNormalizedSolutionsAsBigInt()` and matched in O(n) per partial board state.

### Persistence — Drift (SQLite)

`lib/database/settings_database.dart` defines the schema; `settings_database.g.dart` is generated. Tables: `Settings` (key/value JSON), `GameSessions`, `SolutionStats`. Always run `build_runner` after schema changes.

### Settings Model Hierarchy

```
AppSettings
├── UISettings      – color scheme, custom colors, grid lines, animations
├── GameSettings    – difficulty, hints, timer, haptics
└── DuelSettings    – player name, duration, win/loss stats
```

### Piece Definitions

All 12 pentomino pieces with their orientations are defined in `lib/common/pentominos.dart`.

## Key Files

| File | Role |
|------|------|
| `lib/main.dart` | App entry; wraps with Riverpod `ProviderScope` |
| `lib/pentoscope/pentoscope_provider.dart` | Pentoscope game state & all game actions |
| `lib/classical/pentomino_game_provider.dart` | Classical mode state |
| `lib/common/pentomino_game_mixin.dart` | Shared transformation & validation logic |
| `lib/pentoscope/pentoscope_solver.dart` | Backtracking solver |
| `lib/services/solution_matcher.dart` | BigInt-based solution matching |
| `lib/models/app_settings.dart` | Settings data models |
| `lib/database/settings_database.dart` | Drift schema |

## Additional Documentation

Large `.md` files in the project root contain deeper design notes:
- `CURSORDOC.md` — general architecture reference
- `DOCIA.md` — architecture doc
- `DUEL_ISOM_ARCH.md` — duel mode & isometry details
- `MOVEPIECE.md` — piece movement mechanics
