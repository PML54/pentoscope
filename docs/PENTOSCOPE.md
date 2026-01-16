# Pentoscope - Documentation Technique

## Vue d'ensemble

**Pentoscope** est un mode de jeu de mini-puzzles pentominos à taille variable. Contrairement au mode Classical (plateau fixe 6×10, 12 pièces, 9356 solutions pré-calculées), Pentoscope génère dynamiquement des puzzles avec un nombre configurable de pièces (3 à 8) sur des plateaux de dimensions variables.

### Caractéristiques principales

- **Plateaux variables** : 3×5, 4×5, 5×5, 6×5, 7×5, 8×5
- **Génération dynamique** : Puzzles créés à la volée avec solveur backtracking optimisé
- **Niveaux de difficulté** : Facile (≥4 solutions), Aléatoire, Difficile (≤2 solutions)
- **Mode Training** : Option pour afficher la solution optimale
- **Score d'efficacité** : Note sur 20 basée sur le nombre d'isométries utilisées

---

## Architecture des fichiers

```
lib/pentoscope/
├── pentoscope_provider.dart      # State management (Riverpod Notifier)
├── pentoscope_generator.dart     # Génération de puzzles
├── pentoscope_solver.dart        # Solveur backtracking OPTIMISÉ
├── piece_difficulty.dart         # Classement difficulté des pièces
├── screens/
│   ├── pentoscope_menu_screen.dart   # Menu de configuration
│   └── pentoscope_game_screen.dart   # Écran de jeu
└── widgets/
    ├── pentoscope_board.dart         # Plateau de jeu
    └── pentoscope_piece_slider.dart  # Slider des pièces disponibles
```

---

## Composants principaux

### 1. PentoscopeGenerator (`pentoscope_generator.dart`)

Générateur de puzzles sans table pré-calculée. Utilise une approche "lazy" qui cherche des solutions en temps réel.

#### Tailles de plateau disponibles

| Enum | Dimensions | Pièces | Label |
|------|------------|--------|-------|
| `size3x5` | 3 col × 5 lignes | 3 | "3×5" |
| `size4x5` | 4 col × 5 lignes | 4 | "4×5" |
| `size5x5` | 5 col × 5 lignes | 5 | "5×5" |
| `size6x5` | 5 col × 6 lignes | 6 | "6×5" |
| `size7x5` | 5 col × 7 lignes | 7 | "7×5" |
| `size8x5` | 5 col × 8 lignes | 8 | "8×5" |

#### Méthodes de génération

```dart
// Génération aléatoire standard
Future<PentoscopePuzzle> generate(PentoscopeSize size)

// Génération facile (≥4 solutions)
Future<PentoscopePuzzle> generateEasy(PentoscopeSize size)

// Génération difficile (≤2 solutions)
Future<PentoscopePuzzle> generateHard(PentoscopeSize size)
```

#### Algorithme de génération

1. Sélectionner N pièces aléatoires parmi les 12 disponibles
2. Vérifier rapidement si au moins une solution existe (`findFirstSolution`)
3. Chercher toutes les solutions avec timeout de 2 secondes
4. Si aucune solution → retry avec d'autres pièces
5. Pour modes easy/hard : vérifier le nombre de solutions avant d'accepter

### 2. PentoscopeSolver (`pentoscope_solver.dart`)

Solveur par backtracking **optimisé** pour trouver les solutions d'un puzzle.

#### Optimisations implémentées

Le solveur utilise 3 techniques d'optimisation inspirées de `PentominoSolver` (utilisé pour générer les 9356 solutions du 6×10) :

| Technique | Description | Gain estimé |
|-----------|-------------|-------------|
| **Smallest Free Cell First** | Cible toujours la plus petite case libre (parcours ligne par ligne). Ne teste que les placements qui couvrent cette case. | **80-90%** réduction des tentatives |
| **Isolated Region Pruning** | Après chaque placement, analyse les régions vides via flood fill. Élimine les branches si région < 5 cases ou non-multiple de 5. | **50-70%** des branches mortes |
| **Piece Ordering** | Trie les pièces par `numOrientations` croissant. Les pièces les plus contraintes (moins d'orientations) sont essayées en premier. | **10-20%** supplémentaire |

#### Classes

```dart
/// Représente un placement de pièce dans une solution
class SolverPlacement {
  final int pieceId;        // ID de la pièce (1-12)
  final int gridX;          // Position X sur le plateau
  final int gridY;          // Position Y sur le plateau
  final int positionIndex;  // Index de la position/orientation
}

/// Alias pour une solution complète
typedef Solution = List<SolverPlacement>;

/// Résultat du solveur complet
class SolverResult {
  final int solutionCount;
  final List<Solution> solutions;
}
```

#### Méthodes publiques

```dart
// Trouve la première solution (rapide, s'arrête dès trouvée)
bool findFirstSolution(List<int> pieceIds, int width, int height)

// Trouve toutes les solutions (avec timeout)
Future<SolverResult> findAllSolutions(
  List<int> pieceIds,
  int width,
  int height,
  {Duration timeout = const Duration(seconds: 2)}
)
```

#### Méthodes d'optimisation internes

```dart
// Trouve la plus petite case libre (parcours y puis x)
int? _findSmallestFreeCell(List<List<int>> plateau, int width, int height)

// Trouve un placement valide qui couvre la case cible
(int, int)? _findPlacementCoveringCell(Pento, posIndex, targetX, targetY, ...)

// Vérifie que toutes les zones vides sont valides (≥5 et multiple de 5)
bool _areIsolatedRegionsValid(List<List<int>> plateau, int width, int height)

// Flood fill pour mesurer une région connexe
int _floodFill(int x, int y, plateau, visited, width, height)

// Trie les pièces par contrainte (numOrientations croissant)
List<int> _sortByConstraint(List<int> pieceIds)
```

### 3. PentoscopeProvider (`pentoscope_provider.dart`)

Gestionnaire d'état Riverpod pour le jeu Pentoscope.

#### État (PentoscopeState)

| Champ | Type | Description |
|-------|------|-------------|
| `puzzle` | `PentoscopePuzzle?` | Configuration du puzzle actuel |
| `plateau` | `Plateau` | Grille de jeu |
| `availablePieces` | `List<Pento>` | Pièces dans le slider |
| `placedPieces` | `List<PentoscopePlacedPiece>` | Pièces placées sur le plateau |
| `selectedPiece` | `Pento?` | Pièce sélectionnée (slider) |
| `selectedPlacedPiece` | `PentoscopePlacedPiece?` | Pièce placée sélectionnée |
| `selectedPositionIndex` | `int` | Index de rotation/orientation |
| `selectedCellInPiece` | `Point?` | Mastercase (point de référence drag) |
| `previewX`, `previewY` | `int?` | Position de la prévisualisation |
| `isPreviewValid` | `bool` | Preview valide (vert) ou non (rouge) |
| `validPlacements` | `List<Point>` | Positions valides pré-calculées |
| `isComplete` | `bool` | Puzzle terminé |
| `isometryCount` | `int` | Nombre d'isométries appliquées |
| `translationCount` | `int` | Nombre de translations |
| `score` | `int` | Score d'efficacité (0-20) |
| `showSolution` | `bool` | Mode training activé |
| `currentSolution` | `Solution?` | Solution affichée (training) |
| `viewOrientation` | `ViewOrientation` | Portrait ou Landscape |

#### Méthodes principales

```dart
// Démarrer un nouveau puzzle
Future<void> startPuzzle(
  PentoscopeSize size, {
  PentoscopeDifficulty difficulty = PentoscopeDifficulty.random,
  bool showSolution = false,
})

// Sélectionner une pièce du slider
void selectPiece(Pento piece)

// Sélectionner une pièce placée sur le plateau
void selectPlacedPiece(PentoscopePlacedPiece placed, int absoluteX, int absoluteY)

// Tenter de placer la pièce sélectionnée
bool tryPlacePiece(int gridX, int gridY)

// Retirer une pièce du plateau
void removePlacedPiece(PentoscopePlacedPiece placed)

// Annuler la sélection
void cancelSelection()

// Appliquer des isométries
void applyIsometryRotationCW()   // Rotation horaire
void applyIsometryRotationTW()   // Rotation anti-horaire
void applyIsometrySymmetryH()    // Symétrie horizontale
void applyIsometrySymmetryV()    // Symétrie verticale

// Cycle de rotation rapide
void cycleToNextOrientation()

// Mise à jour de la prévisualisation
void updatePreview(int gridX, int gridY)

// Réinitialiser avec nouveau puzzle
Future<void> reset()
```

### 4. PentoscopePlacedPiece

Représente une pièce placée sur le plateau Pentoscope.

```dart
class PentoscopePlacedPiece {
  final Pento piece;          // Référence à la pièce
  final int positionIndex;    // Index de position (rotation)
  final int gridX;            // Ancre X sur le plateau
  final int gridY;            // Ancre Y sur le plateau

  /// Coordonnées absolues des 5 cellules occupées (normalisées)
  Iterable<Point> get absoluteCells
}
```

---

## Fonctionnalités avancées

### Snapping intelligent

Quand l'utilisateur déplace une pièce, le système :

1. Pré-calcule **tous les placements valides** (`validPlacements`)
2. Trouve le placement le plus proche du doigt (`_findClosestValidPlacement`)
3. Affiche la preview en vert (valide) ou rouge (aucun placement possible)

### Calcul du score

Le score (0-20) mesure l'efficacité des isométries :

```dart
int _calculateScore(
  List<PentoscopePlacedPiece> placedPieces,
  Solution solution,
  int actualIsometries,
) {
  if (actualIsometries == 0) return 20;  // Parfait sans isométrie

  int totalMinIsometries = 0;
  for (final placed in placedPieces) {
    // Calculer le minimum d'isométries nécessaires
    final minIso = pento.minIsometriesToReach(initialPos, optimalPos);
    totalMinIsometries += minIso;
  }

  // Score = ratio optimal / réel × 20
  return ((totalMinIsometries / actualIsometries) * 20).round().clamp(0, 20);
}
```

### Mode Training

Quand `showSolution = true` :
- La solution optimale est affichée en transparence sur le plateau
- Les couleurs réelles des pièces sont utilisées
- Le score est calculé par rapport à cette solution

---

## Écrans

### PentoscopeMenuScreen

Menu de configuration avant de jouer :

- **Sélection de taille** : Boutons 3×5 à 8×5
- **Mode Training** : Switch pour afficher la solution
- **Bouton Jouer** : Lance le puzzle

### PentoscopeGameScreen

Écran de jeu principal :

- **AppBar** (portrait) : Bouton fermer, score (si terminé), boutons isométrie
- **Plateau** : Zone de jeu avec drag & drop
- **Slider** : Pièces disponibles (horizontal en portrait, vertical en paysage)
- **Actions contextuelles** : Isométries visibles uniquement si pièce sélectionnée

---

## Widgets

### PentoscopeBoard

Plateau de jeu avec support :
- Rotation portrait/paysage automatique
- Drag & drop avec prévisualisation
- Détection de la mastercase
- Bordures fusionnées entre cellules adjacentes

### PentoscopePieceSlider

Slider de pièces avec :
- Pièces centrées dans leur container de sélection
- Pièces agrandies (scale 1.5x) pour meilleure visibilité
- Rotation visuelle en mode paysage (-90°)
- Pièces draggables avec feedback visuel
- Surbrillance ambre pour la pièce sélectionnée
- Support du DragTarget pour retirer des pièces (drag vers slider)

---

## Différences avec Classical

| Aspect | Classical | Pentoscope |
|--------|-----------|------------|
| Plateau | Fixe 6×10 | Variable (3×5 à 8×5) |
| Pièces | 12 | 3 à 8 |
| Solutions | 9356 pré-calculées | Générées dynamiquement |
| Solveur | BigInt matching | Backtracking optimisé |
| Optimisations | N/A (lookup) | Smallest Cell First + Pruning |
| Score | Basé sur le temps | Basé sur efficacité isométries |
| Hint | Via `SolutionMatcher` | Non disponible |
| Timer | Oui | Non |
| Sauvegarde DB | Oui (`GameSessions`) | Non |

---

## Comparaison des solveurs

### Avant optimisation (naïf)

```
Approche : Triple boucle (posIndex → gridY → gridX)
Problème : Teste toutes les positions même impossibles
Performance : Lent pour puzzles > 5 pièces
```

### Après optimisation

```
Approche : Smallest Free Cell First + Pruning
Avantages :
  - Ne teste que les placements couvrant la case cible
  - Élimine les branches mortes (zones isolées)
  - Pièces contraintes en premier
Performance : 80-95% plus rapide
```
