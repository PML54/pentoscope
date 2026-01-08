# tutorial/commands/highlight_commands.dart

**Module:** tutorial

## Fonctions

### HighlightCellCommand

HIGHLIGHT_CELL


```dart
const HighlightCellCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'HIGHLIGHT_CELL: les paramètres x et y sont obligatoires', );
```

### HighlightCellCommand

```dart
return HighlightCellCommand( x: xValue is int ? xValue : int.parse(xValue.toString()), y: yValue is int ? yValue : int.parse(yValue.toString()), color: _parseColor(colorStr), );
```

### HighlightCellsCommand

HIGHLIGHT_CELLS


```dart
const HighlightCellsCommand({required this.cells, required this.color});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### HighlightCellsCommand

```dart
return HighlightCellsCommand( cells: cells, color: HighlightCellCommand._parseColor(colorStr), );
```

### HighlightValidPositionsCommand

HIGHLIGHT_VALID_POSITIONS


```dart
const HighlightValidPositionsCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'HIGHLIGHT_VALID_POSITIONS: le paramètre pieceNumber est obligatoire', );
```

### HighlightValidPositionsCommand

```dart
return HighlightValidPositionsCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), color: HighlightCellCommand._parseColor(colorStr), );
```

### ClearHighlightsCommand

CLEAR_HIGHLIGHTS


```dart
const ClearHighlightsCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### HighlightMastercaseCommand

HIGHLIGHT_MASTERCASE


```dart
const HighlightMastercaseCommand({required this.x, required this.y});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'HIGHLIGHT_MASTERCASE: les paramètres x/gridX et y/gridY sont obligatoires', );
```

### HighlightMastercaseCommand

```dart
return HighlightMastercaseCommand( x: xValue is int ? xValue : int.parse(xValue.toString()), y: yValue is int ? yValue : int.parse(yValue.toString()), );
```

### ClearMastercaseHighlightCommand

CLEAR_MASTERCASE_HIGHLIGHT


```dart
const ClearMastercaseHighlightCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

