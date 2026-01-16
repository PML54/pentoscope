# common/pentomino_game_mixin.dart

**Module:** common

## Fonctions

### canPlacePiece

Mixin contenant les fonctions communes aux providers Classical et Pentoscope

Ce mixin factorise la logique partagée pour :
- Les transformations isométriques (remapping de mastercase)
- La gestion des coordonnées (normalisées, brutes, absolues)
- Le calcul de la mastercase par défaut
- La conversion entre coordonnées normalisées et brutes
Retourne le plateau actuel
Retourne la pièce sélectionnée (peut être null)
Retourne l'index de position actuel
Retourne la mastercase sélectionnée (peut être null)
Vérifie si une pièce peut être placée à une position donnée


```dart
bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY);
```

### coordsInPositionOrder

Remapping de la cellule de référence (mastercase) lors d'une isométrie

Utilise la version robuste de Pentoscope qui préserve l'identité géométrique
en utilisant les coordonnées normalisées dans l'ordre stable des cellules.

Cette méthode est IDENTIQUE dans les deux providers (version Pentoscope).


```dart
List<Point> coordsInPositionOrder(int posIdx) {
```

### Point

```dart
return Point(x, y);
```

### getRawMastercaseCoords

Convertit les coordonnées normalisées de la mastercase en coordonnées brutes
pour la position actuelle de la pièce (grille 5×5)

Cette méthode est IDENTIQUE dans Pentoscope et peut être utilisée dans Classical.


```dart
Point getRawMastercaseCoords( Pento piece, int positionIndex, Point normalizedMastercase, ) {
```

### Point

```dart
return Point(x, y);
```

### Point

Calcule la mastercase par défaut (première cellule normalisée)

Cette méthode est IDENTIQUE dans Pentoscope et peut être utilisée dans Classical.


```dart
return Point(rawX - minX, rawY - minY);
```

### calculateAnchorPosition

Calcule la position d'ancrage en tenant compte de la mastercase

Si une mastercase est définie, calcule où doit être l'ancre (gridX, gridY)
pour que la mastercase soit à la position (gridX, gridY) du doigt.


```dart
Point calculateAnchorPosition(int gridX, int gridY) {
```

### Point

```dart
return Point(gridX, gridY);
```

### Point

```dart
return Point(gridX - rawMastercase.x, gridY - rawMastercase.y);
```

