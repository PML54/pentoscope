# utils/pentomino_geometry.dart

**Module:** utils

## Fonctions

### Point2D

Représente un point avec coordonnées flottantes


```dart
const Point2D(this.x, this.y);
```

### toString

```dart
String toString() => '($x, $y)';
```

### cellNumberToCoords

Convertit un numéro de case (1-25) en coordonnées (x, y) sur grille 5×5
Numérotation: ligne 1 (bas) = cases 1-5, ligne 2 = cases 6-10, etc.


```dart
Point2D cellNumberToCoords(int cellNumber) {
```

### Point2D

```dart
return Point2D(x.toDouble(), y.toDouble());
```

### calculateBarycenter

Calcule le barycentre (centre géométrique) d'une forme de pentomino
donnée par une liste de numéros de cases


```dart
Point2D calculateBarycenter(List<int> shape) {
```

### Point2D

```dart
return Point2D(sumX / shape.length, sumY / shape.length);
```

### getPieceRotationCenter

Calcule le centre de rotation pour toutes les positions d'un pentomino
Retourne le barycentre de la forme de base


```dart
Point2D getPieceRotationCenter(Pento piece) {
```

### calculateBarycenter

```dart
return calculateBarycenter(piece.baseShape);
```

### PentominoGeometry

Analyse géométrique complète d'un pentomino


```dart
return PentominoGeometry( piece: piece, rotationCenter: rotationCenter, positionCenters: positionCenters, );
```

### describeTransformation

Décrit la transformation entre la position de base et une autre position


```dart
String describeTransformation(int positionIndex) {
```

### toOffset

Extension pour Offset (utilisé par Flutter)


```dart
Offset toOffset() => Offset(x, y);
```

