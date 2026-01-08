# pentapol - Documentation

*Pentapol - Analyse du code Flutter/Dart*

## Modules

- **classical** (3 fichiers)
- **common** (8 fichiers)
- **config** (1 fichiers)
- **data** (1 fichiers)
- **database** (2 fichiers)
- **debug** (1 fichiers)
- **duel** (15 fichiers)
- **main.dart** (1 fichiers)
- **models** (1 fichiers)
- **pentoscope** (7 fichiers)
- **providers** (1 fichiers)
- **screens** (12 fichiers)
- **services** (4 fichiers)
- **tutorial** (20 fichiers)
- **utils** (6 fichiers)

---

## Module: classical

### classical/pentomino_game_provider.dart

**Fonctions :**

- `applyIsometryRotationCW()`
- `applyIsometryRotationTW()`
- `applyIsometrySymmetryH()`
- `applyIsometrySymmetryV()`
- `build()`
- `calculateScore()`
- `cancelSelection()`
- `cancelTutorial()`
- `onPuzzleCompleted()`
- `clearBoardHighlight()`
- `clearCellHighlights()`
- `clearIsometryIconHighlight()`
- `incrementSolutionsViewCount()`
- `clearMastercaseHighlight()`
- `clearPreview()`
- `clearSliderHighlight()`
- `cycleToNextOrientation()`
- `enterIsometriesMode()`
- `enterTutorialMode()`
- `StateError()`
- `StateError()`
- `exitIsometriesMode()`
- `exitTutorialMode()`
- `StateError()`
- `StateError()`
- `getElapsedSeconds()`
- `highlightCell()`
- `ArgumentError()`
- `highlightCells()`
- `highlightIsometryIcon()`
- `highlightMastercase()`
- `highlightPieceInSlider()`
- `ArgumentError()`
- `highlightPieceOnBoard()`
- `ArgumentError()`
- `StateError()`
- `highlightValidPositions()`
- `placeSelectedPieceForTutorial()`
- `removePlacedPiece()`
- `reset()`
- `resetSliderPosition()`
- `restoreState()`
- `scrollSlider()`
- `scrollSliderToPiece()`
- `ArgumentError()`
- `selectPiece()`
- `selectPieceFromSliderForTutorial()`
- `ArgumentError()`
- `selectPlacedPiece()`
- `selectPlacedPieceAtForTutorial()`
- `StateError()`
- `selectPlacedPieceWithMastercaseForTutorial()`
- `StateError()`
- `ArgumentError()`
- `setViewOrientation()`
- `startTimer()`
- `stopTimer()`
- `tryPlacePiece()`
- `undoLastPlacement()`
- `updatePreview()`
- `Point()`
- `Point()`

### classical/pentomino_game_screen.dart

**Fonctions :**

- `PentominoGameScreen()`
- `createState()`
- `build()`
- `SizedBox()`
- `SizedBox()`
- `Divider()`
- `SizedBox()`
- `SizedBox()`
- `Scaffold()`
- `TutorialOverlay()`
- `TutorialControls()`
- `dispose()`
- `initState()`
- `didChangeDependencies()`
- `Row()`
- `Column()`
- `AnimatedContainer()`

### classical/pentomino_game_state.dart

**Fonctions :**

- `PentominoGameState()`
- `canPlacePiece()`
- `copyWith()`
- `PentominoGameState()`
- `getPiecePositionIndex()`
- `Point()`
- `copyWith()`
- `PlacedPiece()`
- `getOccupiedCells()`

---

## Module: common

### common/bigint_plateau.dart

**Fonctions :**

- `placePiece()`
- `ArgumentError()`
- `ArgumentError()`
- `clearCells()`
- `ArgumentError()`
- `getCell()`
- `ArgumentError()`

### common/game_piece.dart

**Fonctions :**

- `GamePiece()`
- `shapeToCoordinates()`
- `Point()`
- `shapeToCoordinates()`
- `Point()`
- `rotate()`
- `GamePiece()`
- `place()`
- `GamePiece()`
- `unplace()`
- `GamePiece()`

### common/isometry_transformation_service.dart

**Fonctions :**

- `applyRotationTW()`
- `applyRotationCW()`
- `applySymmetryH()`
- `applySymmetryV()`
- `canPlacePiece()`
- `UnimplementedError()`

### common/pentominos.dart

**Fonctions :**

- `Pento()`
- `findRotation90()`
- `findSymmetryH()`
- `findSymmetryV()`
- `getLetter()`
- `getLetterForPosition()`
- `rotate180()`
- `rotationCW()`
- `rotationTW()`
- `symmetryH()`
- `symmetryV()`
- `minIsometriesToReach()`

### common/placed_piece.dart

**Fonctions :**

- `PlacedPiece()`
- `Point()`
- `copyWith()`
- `PlacedPiece()`
- `toString()`

### common/plateau.dart

**Fonctions :**

- `Plateau()`
- `Plateau()`
- `Plateau()`
- `isInBounds()`
- `getCell()`
- `setCell()`
- `copy()`
- `Plateau()`

### common/point.dart

**Fonctions :**

- `Point()`
- `toString()`

### common/shape_recognizer.dart

**Fonctions :**

- `ShapeMatch()`
- `toString()`
- `ShapeMatch()`

---

## Module: config

### config/game_icons_config.dart

**Fonctions :**

- `GameIconConfig()`
- `isVisibleIn()`
- `getIconsForMode()`

---

## Module: data

### data/solution_database.dart

**Fonctions :**

- `init()`
- `StateError()`
- `decodeSolution()`
- `hasSolution()`
- `findMatchingSolutions()`
- `getStats()`
- `reset()`

---

## Module: database

### database/settings_database.dart

**Fonctions :**

- `LazyDatabase()`
- `NativeDatabase()`
- `getSetting()`
- `setSetting()`
- `into()`
- `deleteSetting()`
- `clearAllSettings()`
- `delete()`
- `saveGameSession()`
- `into()`
- `getFastestCompletion()`
- `getHighestScore()`
- `getTotalSessionsCount()`
- `getUniqueSolutionsCount()`
- `getSolutionStats()`
- `update()`
- `into()`

### database/settings_database.g.dart

**Fonctions :**

- `validateIntegrity()`
- `map()`
- `Setting()`
- `Setting()`
- `toColumns()`
- `toCompanion()`
- `SettingsCompanion()`
- `Setting()`
- `toJson()`
- `copyWith()`
- `copyWithCompanion()`
- `Setting()`
- `toString()`
- `SettingsCompanion()`
- `custom()`
- `RawValuesInsertable()`
- `copyWith()`
- `SettingsCompanion()`
- `toColumns()`
- `toString()`
- `VerificationMeta()`
- `validateIntegrity()`
- `map()`
- `GameSession()`
- `GameSession()`
- `toColumns()`
- `toCompanion()`
- `GameSessionsCompanion()`
- `GameSession()`
- `toJson()`
- `copyWith()`
- `copyWithCompanion()`
- `GameSession()`
- `toString()`
- `GameSessionsCompanion()`
- `custom()`
- `RawValuesInsertable()`
- `copyWith()`
- `GameSessionsCompanion()`
- `toColumns()`
- `toString()`
- `validateIntegrity()`
- `map()`
- `SolutionStat()`
- `SolutionStat()`
- `toColumns()`
- `toCompanion()`
- `SolutionStatsCompanion()`
- `SolutionStat()`
- `toJson()`
- `copyWith()`
- `copyWithCompanion()`
- `SolutionStat()`
- `toString()`
- `SolutionStatsCompanion()`
- `custom()`
- `RawValuesInsertable()`
- `copyWith()`
- `SolutionStatsCompanion()`
- `toColumns()`
- `toString()`
- `DriftDatabaseOptions()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`
- `Function()`

---

## Module: debug

### debug/database_debug_screen.dart

**Fonctions :**

- `DatabaseDebugScreen()`
- `createState()`
- `build()`
- `Scaffold()`
- `Text()`
- `Column()`
- `Text()`
- `Column()`
- `Container()`
- `Column()`
- `SizedBox()`
- `Row()`
- `Row()`
- `SnackBar()`
- `SnackBar()`

---

## Module: duel

### duel/models/duel_messages.dart

**Fonctions :**

- `toJson()`
- `encode()`
- `toJson()`
- `toJson()`
- `toJson()`
- `toJson()`
- `toJson()`
- `toJson()`
- `PongMessage()`
- `RoomCreatedMessage()`
- `RoomJoinedMessage()`
- `PlayerJoinedMessage()`
- `PlayerLeftMessage()`
- `GameStartMessage()`
- `CountdownMessage()`
- `PiecePlacedMessage()`
- `PlacementRejectedMessage()`
- `GameStateMessage()`
- `GameEndMessage()`
- `isDraw()`
- `ErrorMessage()`

### duel/models/duel_state.dart

**Fonctions :**

- `DuelState()`
- `copyWith()`
- `DuelState()`
- `DuelPlayer()`
- `copyWith()`
- `DuelPlayer()`
- `toJson()`
- `DuelPlayer()`
- `DuelPlacedPiece()`
- `toJson()`
- `DuelPlacedPiece()`
- `isOwnedBy()`

### duel/providers/duel_provider.dart

**Fonctions :**

- `DuelNotifier()`
- `build()`
- `createRoom()`
- `joinRoom()`
- `leaveRoom()`
- `placePiece()`
- `setReady()`

### duel/screens/duel_create_screen.dart

**Fonctions :**

- `DuelCreateScreen()`
- `createState()`
- `initState()`
- `dispose()`
- `build()`
- `Scaffold()`
- `Icon()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`

### duel/screens/duel_game_screen.dart

**Fonctions :**

- `DuelGameScreen()`
- `createState()`
- `initState()`
- `dispose()`
- `build()`
- `WillPopScope()`
- `IconButton()`
- `Container()`
- `Column()`
- `SizedBox()`
- `LayoutBuilder()`
- `Center()`
- `GestureDetector()`
- `Padding()`
- `SizedBox()`
- `Positioned()`
- `paint()`
- `shouldRepaint()`

### duel/screens/duel_home_screen.dart

**Fonctions :**

- `DuelHomeScreen()`
- `build()`
- `Scaffold()`
- `Icon()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `Spacer()`
- `Text()`
- `SizedBox()`

### duel/screens/duel_join_screen.dart

**Fonctions :**

- `DuelJoinScreen()`
- `createState()`
- `initState()`
- `dispose()`
- `build()`
- `Scaffold()`
- `Icon()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `formatEditUpdate()`
- `TextEditingValue()`

### duel/screens/duel_result_screen.dart

**Fonctions :**

- `DuelResultScreen()`
- `build()`
- `Scaffold()`
- `Spacer()`
- `SizedBox()`
- `SizedBox()`
- `Padding()`
- `SizedBox()`
- `Spacer()`
- `SizedBox()`
- `SizedBox()`
- `build()`
- `Row()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `Icon()`

### duel/screens/duel_settings_screen.dart

**Fonctions :**

- `DuelSettingsScreen()`
- `createState()`
- `initState()`
- `dispose()`
- `build()`
- `Scaffold()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `Padding()`
- `SizedBox()`
- `TextField()`
- `Wrap()`
- `ChoiceChip()`
- `SizedBox()`
- `Padding()`
- `SizedBox()`
- `SwitchListTile()`
- `Column()`
- `Card()`
- `Divider()`
- `Icon()`
- `SizedBox()`
- `SizedBox()`
- `Column()`
- `SizedBox()`
- `SnackBar()`
- `SnackBar()`
- `DuelSettingsTile()`
- `build()`
- `ListTile()`

### duel/screens/duel_waiting_screen.dart

**Fonctions :**

- `DuelWaitingScreen()`
- `build()`
- `Scaffold()`
- `SizedBox()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `Icon()`
- `SizedBox()`
- `SizedBox()`
- `Text()`
- `Spacer()`

### duel/services/duel_validator.dart

**Fonctions :**

- `initialize()`
- `loadSolution()`
- `validatePlacement()`
- `reset()`

### duel/services/websocket_service.dart

**Fonctions :**

- `connect()`
- `disconnect()`
- `send()`
- `sendRaw()`
- `connect()`
- `dispose()`

### duel/widgets/duel_countdown.dart

**Fonctions :**

- `DuelCountdown()`
- `build()`
- `Container()`

### duel/widgets/duel_piece_slider.dart

**Fonctions :**

- `DuelPieceSlider()`
- `build()`
- `Container()`

### duel/widgets/opponent_piece_overlay.dart

**Fonctions :**

- `OpponentPieceOverlay()`
- `build()`
- `Stack()`
- `paint()`
- `shouldRepaint()`

---

## Module: main.dart

### main.dart

**Fonctions :**

- `main()`
- `MyApp()`
- `build()`
- `MaterialApp()`

---

## Module: models

### models/app_settings.dart

**Fonctions :**

- `UISettings()`
- `copyWith()`
- `UISettings()`
- `getPieceColor()`
- `toJson()`
- `UISettings()`
- `GameSettings()`
- `copyWith()`
- `GameSettings()`
- `toJson()`
- `GameSettings()`
- `DuelSettings()`
- `copyWith()`
- `DuelSettings()`
- `recordGame()`
- `copyWith()`
- `resetStats()`
- `copyWith()`
- `toJson()`
- `DuelSettings()`
- `AppSettings()`
- `copyWith()`
- `AppSettings()`
- `toJson()`
- `AppSettings()`

---

## Module: pentoscope

### pentoscope/pentoscope_generator.dart

**Fonctions :**

- `generate()`
- `PentoscopePuzzle()`
- `generateEasy()`
- `PentoscopePuzzle()`
- `generateHard()`
- `PentoscopePuzzle()`
- `PentoscopePuzzle()`
- `toString()`
- `PentoscopeSize()`
- `PentoscopeStats()`
- `toString()`

### pentoscope/pentoscope_provider.dart

**Fonctions :**

- `applyIsometryRotationCW()`
- `applyIsometryRotationTW()`
- `applyIsometrySymmetryH()`
- `applyIsometrySymmetryV()`
- `build()`
- `cancelSelection()`
- `clearPreview()`
- `cycleToNextOrientation()`
- `removePlacedPiece()`
- `reset()`
- `selectPiece()`
- `selectPlacedPiece()`
- `setViewOrientation()`
- `startPuzzle()`
- `tryPlacePiece()`
- `updatePreview()`
- `Point()`
- `coordsInPositionOrder()`
- `Point()`
- `PentoscopePlacedPiece()`
- `Point()`
- `copyWith()`
- `PentoscopePlacedPiece()`
- `PentoscopeState()`
- `PentoscopeState()`
- `canPlacePiece()`
- `copyWith()`
- `PentoscopeState()`
- `getPiecePositionIndex()`

### pentoscope/pentoscope_solver.dart

**Fonctions :**

- `SolverPlacement()`
- `toString()`
- `findFirstSolution()`
- `findAllSolutions()`
- `backtrackAll()`
- `SolverResult()`
- `SolverResult()`
- `toString()`

### pentoscope/screens/pentoscope_game_screen.dart

**Fonctions :**

- `PentoscopeGameScreen()`
- `build()`
- `Scaffold()`
- `IconButton()`
- `Text()`
- `AnimatedContainer()`
- `Column()`
- `Expanded()`
- `Row()`
- `Expanded()`

### pentoscope/screens/pentoscope_menu_screen.dart

**Fonctions :**

- `PentoscopeMenuScreen()`
- `createState()`
- `build()`
- `Scaffold()`
- `Text()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `Row()`
- `Expanded()`
- `SizedBox()`
- `Row()`
- `SizedBox()`
- `Expanded()`
- `SizedBox()`

### pentoscope/widgets/pentoscope_board.dart

**Fonctions :**

- `PentoscopeBoard()`
- `build()`
- `LayoutBuilder()`
- `Center()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`

### pentoscope/widgets/pentoscope_piece_slider.dart

**Fonctions :**

- `PentoscopePieceSlider()`
- `build()`
- `Padding()`

---

## Module: providers

### providers/settings_provider.dart

**Fonctions :**

- `SettingsDatabase()`
- `SettingsNotifier()`
- `build()`
- `recordDuelGame()`
- `resetDuelSettings()`
- `resetDuelStats()`
- `resetToDefaults()`
- `setColorScheme()`
- `setCustomColors()`
- `setDifficulty()`
- `setDuelCustomDuration()`
- `setDuelDuration()`
- `setDuelGuideOpacity()`
- `setDuelHatchOpacity()`
- `setDuelPlayerName()`
- `setDuelShowGuide()`
- `setDuelShowHatch()`
- `setDuelShowOpponentProgress()`
- `setDuelShowPieceNumbers()`
- `setDuelSounds()`
- `setDuelVibration()`
- `setEnableAnimations()`
- `setEnableHaptics()`
- `setEnableHints()`
- `setEnableTimer()`
- `setIconSize()`
- `setIsometriesAppBarColor()`
- `setLongPressDuration()`
- `setPieceOpacity()`
- `setShowGridLines()`
- `setShowPieceNumbers()`
- `setShowSolutionCounter()`

---

## Module: screens

### screens/custom_colors_screen.dart

**Fonctions :**

- `CustomColorsScreen()`
- `createState()`
- `initState()`
- `build()`
- `Scaffold()`
- `Card()`
- `SizedBox()`
- `GestureDetector()`

### screens/home_screen.dart

**Fonctions :**

- `HomeScreen()`
- `build()`
- `Scaffold()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `build()`
- `Material()`
- `build()`
- `Material()`
- `SizedBox()`
- `SizedBox()`
- `Icon()`

### screens/pentomino_game/utils/game_colors.dart

**Fonctions :**

- `getPieceColorFallback()`

### screens/pentomino_game/widgets/game_mode/piece_slider.dart

**Fonctions :**

- `PieceSlider()`
- `createState()`
- `dispose()`
- `build()`
- `Padding()`

### screens/pentomino_game/widgets/shared/action_slider.dart

**Fonctions :**

- `getCompatibleSolutionsIncludingSelected()`
- `ActionSlider()`
- `build()`
- `Column()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `Column()`
- `SizedBox()`
- `SizedBox()`

### screens/pentomino_game/widgets/shared/draggable_piece_widget.dart

**Fonctions :**

- `DraggablePieceWidget()`
- `createState()`
- `dispose()`
- `build()`

### screens/pentomino_game/widgets/shared/game_board.dart

**Fonctions :**

- `GameBoard()`
- `build()`
- `LayoutBuilder()`
- `Center()`

### screens/pentomino_game/widgets/shared/piece_border_calculator.dart

**Fonctions :**

- `calculate()`
- `neighborId()`
- `Border()`
- `Border()`

### screens/pentomino_game/widgets/shared/piece_renderer.dart

**Fonctions :**

- `PieceRenderer()`
- `build()`
- `Container()`

### screens/settings_screen.dart

**Fonctions :**

- `SettingsScreen()`
- `build()`
- `Scaffold()`
- `Divider()`
- `Divider()`
- `Divider()`
- `SizedBox()`
- `ListTile()`
- `Icon()`
- `SizedBox()`
- `Text()`
- `Spacer()`
- `SizedBox()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `ChoiceChip()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `Column()`
- `SizedBox()`
- `ListTile()`
- `SizedBox()`
- `Text()`
- `Divider()`
- `SizedBox()`
- `Padding()`
- `Padding()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `Color()`
- `GestureDetector()`

### screens/solutions_browser_screen.dart

**Fonctions :**

- `SolutionsBrowserScreen()`
- `createState()`
- `initState()`
- `build()`
- `Scaffold()`
- `Scaffold()`
- `SizedBox()`
- `SizedBox()`
- `Container()`
- `Container()`
- `SizedBox()`
- `SizedBox()`
- `Divider()`
- `SizedBox()`
- `SizedBox()`
- `neighborId()`
- `Border()`
- `Border()`

### screens/solutions_viewer_screen.dart

**Fonctions :**

- `SolutionsViewerScreen()`
- `createState()`
- `build()`
- `Scaffold()`
- `Scaffold()`
- `Container()`
- `SizedBox()`
- `Text()`
- `Text()`
- `Text()`
- `Text()`

---

## Module: services

### services/pentapol_solutions_loader.dart

**Fonctions :**

- `StateError()`

### services/pentomino_solver.dart

**Fonctions :**

- `hasSolution()`
- `findSolution()`
- `ArgumentError()`
- `areIsolatedRegionsValid()`
- `backtrack()`
- `backtrackFromPosition()`
- `backtrack()`
- `canAnyAvailablePieceFitRegion()`
- `canPlaceWithOffset()`
- `countAllSolutions()`
- `countRecursive()`
- `countRecursive()`
- `countRecursive()`
- `Function()`
- `searchRecursive()`
- `searchRecursive()`
- `searchRecursive()`
- `findSmallestFreeCell()`
- `floodFillAndCollect()`
- `placeWithOffset()`
- `removeWithOffset()`
- `stopCounting()`
- `tryNextPlacements()`
- `toString()`

### services/plateau_solution_counter.dart

**Fonctions :**

- `StateError()`
- `StateError()`
- `getCompatibleSolutionsBigInt()`
- `getCompatibleSolutionIndices()`
- `findExactSolutionIndex()`

### services/solution_matcher.dart

**Fonctions :**

- `SolutionInfo()`
- `toString()`
- `initWithBigIntSolutions()`
- `StateError()`
- `ArgumentError()`
- `countCompatibleFromBigInts()`
- `getCompatibleSolutionsFromBigInts()`
- `getCompatibleSolutionIndices()`
- `findSolutionIndex()`

---

## Module: tutorial

### tutorial/commands/board_selection_commands.dart

**Fonctions :**

- `SelectPieceOnBoardAtCommand()`
- `execute()`
- `SelectPieceOnBoardAtCommand()`
- `SelectPieceOnBoardWithMastercaseCommand()`
- `execute()`
- `SelectPieceOnBoardWithMastercaseCommand()`
- `HighlightPieceOnBoardCommand()`
- `execute()`
- `HighlightPieceOnBoardCommand()`
- `CancelSelectionCommand()`
- `execute()`

### tutorial/commands/control_commands.dart

**Fonctions :**

- `WaitCommand()`
- `execute()`
- `WaitCommand()`
- `RepeatCommand()`
- `execute()`
- `RepeatCommand()`

### tutorial/commands/highlight_commands.dart

**Fonctions :**

- `HighlightCellCommand()`
- `execute()`
- `FormatException()`
- `HighlightCellCommand()`
- `HighlightCellsCommand()`
- `execute()`
- `HighlightCellsCommand()`
- `HighlightValidPositionsCommand()`
- `execute()`
- `FormatException()`
- `HighlightValidPositionsCommand()`
- `ClearHighlightsCommand()`
- `execute()`
- `HighlightMastercaseCommand()`
- `execute()`
- `FormatException()`
- `HighlightMastercaseCommand()`
- `ClearMastercaseHighlightCommand()`
- `execute()`

### tutorial/commands/highlight_isometry_icon.dart

**Fonctions :**

- `HighlightIsometryIconCommand()`
- `FormatException()`
- `FormatException()`
- `HighlightIsometryIconCommand()`
- `validate()`
- `execute()`
- `ClearIsometryIconHighlightCommand()`
- `execute()`

### tutorial/commands/message_commands.dart

**Fonctions :**

- `ShowMessageCommand()`
- `execute()`
- `ShowMessageCommand()`
- `ClearMessageCommand()`
- `execute()`

### tutorial/commands/placement_commands.dart

**Fonctions :**

- `PlaceSelectedPieceAtCommand()`
- `execute()`
- `PlaceSelectedPieceAtCommand()`
- `RemovePieceAtCommand()`
- `execute()`
- `RemovePieceAtCommand()`

### tutorial/commands/selection_commands.dart

**Fonctions :**

- `SelectPieceFromSliderCommand()`
- `execute()`
- `FormatException()`
- `SelectPieceFromSliderCommand()`
- `HighlightPieceInSliderCommand()`
- `execute()`
- `FormatException()`
- `HighlightPieceInSliderCommand()`
- `ClearSliderHighlightCommand()`
- `execute()`
- `ScrollSliderCommand()`
- `execute()`
- `FormatException()`
- `ScrollSliderCommand()`
- `ScrollSliderToPieceCommand()`
- `execute()`
- `FormatException()`
- `ScrollSliderToPieceCommand()`
- `ResetSliderPositionCommand()`
- `execute()`

### tutorial/commands/transform_commands.dart

**Fonctions :**

- `RotateAroundMasterCommand()`
- `execute()`
- `FormatException()`
- `FormatException()`
- `RotateAroundMasterCommand()`
- `SymmetryAroundMasterCommand()`
- `execute()`
- `FormatException()`
- `FormatException()`
- `FormatException()`
- `SymmetryAroundMasterCommand()`

### tutorial/commands/translate_command.dart

**Fonctions :**

- `TranslateCommand()`
- `execute()`
- `FormatException()`
- `FormatException()`
- `TranslateCommand()`

### tutorial/commands/tutorial_mode_commands.dart

**Fonctions :**

- `EnterTutorialModeCommand()`
- `execute()`
- `ExitTutorialModeCommand()`
- `execute()`
- `ExitTutorialModeCommand()`
- `CancelTutorialCommand()`
- `execute()`
- `ResetGameCommand()`
- `execute()`

### tutorial/interpreter/scratch_interpreter.dart

**Fonctions :**

- `run()`
- `StateError()`
- `pause()`
- `resume()`
- `stop()`
- `stepNext()`
- `stepBack()`
- `reset()`

### tutorial/models/scratch_command.dart

**Fonctions :**

- `ScratchCommand()`
- `execute()`
- `validate()`
- `CompositeCommand()`
- `execute()`
- `ConditionalCommand()`
- `execute()`

### tutorial/models/tutorial_context.dart

**Fonctions :**

- `setMessage()`
- `clearMessage()`
- `setVariable()`
- `getVariable()`
- `incrementVariable()`
- `pause()`
- `resume()`
- `cancel()`
- `waitIfPaused()`

### tutorial/models/tutorial_script.dart

**Fonctions :**

- `TutorialScript()`
- `TutorialScript()`
- `copyWith()`
- `TutorialScript()`

### tutorial/models/tutorial_state.dart

**Fonctions :**

- `TutorialState()`
- `copyWith()`
- `TutorialState()`

### tutorial/parser/yaml_parser.dart

**Fonctions :**

- `parse()`
- `FormatException()`
- `validate()`
- `ClearMessageCommand()`
- `EnterTutorialModeCommand()`
- `CancelTutorialCommand()`
- `ResetGameCommand()`
- `ClearSliderHighlightCommand()`
- `ResetSliderPositionCommand()`
- `CancelSelectionCommand()`
- `ClearHighlightsCommand()`
- `FormatException()`

### tutorial/providers/tutorial_provider.dart

**Fonctions :**

- `TutorialNotifier()`
- `build()`
- `loadScript()`
- `StateError()`
- `unloadScript()`
- `start()`
- `StateError()`
- `StateError()`
- `pause()`
- `resume()`
- `stop()`
- `quit()`
- `restart()`
- `start()`
- `stepNext()`
- `stepBack()`
- `updateMessage()`

### tutorial/widgets/highlighted_icon_button.dart

**Fonctions :**

- `HighlightedIconButton()`
- `createState()`
- `initState()`
- `dispose()`
- `build()`
- `AnimatedBuilder()`
- `Container()`

### tutorial/widgets/tutorial_controls.dart

**Fonctions :**

- `TutorialControls()`
- `build()`
- `Positioned()`
- `build()`
- `Row()`
- `SizedBox()`
- `build()`
- `Column()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`
- `build()`
- `Row()`
- `SizedBox()`
- `SizedBox()`
- `SizedBox()`

### tutorial/widgets/tutorial_overlay.dart

**Fonctions :**

- `TutorialOverlay()`
- `build()`
- `Stack()`
- `build()`
- `Material()`
- `Icon()`
- `SizedBox()`
- `Text()`
- `SizedBox()`
- `build()`
- `Material()`
- `Icon()`
- `SizedBox()`
- `build()`
- `Material()`
- `SizedBox()`

---

## Module: utils

### utils/pentomino_geometry.dart

**Fonctions :**

- `Point2D()`
- `toString()`
- `cellNumberToCoords()`
- `Point2D()`
- `calculateBarycenter()`
- `Point2D()`
- `getPieceRotationCenter()`
- `calculateBarycenter()`
- `PentominoGeometry()`
- `describeTransformation()`
- `toOffset()`

### utils/piece_utils.dart

**Fonctions :**

- `getPieceName()`
- `getDefaultPieceColor()`
- `PiecePreview()`
- `build()`
- `SizedBox()`
- `Positioned()`
- `PieceIcon()`
- `build()`
- `Container()`
- `getColorHex()`
- `getPredefinedColors()`

### utils/plateau_compressor.dart

**Fonctions :**

- `encode()`
- `decode()`
- `rotate90()`
- `encode()`
- `rotate180()`
- `rotate90()`
- `rotate270()`
- `rotate90()`
- `mirrorH()`
- `encode()`
- `compare()`
- `findCanonical()`
- `toDebugString()`
- `areEquivalent()`
- `compare()`

### utils/solution_collector.dart

**Fonctions :**

- `onSolutionFound()`
- `finalize()`
- `collectAllSolutions()`

### utils/solution_exporter.dart

**Fonctions :**

- `empty()`
- `PentominoSolution()`
- `toString()`
- `addSolution()`
- `saveToFile()`
- `saveCompact()`
- `saveDartCode()`
- `placementsToGrid()`
- `PentominoSolution()`
- `main()`

### utils/time_format.dart

**Fonctions :**

- `formatMillis()`

