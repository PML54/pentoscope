# common/placed_piece.dart

**Module:** common

## Fonctions

### PlacedPiece

Pièce placée sur un plateau de jeu

Utilisée par:
- Isopento
- Pentoscope
- (Extensible pour autres modules)
La pièce (pentomino)
Index de la position/orientation actuelle (0-7 ou moins selon la pièce)
Position X sur le plateau (coin supérieur gauche)
Position Y sur le plateau (coin supérieur gauche)
Nombre d'isométries appliquées pour transformer la pièce
(utile pour tracker la difficulté / complexité)


```dart
const PlacedPiece({
```

### Point

Coordonnées absolues des cellules occupées (normalisées)

Exemple: Si piece est en position 2, gridX=5, gridY=3
Retourne les Point(x, y) de chaque cellule occupée


```dart
yield Point(gridX + localX, gridY + localY);
```

### copyWith

Crée une copie avec champs optionnels modifiés


```dart
PlacedPiece copyWith({
```

### PlacedPiece

```dart
return PlacedPiece( piece: piece ?? this.piece, positionIndex: positionIndex ?? this.positionIndex, gridX: gridX ?? this.gridX, gridY: gridY ?? this.gridY, isometriesUsed: isometriesUsed ?? this.isometriesUsed, );
```

### toString

```dart
String toString() => 'PlacedPiece(${piece.id}, pos=$positionIndex, grid=($gridX,$gridY), iso=$isometriesUsed)';
```

