# pentoscope/pentoscope_provider.dart

**Module:** pentoscope

## Fonctions

### applyIsometryRotationCW

```dart
TransformationResult applyIsometryRotationCW() {
```

### applyIsometryRotationTW

```dart
TransformationResult applyIsometryRotationTW() {
```

### applyIsometrySymmetryH

```dart
TransformationResult applyIsometrySymmetryH() {
```

### applyIsometrySymmetryV

```dart
TransformationResult applyIsometrySymmetryV() {
```

### build

```dart
PentoscopeState build() {
```

### startTimer

Démarre le chronomètre


```dart
void startTimer() {
```

### stopTimer

Arrête le chronomètre


```dart
void stopTimer() {
```

### getElapsedSeconds

Retourne le temps écoulé en secondes


```dart
int getElapsedSeconds() {
```

### calculateNote

Calcule la note de "non-triche" (0-20)
- 0 hints → 20/20
- ≥ nbPieces - 1 hints → 0/20
- Entre les deux → linéaire


```dart
int calculateNote() {
```

### applyHint

Applique un indice en plaçant une pièce du slider selon une solution possible


```dart
void applyHint() {
```

### cancelSelection

Version interne pour vérifier avec un état spécifique


```dart
void cancelSelection() {
```

### clearPreview

```dart
void clearPreview() {
```

### cycleToNextOrientation

```dart
void cycleToNextOrientation() {
```

### removePlacedPiece

```dart
void removePlacedPiece(PentoscopePlacedPiece placed) {
```

### reset

```dart
Future<void> reset() async {
```

### selectPiece

```dart
void selectPiece(Pento piece) {
```

### selectPlacedPiece

```dart
void selectPlacedPiece( PentoscopePlacedPiece placed, int absoluteX, int absoluteY, ) {
```

### Point

```dart
return Point(x, y);
```

### setViewOrientation

À appeler depuis l'UI (board) quand l'orientation change.
Ne change aucune coordonnée: uniquement l'interprétation des actions
(ex: Sym H/V) en mode paysage.


```dart
void setViewOrientation(bool isLandscape) {
```

### startPuzzle

```dart
Future<void> startPuzzle( PentoscopeSize size, {
```

### startPuzzleFromSeed

🎮 Démarre un puzzle avec un seed et des pièces spécifiques (mode multiplayer)


```dart
Future<void> startPuzzleFromSeed( PentoscopeSize size, int seed, List<int> pieceIds, ) async {
```

### changeBoardSize

🔄 Change la taille du plateau (redémarre avec un nouveau puzzle)


```dart
Future<void> changeBoardSize(PentoscopeSize newSize) async {
```

### startPuzzle

```dart
await startPuzzle( newSize, difficulty: PentoscopeDifficulty.random, showSolution: false, );
```

### tryPlacePiece

💾 Sauvegarder le niveau terminé
Méthode publique pour obtenir les coordonnées brutes de la mastercase
Utile pour le widget board qui doit reconstruire les coordonnées de drag


```dart
bool tryPlacePiece(int gridX, int gridY) {
```

### updatePreview

```dart
void updatePreview(int gridX, int gridY) {
```

### Point

```dart
return Point(x, y);
```

### Point

```dart
return Point(x, y);
```

### Point

Calcule la position gridX,gridY pour maintenir la mastercase fixe lors d'une transformation


```dart
return Point(x, y);
```

### Point

```dart
return Point(originalPiece.gridX, originalPiece.gridY);
```

### Point

```dart
return Point(originalPiece.gridX, originalPiece.gridY);
```

### Point

```dart
return Point(x, y);
```

### Point

```dart
return Point(newGridX, newGridY);
```

### Point

Helper: calcule la mastercase par défaut (première cellule normalisée)


```dart
return Point(rawX - minX, rawY - minY);
```

### Point

Convertit les coordonnées normalisées de la mastercase en coordonnées brutes
pour la position actuelle de la pièce (grille 5×5)


```dart
return Point(x, y);
```

### coordsInPositionOrder

Annule le mode "pièce placée en main" (sélection sur plateau) en
reconstruisant le plateau complet à partir des pièces placées.
À appeler avant de sélectionner une pièce du slider.
Cherche la position valide la plus proche autour de la mastercase
Retourne null si aucune position valide n'est trouvée dans un rayon raisonnable
Trouve la position valide la plus proche du doigt
dragGridX/Y = position du doigt sur le plateau
Retourne la position d'ancre valide la plus proche

✅ FIX: On cherche la position où la MASTERCASE serait la plus proche du doigt
Si pas de mastercase définie, on utilise la première cellule normalisée
Génère TOUS les placements possibles pour une pièce à une positionIndex donnée
Retourne une liste de Point (gridX, gridY) où la pièce peut être placée


```dart
List<Point> coordsInPositionOrder(int posIdx) {
```

### Point

```dart
return Point(x, y);
```

### selectPieceFromSliderForTutorial

Sélectionne une pièce depuis le slider (pour tutoriel)


```dart
void selectPieceFromSliderForTutorial(int pieceNumber) {
```

### highlightPieceInSlider

Surligne une pièce dans le slider (pour tutoriel)


```dart
void highlightPieceInSlider(int pieceNumber) {
```

### clearSliderHighlight

Efface le surlignage du slider (pour tutoriel)


```dart
void clearSliderHighlight() {
```

### scrollSliderToPiece

Fait défiler le slider jusqu'à une pièce (pour tutoriel)


```dart
void scrollSliderToPiece(int pieceNumber) {
```

### placeSelectedPieceForTutorial

Place la pièce sélectionnée à une position donnée (pour tutoriel)


```dart
void placeSelectedPieceForTutorial(int gridX, int gridY) {
```

### selectPlacedPieceAt

Sélectionne une pièce placée sur le plateau (pour tutoriel)


```dart
void selectPlacedPieceAt(int x, int y) {
```

### rotateAroundMasterForTutorial

Applique une rotation autour de la mastercase (pour tutoriel)


```dart
void rotateAroundMasterForTutorial(int pieceNumber, int quarterTurns) {
```

### PentoscopePlacedPiece

Pièce placée sur le plateau Pentoscope


```dart
const PentoscopePlacedPiece({
```

### Point

Coordonnées absolues des cellules occupées (normalisées)


```dart
yield Point(gridX + localX, gridY + localY);
```

### copyWith

```dart
PentoscopePlacedPiece copyWith({
```

### PentoscopePlacedPiece

```dart
return PentoscopePlacedPiece( piece: piece ?? this.piece, positionIndex: positionIndex ?? this.positionIndex, gridX: gridX ?? this.gridX, gridY: gridY ?? this.gridY, );
```

### PentoscopeState

État du jeu Pentoscope
Orientation "vue" (repère écran). Ne change pas la logique.
Sert à interpréter des actions (ex: Sym H/V) en paysage.


```dart
const PentoscopeState({
```

### PentoscopeState

```dart
return PentoscopeState( plateau: Plateau.allVisible(5, 5), showSolution: false, // ✅ NOUVEAU currentSolution: null, // ✅ NOUVEAU );
```

### canPlacePiece

```dart
bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY) {
```

### copyWith

```dart
PentoscopeState copyWith({
```

### PentoscopeState

```dart
return PentoscopeState( viewOrientation: viewOrientation ?? this.viewOrientation, puzzle: puzzle ?? this.puzzle, plateau: plateau ?? this.plateau, availablePieces: availablePieces ?? this.availablePieces, placedPieces: placedPieces ?? this.placedPieces, selectedPiece: clearSelectedPiece ? null : (selectedPiece ?? this.selectedPiece), selectedPositionIndex: selectedPositionIndex ?? this.selectedPositionIndex, piecePositionIndices: piecePositionIndices ?? this.piecePositionIndices, selectedPlacedPiece: clearSelectedPlacedPiece ? null : (selectedPlacedPiece ?? this.selectedPlacedPiece), selectedCellInPiece: clearSelectedCellInPiece ? null : (selectedCellInPiece ?? this.selectedCellInPiece), previewX: clearPreview ? null : (previewX ?? this.previewX), previewY: clearPreview ? null : (previewY ?? this.previewY), isPreviewValid: clearPreview ? false : (isPreviewValid ?? this.isPreviewValid), validPlacements: validPlacements ?? this.validPlacements, // ✨ NOUVEAU isComplete: isComplete ?? this.isComplete, isometryCount: isometryCount ?? this.isometryCount, translationCount: translationCount ?? this.translationCount, hintCount: hintCount ?? this.hintCount, deleteCount: deleteCount ?? this.deleteCount, isSnapped: isSnapped ?? this.isSnapped, showSolution: showSolution ?? this.showSolution, // ✅ NOUVEAU currentSolution: currentSolution ?? this.currentSolution, // ✅ NOUVEAU hasPossibleSolution: hasPossibleSolution ?? this.hasPossibleSolution, // 💡 HINT elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds, // ⏱️ Timer );
```

### getPiecePositionIndex

```dart
int getPiecePositionIndex(int pieceId) {
```

