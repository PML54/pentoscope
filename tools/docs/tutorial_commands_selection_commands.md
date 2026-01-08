# tutorial/commands/selection_commands.dart

**Module:** tutorial

## Fonctions

### SelectPieceFromSliderCommand

SELECT_PIECE_FROM_SLIDER


```dart
const SelectPieceFromSliderCommand({required this.pieceNumber});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'SELECT_PIECE_FROM_SLIDER: le paramètre "pieceNumber" est obligatoire', );
```

### SelectPieceFromSliderCommand

```dart
return SelectPieceFromSliderCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), );
```

### HighlightPieceInSliderCommand

HIGHLIGHT_PIECE_IN_SLIDER


```dart
const HighlightPieceInSliderCommand({required this.pieceNumber});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'HIGHLIGHT_PIECE_IN_SLIDER: le paramètre "pieceNumber" est obligatoire', );
```

### HighlightPieceInSliderCommand

```dart
return HighlightPieceInSliderCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), );
```

### ClearSliderHighlightCommand

CLEAR_SLIDER_HIGHLIGHT


```dart
const ClearSliderHighlightCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### ScrollSliderCommand

SCROLL_SLIDER


```dart
const ScrollSliderCommand({required this.positions});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'SCROLL_SLIDER: le paramètre "positions" est obligatoire', );
```

### ScrollSliderCommand

```dart
return ScrollSliderCommand( positions: pos is int ? pos : int.parse(pos.toString()), );
```

### ScrollSliderToPieceCommand

SCROLL_SLIDER_TO_PIECE


```dart
const ScrollSliderToPieceCommand({required this.pieceNumber});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### FormatException

```dart
throw FormatException( 'SCROLL_SLIDER_TO_PIECE: le paramètre "pieceNumber" est obligatoire', );
```

### ScrollSliderToPieceCommand

```dart
return ScrollSliderToPieceCommand( pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()), );
```

### ResetSliderPositionCommand

RESET_SLIDER_POSITION


```dart
const ResetSliderPositionCommand();
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

