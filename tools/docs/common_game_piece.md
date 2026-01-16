# common/game_piece.dart

**Module:** common

## Fonctions

### GamePiece

```dart
const GamePiece({
```

### shapeToCoordinates

```dart
static List<Point> shapeToCoordinates(List<int> shape) {
```

### Point

```dart
return Point(col, row);
```

### shapeToCoordinates

```dart
return shapeToCoordinates(currentShape);
```

### Point

```dart
return Point(placedX! + p.x, placedY! + p.y);
```

### rotate

```dart
GamePiece rotate() {
```

### GamePiece

```dart
return GamePiece( pento: pento, currentOrientation: (currentOrientation + 1) % pento.numOrientations, isPlaced: isPlaced, placedX: placedX, placedY: placedY, );
```

### place

```dart
GamePiece place(int x, int y) {
```

### GamePiece

```dart
return GamePiece( pento: pento, currentOrientation: currentOrientation, isPlaced: true, placedX: x, placedY: y, );
```

### unplace

```dart
GamePiece unplace() {
```

### GamePiece

```dart
return GamePiece( pento: pento, currentOrientation: currentOrientation, isPlaced: false, placedX: null, placedY: null, );
```

