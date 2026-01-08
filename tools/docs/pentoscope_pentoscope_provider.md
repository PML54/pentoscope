# pentoscope/pentoscope_provider.dart

**Module:** pentoscope

## Fonctions

### applyIsometryRotationCW

```dart
void applyIsometryRotationCW() {
```

### applyIsometryRotationTW

```dart
void applyIsometryRotationTW() {
```

### applyIsometrySymmetryH

```dart
void applyIsometrySymmetryH() {
```

### applyIsometrySymmetryV

```dart
void applyIsometrySymmetryV() {
```

### build

```dart
PentoscopeState build() {
```

### cancelSelection

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

### tryPlacePiece

```dart
bool tryPlacePiece(int gridX, int gridY) {
```

### updatePreview

```dart
void updatePreview(int gridX, int gridY) {
```

### Point

Helper: calcule la mastercase par défaut (première cellule normalisée)


```dart
return Point(rawX - minX, rawY - minY);
```

### coordsInPositionOrder

Annule le mode "pièce placée en main" (sélection sur plateau) en
reconstruisant le plateau complet à partir des pièces placées.
À appeler avant de sélectionner une pièce du slider.
Trouve la position valide la plus proche du doigt (en tenant compte de la mastercase)
dragGridX/Y = position du doigt
Retourne la position d'ancre valide la plus proche
Génère TOUS les placements possibles pour une pièce à une positionIndex donnée
Retourne une liste de Point (gridX, gridY) où la pièce peut être placée


```dart
List<Point> coordsInPositionOrder(int posIdx) {
```

### Point

```dart
return Point(x, y);
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
return PentoscopeState( viewOrientation: viewOrientation ?? this.viewOrientation, puzzle: puzzle ?? this.puzzle, plateau: plateau ?? this.plateau, availablePieces: availablePieces ?? this.availablePieces, placedPieces: placedPieces ?? this.placedPieces, selectedPiece: clearSelectedPiece ? null : (selectedPiece ?? this.selectedPiece), selectedPositionIndex: selectedPositionIndex ?? this.selectedPositionIndex, piecePositionIndices: piecePositionIndices ?? this.piecePositionIndices, selectedPlacedPiece: clearSelectedPlacedPiece ? null : (selectedPlacedPiece ?? this.selectedPlacedPiece), selectedCellInPiece: clearSelectedCellInPiece ? null : (selectedCellInPiece ?? this.selectedCellInPiece), previewX: clearPreview ? null : (previewX ?? this.previewX), previewY: clearPreview ? null : (previewY ?? this.previewY), isPreviewValid: clearPreview ? false : (isPreviewValid ?? this.isPreviewValid), validPlacements: validPlacements ?? this.validPlacements, // ✨ NOUVEAU isComplete: isComplete ?? this.isComplete, isometryCount: isometryCount ?? this.isometryCount, translationCount: translationCount ?? this.translationCount, score: score ?? this.score, // 🎯 NOUVEAU isSnapped: isSnapped ?? this.isSnapped, showSolution: showSolution ?? this.showSolution, // ✅ NOUVEAU currentSolution: currentSolution ?? this.currentSolution, // ✅ NOUVEAU );
```

### getPiecePositionIndex

```dart
int getPiecePositionIndex(int pieceId) {
```

