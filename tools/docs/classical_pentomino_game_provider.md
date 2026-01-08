# classical/pentomino_game_provider.dart

**Module:** classical

## Fonctions

### applyIsometryRotationCW

Applique une rotation 90° horaire


```dart
void applyIsometryRotationCW() {
```

### applyIsometryRotationTW

Applique une rotation 90° anti-horaire


```dart
void applyIsometryRotationTW() {
```

### applyIsometrySymmetryH

Applique une symétrie (H/V swap en paysage)


```dart
void applyIsometrySymmetryH() {
```

### applyIsometrySymmetryV

Applique une symétrie verticale (V/H swap en paysage)


```dart
void applyIsometrySymmetryV() {
```

### build

```dart
PentominoGameState build() {
```

### calculateScore

```dart
int calculateScore(int elapsedSeconds) {
```

### cancelSelection

Annule la sélection en cours


```dart
void cancelSelection() {
```

### cancelTutorial

Annule le tutoriel (toujours restaurer)


```dart
void cancelTutorial() {
```

### onPuzzleCompleted

```dart
Future<void> onPuzzleCompleted() async {
```

### clearBoardHighlight

Efface la surbrillance du plateau


```dart
void clearBoardHighlight() {
```

### clearCellHighlights

Efface toutes les surbrillances de cases


```dart
void clearCellHighlights() {
```

### clearIsometryIconHighlight

🆕 Efface la surbrillance des icônes d'isométrie


```dart
void clearIsometryIconHighlight() {
```

### incrementSolutionsViewCount

🆕 Incrémente le compteur de consultation des solutions


```dart
void incrementSolutionsViewCount() {
```

### clearMastercaseHighlight

Efface la surbrillance de la mastercase


```dart
void clearMastercaseHighlight() {
```

### clearPreview

Efface la prévisualisation


```dart
void clearPreview() {
```

### clearSliderHighlight

Efface la surbrillance du slider


```dart
void clearSliderHighlight() {
```

### cycleToNextOrientation

Cycle vers l'orientation suivante de la pièce sélectionnée
Passe simplement à l'index suivant dans piece.positions (boucle)


```dart
void cycleToNextOrientation() {
```

### enterIsometriesMode

Entre en mode isométries (sauvegarde l'état actuel)


```dart
void enterIsometriesMode() {
```

### enterTutorialMode

Entre en mode tutoriel : sauvegarde l'état actuel et reset le jeu


```dart
void enterTutorialMode() {
```

### StateError

```dart
throw StateError('Déjà en mode tutoriel');
```

### StateError

```dart
throw StateError( 'Impossible d\'entrer en tutoriel depuis le mode isométries', );
```

### exitIsometriesMode

Sort du mode isométries (restaure l'état sauvegardé)


```dart
void exitIsometriesMode() {
```

### exitTutorialMode

Sort du mode tutoriel et restaure l'état sauvegardé


```dart
void exitTutorialMode({bool restore = true}) {
```

### StateError

```dart
throw StateError('Pas en mode tutoriel');
```

### StateError

```dart
throw StateError('Pas de sauvegarde disponible');
```

### getElapsedSeconds

Trouve une pièce placée à une position donnée
Trouve une pièce placée par son ID


```dart
int getElapsedSeconds() {
```

### highlightCell

Trouve la pièce placée à une position donnée
Surligne une case individuelle avec une couleur


```dart
void highlightCell(int x, int y, Color color) {
```

### ArgumentError

```dart
throw ArgumentError('Position hors limites: ($x, $y)');
```

### highlightCells

Surligne plusieurs cases avec la même couleur


```dart
void highlightCells(List<Point> cells, Color color) {
```

### highlightIsometryIcon

🆕 Surligne une icône d'isométrie (pour tutoriel)
iconName: 'rotation', 'rotation_cw', 'symmetry_h', 'symmetry_v'


```dart
void highlightIsometryIcon(String iconName) {
```

### highlightMastercase

Surligne la mastercase d'une pièce


```dart
void highlightMastercase(Point position) {
```

### highlightPieceInSlider

Surligne une pièce dans le slider (sans la sélectionner)


```dart
void highlightPieceInSlider(int pieceNumber) {
```

### ArgumentError

```dart
throw ArgumentError('pieceNumber doit être entre 1 et 12');
```

### highlightPieceOnBoard

Surligne une pièce posée sur le plateau (sans la sélectionner)


```dart
void highlightPieceOnBoard(int pieceNumber) {
```

### ArgumentError

```dart
throw ArgumentError('pieceNumber doit être entre 1 et 12');
```

### StateError

```dart
throw StateError('La pièce $pieceNumber n\'est pas sur le plateau');
```

### highlightValidPositions

Surligne toutes les positions valides pour la pièce sélectionnée


```dart
void highlightValidPositions(Pento piece, int positionIndex, Color color) {
```

### placeSelectedPieceForTutorial

Place la pièce sélectionnée à la position indiquée (pour tutoriel)
Place la pièce sélectionnée à la position indiquée (pour tutoriel)
gridX/gridY = position de la MASTERCASE (pas du coin haut-gauche)


```dart
void placeSelectedPieceForTutorial(int gridX, int gridY) {
```

### removePlacedPiece

Retire une pièce placée du plateau


```dart
void removePlacedPiece(PlacedPiece placedPiece) {
```

### reset

Réinitialise le jeu


```dart
void reset() {
```

### resetSliderPosition

Remet le slider à sa position initiale


```dart
void resetSliderPosition() {
```

### restoreState

🆕 Restaure un état sauvegardé (utilisé par TutorialProvider au quit)


```dart
void restoreState(PentominoGameState savedState) {
```

### scrollSlider

Fait défiler le slider de N positions
positions > 0 : vers la droite
positions < 0 : vers la gauche


```dart
void scrollSlider(int positions) {
```

### scrollSliderToPiece

Fait défiler le slider pour centrer sur une pièce


```dart
void scrollSliderToPiece(int pieceNumber) {
```

### ArgumentError

```dart
throw ArgumentError('pieceNumber doit être entre 1 et 12');
```

### selectPiece

Sélectionne une pièce du slider (commence le drag)


```dart
void selectPiece(Pento piece) {
```

### selectPieceFromSliderForTutorial

Sélectionne une pièce du slider avec mastercase explicite
(pour compatibilité Scratch SELECT_PIECE_FROM_SLIDER)


```dart
void selectPieceFromSliderForTutorial(int pieceNumber) {
```

### ArgumentError

```dart
throw ArgumentError('pieceNumber doit être entre 1 et 12');
```

### selectPlacedPiece

Sélectionne une pièce déjà placée pour la déplacer
[cellX] et [cellY] sont les coordonnées de la case touchée sur le plateau
Sélectionne une pièce déjà placée pour la déplacer
[cellX] et [cellY] sont les coordonnées de la case touchée sur le plateau


```dart
void selectPlacedPiece(PlacedPiece placedPiece, int cellX, int cellY) {
```

### selectPlacedPieceAtForTutorial

Sélectionne une pièce sur le plateau à une position donnée
(pour compatibilité Scratch SELECT_PIECE_ON_BOARD_AT)


```dart
void selectPlacedPieceAtForTutorial(int x, int y) {
```

### StateError

```dart
throw StateError('Aucune pièce à la position ($x, $y)');
```

### selectPlacedPieceWithMastercaseForTutorial

Sélectionne une pièce avec une mastercase explicite
(pour compatibilité Scratch SELECT_PIECE_ON_BOARD_WITH_MASTERCASE)


```dart
void selectPlacedPieceWithMastercaseForTutorial( int pieceNumber, int mastercaseX, int mastercaseY, ) {
```

### StateError

```dart
throw StateError('La pièce $pieceNumber n\'est pas sur le plateau');
```

### ArgumentError

```dart
throw ArgumentError( 'La position ($mastercaseX, $mastercaseY) n\'est pas dans la pièce $pieceNumber', );
```

### setViewOrientation

Enregistre l'orientation de la vue (portrait/landscape)


```dart
void setViewOrientation(bool isLandscape) {
```

### startTimer

```dart
void startTimer() {
```

### stopTimer

```dart
void stopTimer() {
```

### tryPlacePiece

Tente de placer la pièce sélectionnée sur le plateau
[gridX] et [gridY] sont les coordonnées où on lâche la pièce (position du doigt)
Tente de placer la pièce sélectionnée sur le plateau
[gridX] et [gridY] sont les coordonnées où on lâche la pièce (position du doigt)


```dart
bool tryPlacePiece(int gridX, int gridY) {
```

### undoLastPlacement

Retire la dernière pièce placée (undo)


```dart
void undoLastPlacement() {
```

### updatePreview

Met à jour la prévisualisation du placement pendant le drag
AVEC SNAP INTELLIGENT


```dart
void updatePreview(int gridX, int gridY) {
```

### Point

Applique une transformation isométrique via lookup
Calcule la nouvelle position locale de la master case après une transformation
[centerX], [centerY] : coordonnées absolues de la master case (fixe)
[newGridX], [newGridY] : nouvelle ancre de la pièce transformée


```dart
return Point(newLocalX, newLocalY);
```

### Point

Vérifie si une pièce peut être placée à une position donnée
Utilisé après une transformation géométrique
Calcule le nombre de solutions possibles avec une pièce transformée
Crée temporairement un plateau avec toutes les pièces incluant la transformée
Extrait les coordonnées absolues d'une pièce placée
Cherche la position valide la plus proche dans un rayon donné
Utilise la distance euclidienne pour trouver vraiment la plus proche
Recalcule la validité du plateau et les cellules problématiques
Remapping de la cellule de référence lors d'une isométrie


```dart
return Point(localX, localY);
```

