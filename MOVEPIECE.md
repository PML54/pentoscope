# 🎮 MOVEPIECE - Déplacement des pièces dans Pentapol

**Date de création** : 1er décembre 2025 à 01:30  
**Sujet** : Mécanisme complet du drag & drop des pièces du slider vers le plateau

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture des composants](#architecture-des-composants)
3. [Flux complet du déplacement](#flux-complet-du-déplacement)
4. [Système de coordonnées](#système-de-coordonnées)
5. [Gestion de l'état](#gestion-de-létat)
6. [Code détaillé](#code-détaillé)
7. [Cas particuliers](#cas-particuliers)

---

## 🎯 Vue d'ensemble

### Principe général

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUX DE DÉPLACEMENT                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Utilisateur TAP sur pièce dans slider                       │
│     └─> Sélection de la pièce                                   │
│         └─> État : selectedPiece = index                        │
│                                                                  │
│  2. Utilisateur DRAG la pièce                                   │
│     └─> Widget DraggablePieceWidget activé                      │
│         └─> Feedback visuel (pièce suit le doigt)              │
│                                                                  │
│  3. Pièce survole le plateau                                    │
│     └─> GameBoard détecte DragTarget.onWillAccept              │
│         └─> Calcul position grille (gridX, gridY)              │
│         └─> Preview affiché si placement valide                │
│                                                                  │
│  4. Utilisateur DROP la pièce                                   │
│     └─> GameBoard.onAccept appelé                              │
│         └─> Provider.tryPlacePiece(gridX, gridY)               │
│         └─> Validation + Ajout à placedPieces                  │
│         └─> Haptic feedback                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Composants impliqués

| Composant | Rôle | Fichier |
|-----------|------|---------|
| **PieceSlider** | Affiche les pièces disponibles | `piece_slider.dart` |
| **DraggablePieceWidget** | Gère le drag & drop | `draggable_piece_widget.dart` |
| **GameBoard** | Plateau avec DragTarget | `game_board.dart` |
| **PieceRenderer** | Affiche la pièce | `piece_renderer.dart` |
| **PentominoGameProvider** | Logique métier | `pentomino_game_provider.dart` |
| **PentominoGameState** | État du jeu | `pentomino_game_state.dart` |

---

## 🏗️ Architecture des composants

### Hiérarchie des widgets

```
PentominoGameScreen
├─> PieceSlider (slider horizontal en bas)
│   └─> ListView.builder
│       └─> DraggablePieceWidget (pour chaque pièce)
│           ├─> Draggable<DragData>
│           │   ├─> child: PieceRenderer (pièce normale)
│           │   ├─> feedback: PieceRenderer (pièce pendant drag)
│           │   └─> childWhenDragging: PieceRenderer (opacité 0.3)
│           └─> GestureDetector (tap pour sélection)
│
└─> GameBoard (plateau de jeu)
    └─> DragTarget<DragData>
        ├─> onWillAccept: Calcul preview
        ├─> onAccept: Placement final
        ├─> onLeave: Efface preview
        └─> builder: Affiche plateau + preview
```

### Flux de données

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUX DE DONNÉES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  USER ACTION                                                     │
│      │                                                           │
│      ▼                                                           │
│  DraggablePieceWidget                                           │
│      │                                                           │
│      ├─> onDragStarted()                                        │
│      │   └─> Provider.selectPiece(index)                        │
│      │       └─> State.selectedPiece = index                    │
│      │                                                           │
│      ├─> Draggable.data = DragData(pieceIndex, orientation)    │
│      │                                                           │
│      └─> feedback = PieceRenderer (suit le doigt)              │
│                                                                  │
│  GameBoard (DragTarget)                                         │
│      │                                                           │
│      ├─> onWillAccept(DragData)                                │
│      │   └─> Calcul position grille                            │
│      │   └─> Provider.updatePreview(gridX, gridY)              │
│      │   └─> State.previewX/Y + isPreviewValid                 │
│      │                                                           │
│      ├─> onAccept(DragData)                                    │
│      │   └─> Provider.tryPlacePiece(gridX, gridY)              │
│      │       └─> Validation canPlacePiece()                    │
│      │       └─> State.placedPieces.add(PlacedPiece)           │
│      │       └─> State.selectedPiece = null                    │
│      │       └─> Haptic feedback                                │
│      │                                                           │
│      └─> onLeave()                                              │
│          └─> Provider.clearPreview()                            │
│              └─> State.previewX/Y = null                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flux complet du déplacement

### Étape 1 : Sélection de la pièce

**Action utilisateur** : Tap sur une pièce dans le slider

**Code** : `DraggablePieceWidget`
```dart
GestureDetector(
  onTap: () {
    // Sélectionner la pièce
    ref.read(pentominoGameProvider.notifier).selectPiece(pieceIndex);
  },
  child: Draggable<DragData>(
    // ...
  ),
)
```

**Provider** : `PentominoGameProvider.selectPiece()`
```dart
void selectPiece(int? pieceIndex) {
  if (pieceIndex == null) {
    state = state.copyWith(
      selectedPiece: null,
      selectedOrientation: 0,
    );
    return;
  }

  // Calculer la cellule de référence (coin supérieur gauche)
  final piece = state.availablePieces[pieceIndex];
  final orientation = state.pieceOrientations[pieceIndex] ?? 0;
  final shape = piece.orientations[orientation];
  final coords = GamePiece.shapeToCoordinates(shape);
  
  final minX = coords.map((p) => p.x).reduce(min);
  final minY = coords.map((p) => p.y).reduce(min);

  state = state.copyWith(
    selectedPiece: pieceIndex,
    selectedOrientation: orientation,
    referenceCellInPiece: Point(minX, minY),
  );
}
```

**État résultant** :
```dart
PentominoGameState {
  selectedPiece: 5,                    // Index de la pièce
  selectedOrientation: 0,              // Orientation actuelle
  referenceCellInPiece: Point(0, 0),  // Cellule de référence
}
```

---

### Étape 2 : Début du drag

**Action utilisateur** : Commence à déplacer la pièce

**Code** : `DraggablePieceWidget`
```dart
Draggable<DragData>(
  data: DragData(
    pieceIndex: pieceIndex,
    orientation: currentOrientation,
  ),
  
  onDragStarted: () {
    // Sélectionner la pièce si pas déjà sélectionnée
    if (state.selectedPiece != pieceIndex) {
      ref.read(pentominoGameProvider.notifier).selectPiece(pieceIndex);
    }
    // Haptic feedback
    HapticFeedback.selectionClick();
  },
  
  // Widget qui suit le doigt
  feedback: Transform.scale(
    scale: 1.2,  // Légèrement plus grand
    child: Opacity(
      opacity: 0.8,
      child: PieceRenderer(
        piece: piece,
        orientation: currentOrientation,
        size: cellSize,
      ),
    ),
  ),
  
  // Widget qui reste dans le slider (atténué)
  childWhenDragging: Opacity(
    opacity: 0.3,
    child: PieceRenderer(
      piece: piece,
      orientation: currentOrientation,
      size: cellSize,
    ),
  ),
  
  child: PieceRenderer(
    piece: piece,
    orientation: currentOrientation,
    size: cellSize,
  ),
)
```

**Visuel** :
- Pièce dans slider → Opacité 0.3 (fantôme)
- Pièce sous le doigt → Scale 1.2, Opacité 0.8 (feedback)

---

### Étape 3 : Survol du plateau

**Action utilisateur** : Déplace la pièce au-dessus du plateau

**Code** : `GameBoard.onWillAccept()`
```dart
DragTarget<DragData>(
  onWillAccept: (data) {
    if (data == null) return false;

    // Calculer la position de la grille sous le curseur
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(
      // Position globale du curseur
      details.offset,
    );

    // Convertir en coordonnées de grille
    final gridX = (localPosition.dx / cellSize).floor();
    final gridY = (localPosition.dy / cellSize).floor();

    // Vérifier limites
    if (gridX < 0 || gridX >= plateau.width ||
        gridY < 0 || gridY >= plateau.height) {
      ref.read(pentominoGameProvider.notifier).clearPreview();
      return false;
    }

    // Mettre à jour le preview
    ref.read(pentominoGameProvider.notifier).updatePreview(gridX, gridY);

    // Accepter le drop si placement valide
    return state.isPreviewValid;
  },
  
  // ...
)
```

**Provider** : `PentominoGameProvider.updatePreview()`
```dart
void updatePreview(int? gridX, int? gridY) {
  if (gridX == null || gridY == null || state.selectedPiece == null) {
    state = state.copyWith(
      previewX: null,
      previewY: null,
      isPreviewValid: false,
    );
    return;
  }

  // Vérifier si le placement est valide
  final isValid = canPlacePiece(
    state.selectedPiece!,
    gridX,
    gridY,
  );

  state = state.copyWith(
    previewX: gridX,
    previewY: gridY,
    isPreviewValid: isValid,
  );
}
```

**Validation** : `PentominoGameState.canPlacePiece()`
```dart
bool canPlacePiece(int pieceIndex, int gridX, int gridY) {
  final piece = availablePieces[pieceIndex];
  final orientation = pieceOrientations[pieceIndex] ?? 0;
  final shape = piece.orientations[orientation];
  final coords = GamePiece.shapeToCoordinates(shape);

  // Ajuster avec la cellule de référence
  final refCell = referenceCellInPiece ?? Point(0, 0);
  final adjustedCoords = coords.map(
    (p) => Point(
      gridX + (p.x - refCell.x),
      gridY + (p.y - refCell.y),
    ),
  ).toList();

  // Vérifier chaque cellule
  for (final coord in adjustedCoords) {
    // Hors limites ?
    if (coord.x < 0 || coord.x >= plateau.width ||
        coord.y < 0 || coord.y >= plateau.height) {
      return false;
    }

    // Case cachée ?
    if (plateau.getCell(coord.x, coord.y) == -1) {
      return false;
    }

    // Case déjà occupée ?
    if (plateau.getCell(coord.x, coord.y) != 0) {
      return false;
    }

    // Collision avec pièce placée ?
    for (final placed in placedPieces) {
      if (placed.occupiesCellAt(coord.x, coord.y)) {
        return false;
      }
    }
  }

  return true;
}
```

**Affichage preview** : `GameBoard.builder()`
```dart
// Afficher le preview si présent
if (state.previewX != null && state.previewY != null) {
  final piece = state.availablePieces[state.selectedPiece!];
  final orientation = state.selectedOrientation;
  final shape = piece.orientations[orientation];
  final coords = GamePiece.shapeToCoordinates(shape);

  for (final coord in coords) {
    final x = state.previewX! + coord.x;
    final y = state.previewY! + coord.y;

    // Dessiner cellule de preview
    Positioned(
      left: x * cellSize,
      top: y * cellSize,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: state.isPreviewValid
              ? Colors.green.withOpacity(0.3)  // Valide
              : Colors.red.withOpacity(0.3),   // Invalide
          border: Border.all(
            color: state.isPreviewValid
                ? Colors.green
                : Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
```

**Visuel** :
- Preview vert → Placement valide
- Preview rouge → Placement invalide

---

### Étape 4 : Drop de la pièce

**Action utilisateur** : Relâche la pièce sur le plateau

**Code** : `GameBoard.onAccept()`
```dart
DragTarget<DragData>(
  onAccept: (data) {
    // Calculer position finale
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(
      // Position du drop
      details.offset,
    );

    final gridX = (localPosition.dx / cellSize).floor();
    final gridY = (localPosition.dy / cellSize).floor();

    // Tenter le placement
    ref.read(pentominoGameProvider.notifier).tryPlacePiece(gridX, gridY);
  },
  
  // ...
)
```

**Provider** : `PentominoGameProvider.tryPlacePiece()`
```dart
void tryPlacePiece(int gridX, int gridY) {
  if (state.selectedPiece == null) return;

  final pieceIndex = state.selectedPiece!;

  // Vérifier validité
  if (!canPlacePiece(pieceIndex, gridX, gridY)) {
    // Placement invalide → Haptic error
    HapticFeedback.heavyImpact();
    return;
  }

  // Créer la pièce placée
  final piece = state.availablePieces[pieceIndex];
  final orientation = state.pieceOrientations[pieceIndex] ?? 0;

  final placedPiece = PlacedPiece(
    piece: piece,
    positionIndex: orientation,
    gridX: gridX,
    gridY: gridY,
  );

  // Ajouter à l'historique (pour undo)
  final newHistory = List<PentominoGameState>.from(state.history)
    ..add(state);

  // Mettre à jour l'état
  state = state.copyWith(
    placedPieces: [...state.placedPieces, placedPiece],
    selectedPiece: null,
    previewX: null,
    previewY: null,
    isPreviewValid: false,
    history: newHistory,
  );

  // Haptic feedback succès
  HapticFeedback.mediumImpact();

  // Vérifier victoire
  if (isCompleted) {
    HapticFeedback.heavyImpact();
    // Afficher message victoire
  }
}
```

**État résultant** :
```dart
PentominoGameState {
  placedPieces: [
    PlacedPiece(
      piece: Pento(id: 5, ...),
      positionIndex: 0,
      gridX: 2,
      gridY: 3,
    ),
    // ... autres pièces
  ],
  selectedPiece: null,  // Désélectionné
  previewX: null,
  previewY: null,
  history: [previousState],  // Pour undo
}
```

---

## 📐 Système de coordonnées

### Coordonnées multiples

Le système utilise **3 types de coordonnées** :

#### 1. Coordonnées de forme (Shape coordinates)
**Référentiel** : Grille 5×5 de la pièce

```
Exemple : Pièce T (id=5)
┌─────────────┐
│ . . X . .   │  X = cellule occupée (numéro 1-25)
│ . X X X .   │  . = cellule vide
│ . . . . .   │
│ . . . . .   │
│ . . . . .   │
└─────────────┘

Shape = [3, 7, 8, 9]  // Numéros des cellules occupées
```

#### 2. Coordonnées relatives (Relative coordinates)
**Référentiel** : Origine (0,0) au coin supérieur gauche de la pièce

```
Conversion : shapeToCoordinates()

Shape [3, 7, 8, 9] → Coords [(2,0), (1,1), (2,1), (3,1)]

┌─────────────┐
│ . . X . .   │  (2,0)
│ . X X X .   │  (1,1) (2,1) (3,1)
│ . . . . .   │
└─────────────┘
```

#### 3. Coordonnées absolues (Grid coordinates)
**Référentiel** : Plateau de jeu 6×10

```
Placement en (gridX=2, gridY=3)

Plateau 6×10 :
┌─────────────────────┐
│ . . . . . .         │
│ . . . . . .         │
│ . . . . . .         │
│ . . X . . .         │  (4,3) = gridX + relX
│ . X X X . .         │  (2,4) (3,4) (4,4)
│ . . . . . .         │
└─────────────────────┘
```

### Cellule de référence

**Concept** : Point d'ancrage pour le placement

```dart
// Calculée lors de la sélection
final coords = GamePiece.shapeToCoordinates(shape);
final minX = coords.map((p) => p.x).reduce(min);
final minY = coords.map((p) => p.y).reduce(min);

referenceCellInPiece = Point(minX, minY);  // Coin sup gauche
```

**Utilisation** :
```dart
// Placement : gridX/Y = position de la cellule de référence
// Autres cellules calculées relativement

for (final coord in relativeCoords) {
  final absX = gridX + (coord.x - refCell.x);
  final absY = gridY + (coord.y - refCell.y);
  // ...
}
```

---

## 🎮 Gestion de l'état

### Structure de l'état

```dart
class PentominoGameState {
  // Plateau et pièces
  final Plateau plateau;
  final List<Pento> availablePieces;
  final List<PlacedPiece> placedPieces;

  // Sélection
  final int? selectedPiece;              // Index pièce sélectionnée
  final int? selectedPlacedPiece;        // Index pièce placée sélectionnée
  final int selectedOrientation;         // Orientation actuelle
  final Map<int, int> pieceOrientations; // Orientations par pièce
  final Point? referenceCellInPiece;     // Cellule de référence

  // Preview
  final int? previewX;                   // Position X du preview
  final int? previewY;                   // Position Y du preview
  final bool isPreviewValid;             // Preview valide ?

  // Historique (pour undo)
  final List<PentominoGameState> history;

  // Tutoriel
  final bool isTutorialMode;
  final Map<String, dynamic> tutorialHighlights;
  final String? tutorialMessage;
}
```

### Transitions d'état

```
┌─────────────────────────────────────────────────────────────────┐
│                    MACHINE À ÉTATS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  État INITIAL                                                    │
│  ├─ selectedPiece: null                                         │
│  ├─ previewX/Y: null                                            │
│  └─ placedPieces: []                                            │
│                                                                  │
│  ↓ selectPiece(5)                                               │
│                                                                  │
│  État PIECE_SELECTED                                            │
│  ├─ selectedPiece: 5                                            │
│  ├─ selectedOrientation: 0                                      │
│  └─ referenceCellInPiece: Point(0,0)                           │
│                                                                  │
│  ↓ updatePreview(2, 3)                                          │
│                                                                  │
│  État PREVIEW_ACTIVE                                            │
│  ├─ selectedPiece: 5                                            │
│  ├─ previewX: 2, previewY: 3                                   │
│  └─ isPreviewValid: true                                        │
│                                                                  │
│  ↓ tryPlacePiece(2, 3)                                          │
│                                                                  │
│  État PIECE_PLACED                                              │
│  ├─ placedPieces: [PlacedPiece(...)]                          │
│  ├─ selectedPiece: null                                         │
│  ├─ previewX/Y: null                                            │
│  └─ history: [previousState]                                    │
│                                                                  │
│  ↓ undo()                                                        │
│                                                                  │
│  État PREVIOUS (restauré depuis history)                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💻 Code détaillé

### DragData (structure de données)

```dart
class DragData {
  final int pieceIndex;
  final int orientation;

  DragData({
    required this.pieceIndex,
    required this.orientation,
  });
}
```

### PlacedPiece (pièce placée)

```dart
class PlacedPiece {
  final Pento piece;
  final int positionIndex;  // Orientation
  final int gridX;          // Position X sur le plateau
  final int gridY;          // Position Y sur le plateau

  PlacedPiece({
    required this.piece,
    required this.positionIndex,
    required this.gridX,
    required this.gridY,
  });

  /// Retourne les cellules occupées (coordonnées absolues)
  List<Point> getOccupiedCells() {
    final shape = piece.orientations[positionIndex];
    final relativeCoords = GamePiece.shapeToCoordinates(shape);
    
    return relativeCoords.map(
      (p) => Point(gridX + p.x, gridY + p.y),
    ).toList();
  }

  /// Vérifie si occupe une cellule donnée
  bool occupiesCellAt(int x, int y) {
    return getOccupiedCells().any((p) => p.x == x && p.y == y);
  }
}
```

### Conversion shape → coordinates

```dart
// Dans GamePiece
static List<Point> shapeToCoordinates(List<int> shape) {
  return shape.map((cellNum) {
    // cellNum va de 1 à 25 (grille 5×5)
    final index = cellNum - 1;  // 0 à 24
    final x = index % 5;
    final y = index ~/ 5;
    return Point(x, y);
  }).toList();
}
```

---

## 🔧 Cas particuliers

### 1. Double-tap pour rotation

**Code** : `DraggablePieceWidget`
```dart
GestureDetector(
  onDoubleTap: () {
    // Changer l'orientation
    ref.read(pentominoGameProvider.notifier).cycleOrientation();
    HapticFeedback.selectionClick();
  },
  // ...
)
```

**Provider** :
```dart
void cycleOrientation() {
  if (state.selectedPiece == null) return;

  final piece = state.availablePieces[state.selectedPiece!];
  final currentOrientation = state.selectedOrientation;
  final newOrientation = (currentOrientation + 1) % piece.numOrientations;

  final newOrientations = Map<int, int>.from(state.pieceOrientations);
  newOrientations[state.selectedPiece!] = newOrientation;

  state = state.copyWith(
    selectedOrientation: newOrientation,
    pieceOrientations: newOrientations,
  );
}
```

---

### 2. Déplacement d'une pièce déjà placée

**Code** : `GameBoard`
```dart
// Tap sur une pièce placée
GestureDetector(
  onTap: () {
    final placedIndex = _getPlacedPieceAt(gridX, gridY);
    if (placedIndex != null) {
      ref.read(pentominoGameProvider.notifier)
          .selectPlacedPiece(placedIndex);
    }
  },
  // ...
)
```

**Provider** :
```dart
void selectPlacedPiece(int? index) {
  state = state.copyWith(
    selectedPlacedPiece: index,
    selectedPiece: null,  // Désélectionner pièce du slider
  );
}
```

**Drag de la pièce placée** :
```dart
Draggable<DragData>(
  data: DragData(
    pieceIndex: placed.piece.id - 1,
    orientation: placed.positionIndex,
  ),
  onDragStarted: () {
    // Retirer temporairement la pièce
    ref.read(pentominoGameProvider.notifier)
        .removePlacedPiece(placedIndex);
  },
  // ... même logique que pièce du slider
)
```

---

### 3. Long-press pour supprimer

**Code** : `GameBoard`
```dart
GestureDetector(
  onLongPress: () {
    final placedIndex = _getPlacedPieceAt(gridX, gridY);
    if (placedIndex != null) {
      ref.read(pentominoGameProvider.notifier)
          .removePlacedPiece(placedIndex);
      HapticFeedback.heavyImpact();
    }
  },
  // ...
)
```

**Provider** :
```dart
void removePlacedPiece(int index) {
  if (index < 0 || index >= state.placedPieces.length) return;

  final newHistory = List<PentominoGameState>.from(state.history)
    ..add(state);

  final newPlacedPieces = List<PlacedPiece>.from(state.placedPieces)
    ..removeAt(index);

  state = state.copyWith(
    placedPieces: newPlacedPieces,
    selectedPlacedPiece: null,
    history: newHistory,
  );
}
```

---

### 4. Undo

**Code** : Bouton Undo
```dart
IconButton(
  icon: Icon(Icons.undo),
  onPressed: state.history.isNotEmpty
      ? () => ref.read(pentominoGameProvider.notifier).undo()
      : null,
)
```

**Provider** :
```dart
void undo() {
  if (state.history.isEmpty) return;

  final previousState = state.history.last;
  final newHistory = List<PentominoGameState>.from(state.history)
    ..removeLast();

  state = previousState.copyWith(history: newHistory);
  HapticFeedback.selectionClick();
}
```

---

### 5. Scroll infini du slider

**Code** : `PieceSlider`
```dart
ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: null,  // Infini
  itemBuilder: (context, index) {
    final pieceIndex = index % availablePieces.length;
    final piece = availablePieces[pieceIndex];
    
    return DraggablePieceWidget(
      piece: piece,
      pieceIndex: pieceIndex,
      // ...
    );
  },
)
```

---

## 📊 Diagramme de séquence complet

```
User          DraggablePW    Provider       State          GameBoard
 │                │             │             │                │
 │ Tap pièce      │             │             │                │
 ├───────────────>│             │             │                │
 │                │ selectPiece()             │                │
 │                ├────────────>│             │                │
 │                │             │ copyWith()  │                │
 │                │             ├────────────>│                │
 │                │             │<────────────┤                │
 │                │<────────────┤ selectedPiece=5              │
 │                │             │             │                │
 │ Drag start     │             │             │                │
 ├───────────────>│             │             │                │
 │                │ onDragStarted()           │                │
 │                ├────────────>│             │                │
 │                │ Haptic      │             │                │
 │                │             │             │                │
 │ Drag over board│             │             │                │
 ├────────────────┼─────────────┼─────────────┼───────────────>│
 │                │             │             │ onWillAccept() │
 │                │             │             │ calcul gridX/Y │
 │                │             │ updatePreview(2,3)           │
 │                │             │<────────────┼────────────────┤
 │                │             │ canPlace?   │                │
 │                │             ├────────────>│                │
 │                │             │<────────────┤ true           │
 │                │             │ copyWith()  │                │
 │                │             ├────────────>│                │
 │                │             │<────────────┤ preview set    │
 │                │             │             │ rebuild        │
 │                │             │             ├───────────────>│
 │                │             │             │ draw preview   │
 │                │             │             │                │
 │ Drop           │             │             │                │
 ├────────────────┼─────────────┼─────────────┼───────────────>│
 │                │             │             │ onAccept()     │
 │                │             │ tryPlacePiece(2,3)           │
 │                │             │<────────────┼────────────────┤
 │                │             │ canPlace?   │                │
 │                │             ├────────────>│                │
 │                │             │<────────────┤ true           │
 │                │             │ copyWith()  │                │
 │                │             ├────────────>│                │
 │                │             │<────────────┤ piece placed   │
 │                │             │ Haptic      │                │
 │                │             │             │ rebuild        │
 │                │             │             ├───────────────>│
 │                │             │             │ draw piece     │
 │<───────────────┴─────────────┴─────────────┴────────────────┤
 │ Pièce placée ✅                                              │
```

---

## 🎯 Points clés à retenir

### 1. Trois systèmes de coordonnées
- **Shape** : Grille 5×5 de la pièce (1-25)
- **Relative** : Origine au coin de la pièce (0,0)
- **Absolute** : Position sur le plateau (gridX, gridY)

### 2. Cellule de référence
- Toujours le coin supérieur gauche de la pièce
- Calculée à la sélection
- Utilisée pour tous les placements

### 3. Preview en temps réel
- Calculé pendant `onWillAccept`
- Vert = valide, Rouge = invalide
- Efface sur `onLeave`

### 4. Validation stricte
- Limites du plateau
- Cases cachées
- Cases occupées
- Collisions avec pièces placées

### 5. Haptic feedback
- Selection : `selectionClick()`
- Placement réussi : `mediumImpact()`
- Placement échoué : `heavyImpact()`
- Victoire : `heavyImpact()`

### 6. Historique pour undo
- Chaque placement sauvegarde l'état précédent
- `undo()` restaure le dernier état
- Historique limité en mémoire

---

## 🔗 Fichiers concernés

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `draggable_piece_widget.dart` | 134 | Drag & drop |
| `game_board.dart` | 388 | DragTarget + plateau |
| `piece_slider.dart` | 176 | Liste pièces |
| `piece_renderer.dart` | 108 | Affichage pièce |
| `pentomino_game_provider.dart` | 1578 | Logique métier |
| `pentomino_game_state.dart` | 240 | État du jeu |
| `game_piece.dart` | 74 | Utilitaires pièce |

---

**Dernière mise à jour** : 1er décembre 2025 à 01:30  
**Auteur** : Documentation générée avec Claude Sonnet 4.5

---

**📌 Note** : Ce mémo décrit le système actuel. Pour les évolutions futures (animations, physique, etc.), consulter les issues GitHub.

