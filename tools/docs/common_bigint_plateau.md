# common/bigint_plateau.dart

**Module:** common

## Fonctions

### placePiece

Calcule le décalage (en bits) pour une case [cellIndex] 0..59.
case 59 -> bits 0..5, case 58 -> 6..11, ..., case 0 -> 354..359
Place une pièce (par id) sur une liste de cases [cellIndices] (indices 0..59).
[bit6ById] vient de pentominos : {id -> bit6}


```dart
BigIntPlateau placePiece({
```

### ArgumentError

```dart
throw ArgumentError('bit6 introuvable pour pieceId=$pieceId');
```

### ArgumentError

```dart
throw ArgumentError('cellIndex hors limites: $cellIndex');
```

### clearCells

Efface une liste de cases (les remet à vide).


```dart
BigIntPlateau clearCells(Iterable<int> cellIndices) {
```

### ArgumentError

```dart
throw ArgumentError('cellIndex hors limites: $cellIndex');
```

### getCell

Retourne la valeur de la case (x, y) :
- 0 si vide
- 1..12 = pieceId si occupée


```dart
int getCell(int x, int y) {
```

### ArgumentError

```dart
throw ArgumentError('Coordonnées hors plateau: ($x, $y)');
```

