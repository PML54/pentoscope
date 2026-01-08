# common/shape_recognizer.dart

**Module:** common

## Fonctions

### ShapeMatch

Résultat de la reconnaissance d'une forme


```dart
const ShapeMatch({
```

### toString

```dart
String toString() => 'Pièce ${piece.id}, position $positionIndex, à placer en ($gridX, $gridY)';
```

### ShapeMatch

Reconnaît une forme à partir de 5 coordonnées cartésiennes

[coords] : Liste de 5 coordonnées [[x1,y1], [x2,y2], ...]

Retourne un [ShapeMatch] si la forme correspond à une position de pentomino,
null sinon


```dart
return ShapeMatch( piece: pento, positionIndex: posIdx, gridX: minX, gridY: minY, );
```

