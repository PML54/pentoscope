# Mémo : Gestion des déplacements de pièces dans Pentoscope

## Vue d'ensemble

Le système de déplacement utilise un mécanisme de **drag & drop** avec **snapping** vers les positions valides pré-calculées.

---

## Concepts clés

### 1. Mastercase (`selectedCellInPiece`)
- La cellule de la pièce sur laquelle l'utilisateur a cliqué/touché
- Sert de "point d'accroche" pour le drag
- Exprimée en coordonnées **locales normalisées** (relative à l'ancre de la pièce)

### 2. Ancre (`gridX`, `gridY`)
- Position de référence de la pièce sur le plateau
- Correspond au coin supérieur-gauche de la **bounding box normalisée** de la pièce
- Les cellules de la pièce sont calculées comme `ancre + offset_local`

### 3. Positions valides (`validPlacements`)
- Liste de `Point(gridX, gridY)` où la pièce peut être placée
- Pré-calculée au moment de la **sélection** de la pièce
- Mise à jour après chaque **isométrie** (rotation/symétrie)

### 4. Normalisation
- Chaque forme de pièce (positionIndex) a des cellules normalisées
- Le `minLocalX` et `minLocalY` sont soustraits pour que l'ancre soit toujours à (0,0) ou positif
- Calculé dans `absoluteCells` et `canPlacePiece`

---

## Flux de déplacement

### A. Sélection d'une pièce du SLIDER

```
┌─────────────────────────────────────────────────────────────────┐
│  1. User clique sur pièce dans slider                          │
│     ↓                                                           │
│  2. selectPiece(piece)                                          │
│     ├─ Récupère positionIndex depuis piecePositionIndices       │
│     ├─ Calcule defaultCell (mastercase par défaut)              │
│     ├─ Reconstruit le plateau (toutes les pièces placées)       │
│     └─ Génère validPlacements via _generateValidPlacements()    │
│     ↓                                                           │
│  3. User commence à dragger                                     │
│     ↓                                                           │
│  4. DragTarget.onMove → notifier.updatePreview(logicalX, Y)     │
│     ├─ Si validPlacements vide → preview rouge                  │
│     └─ Sinon → _findClosestValidPlacement() → preview vert      │
│     ↓                                                           │
│  5. User lâche (drop)                                           │
│     ↓                                                           │
│  6. DragTarget.onAcceptWithDetails                              │
│     ├─ Récupère previewX/Y (position snappée)                   │
│     ├─ Reconstruit doigt = ancre + mastercase                   │
│     └─ Appelle tryPlacePiece(reconstructedX, Y)                 │
│     ↓                                                           │
│  7. tryPlacePiece()                                             │
│     ├─ Calcule anchorX = doigt - mastercase                     │
│     ├─ Vérifie canPlacePiece()                                  │
│     ├─ Crée PentoscopePlacedPiece                               │
│     ├─ Met à jour plateau, placedPieces, availablePieces        │
│     └─ Vérifie isComplete                                       │
└─────────────────────────────────────────────────────────────────┘
```

### B. Sélection d'une pièce PLACÉE sur le plateau

```
┌─────────────────────────────────────────────────────────────────┐
│  1. User clique sur cellule du plateau occupée                  │
│     ↓                                                           │
│  2. Board détecte via getPlacedPieceAt(x, y)                    │
│     ↓                                                           │
│  3. selectPlacedPiece(placed, absoluteX, absoluteY)             │
│     ├─ Calcule mastercase: localX = absoluteX - placed.gridX   │
│     ├─ Retire la pièce du plateau temporairement                │
│     ├─ Génère validPlacements (sans la pièce)                   │
│     └─ EXCLUT la position actuelle (évite snap retour)          │
│     ↓                                                           │
│  4. User drag/isométrie/drop (même flux que slider)             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Fonctions principales

### Provider (`pentoscope_provider.dart`)

| Fonction | Rôle |
|----------|------|
| `selectPiece(piece)` | Sélectionne une pièce du slider, génère validPlacements |
| `selectPlacedPiece(placed, x, y)` | Sélectionne une pièce sur le plateau avec mastercase |
| `updatePreview(gridX, gridY)` | Met à jour le preview pendant le drag (snapping) |
| `tryPlacePiece(gridX, gridY)` | Tente de placer la pièce, retourne succès/échec |
| `cancelSelection()` | Annule la sélection, remet la pièce sur le plateau |
| `removePlacedPiece(placed)` | Retire une pièce et la remet dans le slider |
| `_generateValidPlacements(piece, posIdx)` | Génère toutes les positions d'ancre valides |
| `_findClosestValidPlacement(dragX, dragY)` | Trouve la position valide la plus proche |
| `_calculateDefaultCell(piece, posIdx)` | Calcule la mastercase par défaut |

### State (`PentoscopeState`)

| Champ | Type | Description |
|-------|------|-------------|
| `selectedPiece` | `Pento?` | Pièce actuellement sélectionnée |
| `selectedPlacedPiece` | `PentoscopePlacedPiece?` | Si pièce vient du plateau |
| `selectedPositionIndex` | `int` | Orientation actuelle de la pièce |
| `selectedCellInPiece` | `Point?` | Mastercase (cellule cliquée) |
| `validPlacements` | `List<Point>` | Positions d'ancre valides |
| `previewX`, `previewY` | `int?` | Position du preview actuel |
| `isPreviewValid` | `bool` | Vert (true) ou Rouge (false) |

### Widget Board (`pentoscope_board.dart`)

| Callback | Quand | Action |
|----------|-------|--------|
| `onMove` | Pendant drag | `notifier.updatePreview(logicalX, logicalY)` |
| `onLeave` | Quitte zone | `notifier.clearPreview()` |
| `onAcceptWithDetails` | Drop | `notifier.tryPlacePiece(...)` |

---

## Calcul des positions valides

```dart
List<Point> _generateValidPlacements(Pento piece, int positionIndex) {
  // 1. Calculer les offsets de la forme normalisée
  // 2. Balayer de (-maxOffsetX, -maxOffsetY) à (width, height)
  //    → Permet ancres négatives pour pièces aux bords
  // 3. Pour chaque position, tester canPlacePiece()
  // 4. Retourner liste des positions valides
}
```

## Snapping vers position valide

```dart
Point? _findClosestValidPlacement(int dragGridX, int dragGridY) {
  // 1. Calculer l'ancre théorique: 
  //    theoreticalAnchor = doigt - mastercase
  // 2. Parcourir validPlacements
  // 3. Trouver celle avec distance minimale à l'ancre théorique
  // 4. Retourner cette position
}
```

---

## Diagramme des coordonnées

```
┌────────────────────────────────────────┐
│  Plateau (ex: 5x5)                     │
│  ┌───┬───┬───┬───┬───┐                 │
│  │0,0│1,0│2,0│3,0│4,0│ ← gridY = 0     │
│  ├───┼───┼───┼───┼───┤                 │
│  │0,1│1,1│2,1│3,1│4,1│                 │
│  ├───┼───┼───┼───┼───┤                 │
│  │   │ A │ B │   │   │ ← Pièce placée  │
│  ├───┼───┼───┼───┼───┤   ancre=(1,2)   │
│  │   │ C │ D │ E │   │   cells: A,B,C,D,E│
│  ├───┼───┼───┼───┼───┤                 │
│  │   │   │   │   │   │                 │
│  └───┴───┴───┴───┴───┘                 │
│    ↑                                   │
│  gridX                                 │
└────────────────────────────────────────┘

Mastercase: Si user clique sur D (2,3)
  → localX = 2 - 1 = 1
  → localY = 3 - 2 = 1
  → selectedCellInPiece = Point(1, 1)
```

---

## Bugs connus / Points d'attention

1. **Ancres négatives** : Certaines pièces asymétriques nécessitent une ancre négative pour être placées aux bords. Corrigé en étendant le balayage dans `_generateValidPlacements`.

2. **Exclusion position actuelle** : Pour les pièces placées, la position actuelle est exclue de `validPlacements` pour éviter que le snapping ramène toujours à la position d'origine.

3. **Ordre des mises à jour** : Le plateau doit être mis à jour AVANT de générer `validPlacements`, sinon l'ancien plateau est utilisé.

4. **Transformation plateau/écran** : En mode paysage, le plateau est visuellement pivoté. La conversion `visual → logical` se fait dans le board widget.

