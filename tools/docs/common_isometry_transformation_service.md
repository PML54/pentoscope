# common/isometry_transformation_service.dart

**Module:** common

## Fonctions

### applyRotationTW

Service de transformation des isométries (rotations, symétries)

Logique COMMUNE utilisée par:
- IsopentoNotifier
- PentoscopeNotifier

Les Notifiers implémentent les méthodes privées spécifiques:
- _applyPlacedPieceIsometry()
- _applySliderPieceIsometry()
- _extractAbsoluteCoords()
- _canPlacePieceAt()
- recognizeShape()
- _calculateDefaultCell()

Ce service déléguera au Notifier pour les opérations.
Applique une rotation CCW (Trigonometric Wise) à la pièce sélectionnée

Paramètres:
- rotateFunc: fonction appelée avec (coords, cx, cy) → coords transformées
- onSuccess: callback appelé si transformation réussie
- onFailure: callback appelé si transformation échoue


```dart
Future<bool> applyRotationTW({
```

### applyRotationCW

Applique une rotation CW (Clockwise) à la pièce sélectionnée


```dart
Future<bool> applyRotationCW({
```

### applySymmetryH

Applique une symétrie horizontale


```dart
Future<bool> applySymmetryH({
```

### applySymmetryV

Applique une symétrie verticale


```dart
Future<bool> applySymmetryV({
```

### canPlacePiece

Valide le placement d'une pièce sur le plateau

Paramètres:
- plateau: le plateau actuel
- piece: la pièce à placer
- positionIndex: l'orientation
- gridX, gridY: position de placement

Retourne: true si placement valide


```dart
bool canPlacePiece( Plateau plateau, Pento piece, int positionIndex, int gridX, int gridY, ) {
```

### UnimplementedError

Extensions helper pour les transformations géométriques

Note: Ces fonctions pourraient être dans isometry_transforms.dart
mais on les remet ici pour la complétude du service
Rotation autour d'un point avec nombre d'étapes

steps: nombre de rotations de 90°
- 1 = CCW (trigonométrique)
- 3 = CW (horaire)
- Utilisé internement, pas appelé directement


```dart
throw UnimplementedError( 'Utilise rotateAroundPoint() de isometry_transforms.dart' );
```

