# classical/pentomino_game_state.dart

**Module:** classical

## Fonctions

### PentominoGameState

État du jeu de pentominos
État initial du jeu


```dart
return PentominoGameState( plateau: Plateau.allVisible(6, 10), availablePieces: List.from(pentominos), placedPieces: [], selectedPiece: null, selectedPositionIndex: 0, piecePositionIndices: {},
```

### canPlacePiece

Vérifie si une pièce peut être placée à une position donnée


```dart
bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY) {
```

### copyWith

```dart
PentominoGameState copyWith({
```

### PentominoGameState

```dart
return PentominoGameState( plateau: plateau ?? this.plateau, availablePieces: availablePieces ?? this.availablePieces, placedPieces: placedPieces ?? this.placedPieces, selectedPiece: clearSelectedPiece ? null : (selectedPiece ?? this.selectedPiece), selectedPositionIndex: selectedPositionIndex ?? this.selectedPositionIndex, selectedPlacedPiece: clearSelectedPlacedPiece ? null : (selectedPlacedPiece ?? this.selectedPlacedPiece), piecePositionIndices: piecePositionIndices ?? this.piecePositionIndices, selectedCellInPiece: clearSelectedCellInPiece ? null : (selectedCellInPiece ?? this.selectedCellInPiece), previewX: clearPreview ? null : (previewX ?? this.previewX), previewY: clearPreview ? null : (previewY ?? this.previewY), isPreviewValid: clearPreview ? false : (isPreviewValid ?? this.isPreviewValid), isSnapped: clearPreview ? false : (isSnapped ?? this.isSnapped), // 🆕 solutionsCount: solutionsCount ?? this.solutionsCount, solvedSolutionIndex: clearSolvedSolutionIndex ? null : (solvedSolutionIndex ?? this.solvedSolutionIndex), // 🆕 isIsometriesMode: isIsometriesMode ?? this.isIsometriesMode, savedGameState: clearSavedGameState ? null : (savedGameState ?? this.savedGameState),  // Validation boardIsValid: boardIsValid ?? this.boardIsValid, overlappingCells: overlappingCells ?? this.overlappingCells, offBoardCells: offBoardCells ?? this.offBoardCells,  // 🆕 Tutoriel isInTutorial: isInTutorial ?? this.isInTutorial, highlightedSliderPiece: clearHighlightedSliderPiece ? null : (highlightedSliderPiece ?? this.highlightedSliderPiece), highlightedBoardPiece: clearHighlightedBoardPiece ? null : (highlightedBoardPiece ?? this.highlightedBoardPiece), highlightedMastercase: clearHighlightedMastercase ? null : (highlightedMastercase ?? this.highlightedMastercase), cellHighlights: clearCellHighlights ? <Point, Color>{}
```

### getPiecePositionIndex

Obtient l'index de position pour une pièce (par défaut 0)


```dart
int getPiecePositionIndex(int pieceId) {
```

