# tutorial/commands/placement_commands.dart

**Module:** tutorial

## Fonctions

### PlaceSelectedPieceAtCommand

PLACE_SELECTED_PIECE_AT


```dart
const PlaceSelectedPieceAtCommand({required this.gridX, required this.gridY});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### PlaceSelectedPieceAtCommand

```dart
return PlaceSelectedPieceAtCommand( gridX: params['gridX'] as int, gridY: params['gridY'] as int, );
```

### RemovePieceAtCommand

REMOVE_PIECE_AT


```dart
const RemovePieceAtCommand({required this.x, required this.y});
```

### execute

```dart
Future<void> execute(TutorialContext context) async {
```

### RemovePieceAtCommand

```dart
return RemovePieceAtCommand(x: params['x'] as int, y: params['y'] as int);
```

