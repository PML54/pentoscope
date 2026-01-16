================================================================================
MÉMO: ARCHITECTURE GESTION DES PIÈCES (Slider + Plateau)
Réutilisable pour plusieurs modules et apps
================================================================================

Date: 2025-12-14
Basé sur: Isopento + Pentoscope (fonctionnels)
Objectif: Documenter les patterns pour réutilisation (Classical, Duel, etc.)

================================================================================
PARTIE 1: ARCHITECTURE GÉNÉRALE
================================================================================

### 1.1 Structure de base (Provider + State)

```
Provider:
├── State (read-only data)
│   ├── selectedPiece (pièce du slider sélectionnée)
│   ├── selectedPlacedPiece (pièce du plateau sélectionnée)
│   ├── selectedPositionIndex (orientation actuelle)
│   ├── plateau (grille logique du jeu)
│   ├── placedPieces (liste des pièces placées)
│   └── piecePositionIndices (cache: pieceId → positionIndex)
│
├── Notifier (mutations)
│   ├── selectPiece(Pento piece) → cherche le slider
│   ├── selectPlacedPiece(PlacedPiece, x, y) → cherche le plateau
│   ├── cancelSelection() → désélectionne
│   ├── tryPlacePiece(gridX, gridY) → valide + place
│   ├── removePlacedPiece(PlacedPiece) → retire du plateau
│   └── Isométries: delegateIsometryRotationTW/CW, delegateIsometrySymmetryH/V
│
└── Services (logique réutilisable)
    └── IsometryService (transformations géométriques)
```

### 1.2 Points clés d'architecture

✅ **State immutable** → copyWith() pour mutations
✅ **Séparation logique slider vs plateau** → selectPiece() vs selectPlacedPiece()
✅ **Plateau = source de vérité** → synchro strict entre placedPieces et plateau
✅ **Callbacks dans isometries** → service générique, state update spécifique
✅ **Cache piecePositionIndices** → rapide, O(1) lookup par pieceId

================================================================================
PARTIE 2: GESTION DU SLIDER (PORTRAIT + PAYSAGE)
================================================================================

### 2.1 Affichage visuel en paysage (CLEF!)

**Le problème:** En paysage, le plateau est rotationné -90°
- Donc les pièces du slider doivent aussi afficher à -90° pour être cohérentes
- MAIS logiquement elles sont toujours au même index

**Solution:** `displayPositionIndex` != `positionIndex`

```dart
// Dans pentoscope_piece_slider.dart (applicable à tous)

int _getDisplayPositionIndex(int positionIndex, Pento piece, bool isLandscape) {
  if (isLandscape) {
    return (positionIndex - 1 + piece.numOrientations) % piece.numOrientations;
  }
  return positionIndex;
}

// Utilisation:
int displayPositionIndex = _getDisplayPositionIndex(positionIndex, piece, isLandscape);

// Dans le widget draggable:
positionIndex: displayPositionIndex,          // ✅ Pour l'affichage
selectedPositionIndex: isSelected 
    ? displayPositionIndex 
    : state.selectedPositionIndex,            // ✅ Cohérent avec affichage
```

**Point critique:** Si tu passes `positionIndex` logique au PieceRenderer en paysage,
il affichera mal, et les gestes/feedback seront incohérents.

### 2.2 Sélection d'une pièce du slider

```dart
void selectPiece(Pento piece) {
  final positionIndex = state.getPiecePositionIndex(piece.id);  // Cache
  final defaultCell = _calculateDefaultCell(piece, positionIndex);

  state = state.copyWith(
    selectedPiece: piece,
    selectedPositionIndex: positionIndex,
    clearSelectedPlacedPiece: true,            // ✅ Clear pièce placée si une était sélectionnée
    selectedCellInPiece: defaultCell,
  );
}
```

**Point critique:** Quand on sélectionne du slider, il faut:
- Garder le plateau COMPLET (pas enlever la pièce)
- Déselectionner la pièce placée si une était active

### 2.3 Isométries sur pièce slider

```dart
void delegateIsometrySymmetryH({bool isLandscape = false}) {
  if (state.selectedPiece == null) return;
  
  if (isLandscape) {
    _applySliderPieceSymmetryV();  // ✅ SWAP en paysage!
  } else {
    _applySliderPieceSymmetryH();
  }
}

void _applySliderPieceSymmetryH() {
  final piece = state.selectedPiece!;
  final currentIndex = state.selectedPositionIndex;
  final currentCoords = piece.cartesianCoords[currentIndex];
  
  final refX = (state.selectedCellInPiece?.x ?? 0);
  final flippedCoords = flipHorizontal(currentCoords, refX);  // ✅ Pas flipVertical!
  
  final match = recognizeShape(flippedCoords);
  if (match == null || match.piece.id != piece.id) return;
  
  final newIndices = Map<int, int>.from(state.piecePositionIndices);
  newIndices[piece.id] = match.positionIndex;
  final newCell = _calculateDefaultCell(piece, match.positionIndex);
  
  state = state.copyWith(
    selectedPositionIndex: match.positionIndex,
    piecePositionIndices: newIndices,
    selectedCellInPiece: newCell,
    isometryCount: state.isometryCount + 1,
  );
}
```

**Point critique:**
- Slider n'affecte PAS le plateau, juste l'index d'orientation
- En paysage, H/V doivent être SWAPPÉS au niveau du Notifier (pas du service)

================================================================================
PARTIE 3: GESTION DU PLATEAU
================================================================================

### 3.1 Plateau = source de vérité

Le plateau doit **TOUJOURS** être synchro avec `placedPieces`:

```dart
// Synchro correcte:
final newPlateau = Plateau.allVisible(width, height);
for (final p in state.placedPieces) {
  for (final cell in p.absoluteCells) {
    newPlateau.setCell(cell.x, cell.y, p.piece.id);
  }
}
state = state.copyWith(plateau: newPlateau, placedPieces: newPlaced);
```

### 3.2 Sélectionner une pièce placée

```dart
void selectPlacedPiece(PlacedPiece placed, int absoluteX, int absoluteY) {
  final localX = absoluteX - placed.gridX;
  final localY = absoluteY - placed.gridY;

  // ✅ Reconstruire le plateau SANS la pièce sélectionnée
  // (pour permettre le déplacement)
  final newPlateau = Plateau.allVisible(state.plateau.width, state.plateau.height);
  for (final p in state.placedPieces) {
    if (p.piece.id == placed.piece.id) continue;  // ✅ SKIP
    for (final cell in p.absoluteCells) {
      newPlateau.setCell(cell.x, cell.y, p.piece.id);
    }
  }

  state = state.copyWith(
    plateau: newPlateau,
    selectedPiece: placed.piece,
    selectedPlacedPiece: placed,
    selectedPositionIndex: placed.positionIndex,
    selectedCellInPiece: Point(localX, localY),
    clearPreview: true,
  );
}
```

**Point critique:** Quand une pièce placée est sélectionnée, elle doit être
RETIRÉE du plateau pour permettre le drag.

### 3.3 Placer une pièce

```dart
bool tryPlacePiece(int gridX, int gridY) {
  final selectedPiece = state.selectedPiece;
  if (selectedPiece == null) return false;

  if (!state.canPlacePiece(selectedPiece, state.selectedPositionIndex, gridX, gridY)) {
    return false;
  }

  final placed = PlacedPiece(...);
  
  // Reconstruire plateau
  final newPlateau = Plateau.allVisible(state.plateau.width, state.plateau.height);
  
  // Ajouter la NOUVELLE pièce
  for (final cell in placed.absoluteCells) {
    newPlateau.setCell(cell.x, cell.y, selectedPiece.id);
  }
  
  // Ajouter les AUTRES pièces (SKIP si on remplace)
  for (final p in state.placedPieces) {
    if (state.selectedPlacedPiece != null && 
        p.piece.id == state.selectedPlacedPiece!.piece.id) {
      continue;  // ✅ Ne pas re-ajouter la pièce qu'on déplace
    }
    for (final cell in p.absoluteCells) {
      newPlateau.setCell(cell.x, cell.y, p.piece.id);
    }
  }

  // Mettre à jour placedPieces (REMPLACER ou AJOUTER)
  final newPlaced = state.selectedPlacedPiece != null
      ? state.placedPieces
          .map((p) => p.piece.id == state.selectedPlacedPiece!.piece.id ? placed : p)
          .toList()
      : [...state.placedPieces, placed];

  state = state.copyWith(
    plateau: newPlateau,
    placedPieces: newPlaced,
    availablePieces: state.availablePieces.where((p) => p.id != selectedPiece.id).toList(),
    clearSelectedPiece: true,
    clearSelectedPlacedPiece: true,
    clearPreview: true,
  );

  return true;
}
```

**Point critique:**
- Distinguer REMPLACER (pièce sélectionnée existante) vs AJOUTER (pièce neuve)
- Ne pas oublier de SKIP la pièce qu'on remplace

### 3.4 Restaurer le plateau complet

Quand on sélectionne une nouvelle pièce du slider:

```dart
void selectPiece(Pento piece) {
  // ... calculs ...
  
  // ✅ Restaurer le plateau COMPLET
  final newPlateau = Plateau.allVisible(state.plateau.width, state.plateau.height);
  for (final p in state.placedPieces) {
    for (final cell in p.absoluteCells) {
      newPlateau.setCell(cell.x, cell.y, p.piece.id);
    }
  }

  state = state.copyWith(
    plateau: newPlateau,  // ✅ Important!
    selectedPiece: piece,
    // ...
  );
}
```

================================================================================
PARTIE 4: ISOMÉTRIES (Rotations + Symétries)
================================================================================

### 4.1 Architecture IsometryService (réutilisable)

```dart
class IsometryService {
  // Méthodes GÉNÉRIQUES (prennent callbacks)
  void applyPlacedPieceTransform({
    required PlacedPiece selectedPiece,
    required List<List<int>> Function(...) transform,
    required Function(PlacedPiece, List<PlacedPiece>, Point) onSuccess,
    Function()? onFailure,
  }) {
    // Logique pure: extraire coords, transformer, reconnaître, valider
    // Puis: onSuccess(newPiece, newPlaced, newCell)
  }

  void applySliderPieceTransform({
    required Pento selectedPiece,
    required int currentPositionIndex,
    required List<List<int>> Function(...) transform,
    required Function(int newIndex, Point? newCell) onSuccess,
    Function()? onFailure,
  }) {
    // Même pattern
  }

  void applyPlacedPieceSymmetryH({...}) {
    applyPlacedPieceTransform(
      transform: (coords, cx, cy) => flipHorizontal(coords, cy),
      onSuccess: onSuccess,
    );
  }
}
```

**Avantage:** Le service ne connaît PAS Riverpod, aucune dépendance état.
Il prend des données EN ENTRÉE et appelle des callbacks EN SORTIE.

### 4.2 Utilisation dans le Notifier

```dart
void delegateIsometryRotationTW() {
  if (state.selectedPlacedPiece != null) {
    _isometryService.applyPlacedPieceTransform(
      selectedPiece: state.selectedPlacedPiece!,
      transform: (coords, cx, cy) => rotateAroundPoint(coords, cx, cy, 1),
      onSuccess: (newPiece, newPlaced, newCell) {
        state = state.copyWith(
          placedPieces: newPlaced,
          selectedPlacedPiece: newPiece,
          isometryCount: state.isometryCount + 1,
        );
      },
    );
  } else if (state.selectedPiece != null) {
    _isometryService.applySliderPieceTransform(
      selectedPiece: state.selectedPiece!,
      transform: (coords, cx, cy) => rotateAroundPoint(coords, cx, cy, 1),
      onSuccess: (newIndex, newCell) {
        final newIndices = Map<int, int>.from(state.piecePositionIndices);
        newIndices[state.selectedPiece!.id] = newIndex;
        state = state.copyWith(
          selectedPositionIndex: newIndex,
          piecePositionIndices: newIndices,
        );
      },
    );
  }
}
```

### 4.3 Gestion H/V en paysage

```dart
void delegateIsometrySymmetryH({bool isLandscape = false}) {
  if (state.selectedPlacedPiece != null) {
    _isometryService.applyPlacedPieceSymmetryH(...);
  } else if (state.selectedPiece != null) {
    if (isLandscape) {
      _applySliderPieceSymmetryV();  // ✅ SWAP
    } else {
      _applySliderPieceSymmetryH();
    }
  }
}
```

**Point critique:** Le swap H/V doit être au niveau du **Notifier**, pas du service!
C'est un détail UI (paysage), pas de logique pure.

================================================================================
PARTIE 5: CHECKLIST DE RÉUTILISABILITÉ
================================================================================

Avant de l'adapter à un nouveau module, vérifier:

### Données
- [ ] State contient `selectedPiece` et `selectedPlacedPiece`?
- [ ] `piecePositionIndices` cache pour rapider lookup?
- [ ] `plateau` synchro strict avec `placedPieces`?
- [ ] `selectedPositionIndex` et `selectedCellInPiece` présents?

### Sélection
- [ ] `selectPiece()` restaure le plateau COMPLET?
- [ ] `selectPlacedPiece()` RETIRE la pièce du plateau?
- [ ] `cancelSelection()` restaure le plateau si pièce placée sélectionnée?

### Placement
- [ ] `tryPlacePiece()` distingue REMPLACER vs AJOUTER?
- [ ] `tryPlacePiece()` SKIPS la pièce sélectionnée lors de la synchro?
- [ ] `removePlacedPiece()` reconstruit le plateau?

### Isométries
- [ ] Service génériques avec callbacks?
- [ ] Notifier passe `isLandscape` aux méthodes?
- [ ] H/V swappés pour slider en paysage?
- [ ] Slider n'affecte QUE l'index, pas le plateau?

### UI (Slider)
- [ ] `displayPositionIndex` calculé en paysage?
- [ ] Passé au PieceRenderer ET DraggableWidget?
- [ ] Cohérence affichage/gestes?

================================================================================
PARTIE 6: EXEMPLE D'ADAPTATION À UN NOUVEAU MODULE (Classical)
================================================================================

```dart
// lib/classical/classical_provider.dart

class ClassicalState {
  // ✅ Garder la même structure
  final Pento? selectedPiece;
  final PlacedPiece? selectedPlacedPiece;
  final int selectedPositionIndex;
  final Map<int, int> piecePositionIndices;
  final Plateau plateau;
  final List<PlacedPiece> placedPieces;
  // + champs spécifiques ClassicalState (isometryCount, etc.)
}

class ClassicalNotifier extends Notifier<ClassicalState> {
  late final IsometryService _isometryService;

  // ✅ Copier les 4 méthodes de base (1 pour 1)
  void selectPiece(Pento piece) { ... }
  void selectPlacedPiece(PlacedPiece placed, ...) { ... }
  void cancelSelection() { ... }
  bool tryPlacePiece(int gridX, int gridY) { ... }

  // ✅ Copier les isométries
  void delegateIsometryRotationTW() { ... }
  void delegateIsometrySymmetryH({bool isLandscape = false}) { ... }
  // etc.

  // ❌ Ne PAS dupliquer les helpers privés
  // Utiliser _isometryService à la place
}
```

**Avantages:**
- Code boilerplate minimal
- Logic métier dans le service réutilisable
- Consistance entre modules

================================================================================
PARTIE 7: PIÈGES À ÉVITER
================================================================================

❌ **Ne pas sync plateau et placedPieces**
→ Affichage inévitablement cassé

❌ **Passer positionIndex au lieu de displayPositionIndex en paysage**
→ Gestes/feedback incohérents avec l'affichage

❌ **Oublier le SKIP dans tryPlacePiece()**
→ Doublon de pièces sur le plateau

❌ **Ne pas restaurer le plateau dans selectPiece()**
→ Pièces placées sélectionnées disparaissent

❌ **Ne pas passer isLandscape aux isométries slider**
→ H/V inversés en paysage

❌ **Appliquer les isométries slider au plateau**
→ Le plateau change, c'est faux (slider ≠ placement)

================================================================================
CONCLUSION
================================================================================

Clés de succès:
1. **Plateau = source de vérité** → synchro stricte
2. **Séparation slider vs plateau** → selectPiece() et selectPlacedPiece()
3. **displayPositionIndex en paysage** → cohérence affichage/gestes
4. **Service générique + callbacks** → réutilisable entre modules
5. **H/V swap au Notifier** → détail UI, pas logique pure

Réutilisabilité: ~80% du code est réutilisable 1 pour 1.
Seuls 20% sont spécifiques au module (générateur puzzle, règles, etc.)

================================================================================