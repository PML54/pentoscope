# tutorial/commands/board_selection_commands.dart

**Module:** tutorial

## Fonctions

### SelectPieceOnBoardAtCommand

SELECT_PIECE_ON_BOARD_AT


```dart
const SelectPieceOnBoardAtCommand({required this.x, required this.y});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### SelectPieceOnBoardAtCommand

```dart
return SelectPieceOnBoardAtCommand( x: params['x'] as int, y: params['y'] as int, );
```

### SelectPieceOnBoardWithMastercaseCommand

SELECT_PIECE_ON_BOARD_WITH_MASTERCASE


```dart
const SelectPieceOnBoardWithMastercaseCommand({
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### SelectPieceOnBoardWithMastercaseCommand

```dart
return SelectPieceOnBoardWithMastercaseCommand( pieceNumber: params['pieceNumber'] as int, mastercaseX: params['mastercaseX'] as int, mastercaseY: params['mastercaseY'] as int, );
```

### HighlightPieceOnBoardCommand

HIGHLIGHT_PIECE_ON_BOARD


```dart
const HighlightPieceOnBoardCommand({required this.pieceNumber});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### HighlightPieceOnBoardCommand

```dart
return HighlightPieceOnBoardCommand( pieceNumber: params['pieceNumber'] as int, );
```

### CancelSelectionCommand

CANCEL_SELECTION


```dart
const CancelSelectionCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

