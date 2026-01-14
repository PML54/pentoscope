# 📚 CURSORDOC - Documentation Technique Pentapol

**Application de puzzles pentominos en Flutter**

**Date de création : 14 novembre 2025**  
**Dernière mise à jour : 1er décembre 2025**

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Modèles de données](#modèles-de-données)
4. [Services](#services)
5. [Écrans](#écrans)
6. [Providers (Riverpod)](#providers-riverpod)
7. [Système de solutions](#système-de-solutions)
8. [Déplacement des pièces](#déplacement-des-pièces)
9. [Transformations avec mastercase fixe (Pentoscope)](#-transformations-avec-mastercase-fixe-pentoscope)
10. [Configuration](#configuration)

---

## 🎯 Vue d'ensemble

Pentapol est une application Flutter permettant de :
- Créer et éditer des plateaux de pentominos (grille 6×10)
- Résoudre automatiquement les puzzles
- Jouer interactivement avec drag & drop
- Naviguer dans une base de 2339 solutions canoniques (9356 avec transformations)

### Technologies principales
- **Flutter** : Framework UI
- **Riverpod** : Gestion d'état
- **Supabase** : Backend (mode Duel multijoueur)
- **BigInt** : Encodage solutions sur 360 bits (60 cases × 6 bits)
- **SQLite** : Base de données locale (via Drift)

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # Point d'entrée, pré-chargement solutions
├── bootstrap.dart               # Init Supabase
├── models/                      # Modèles de données
│   ├── pentominos.dart         # 12 pièces avec toutes rotations
│   ├── plateau.dart            # Grille de jeu 6×10
│   ├── bigint_plateau.dart     # Plateau encodé en BigInt
│   ├── game_piece.dart         # Pièce interactive
│   ├── game.dart               # État complet d'une partie
│   └── point.dart              # Coordonnées 2D
├── services/                    # Logique métier
│   ├── solution_matcher.dart           # Comparaison solutions BigInt
│   ├── pentapol_solutions_loader.dart  # Chargement .bin → BigInt
│   ├── plateau_solution_counter.dart   # Extension Plateau
│   └── pentomino_solver.dart          # Backtracking avec heuristiques
├── providers/                   # Gestion d'état Riverpod
│   ├── plateau_editor_provider.dart   # Logique éditeur
│   ├── plateau_editor_state.dart      # État éditeur
│   ├── pentomino_game_provider.dart   # Logique jeu
│   └── pentomino_game_state.dart      # État jeu
├── screens/                     # Interfaces utilisateur
│   ├── home_screen.dart               # Menu principal (nouveau)
│   ├── pentomino_game_screen.dart     # Jeu interactif
│   ├── pentomino_game/                # Structure modulaire ✅
│   │   ├── utils/                     # Utilitaires
│   │   │   ├── game_constants.dart    # Constantes du jeu
│   │   │   ├── game_colors.dart       # Palette de couleurs
│   │   │   └── game_utils.dart        # Export centralisé
│   │   └── widgets/                   # Widgets modulaires
│   │       ├── shared/                # Partagés entre modes
│   │       │   ├── piece_renderer.dart
│   │       │   ├── draggable_piece_widget.dart
│   │       │   ├── game_board.dart
│   │       │   └── action_slider.dart
│   │       └── game_mode/             # Mode jeu normal
│   │           └── piece_slider.dart
│   ├── solutions_browser_screen.dart  # Navigateur solutions
│   ├── solutions_viewer_screen.dart   # Visualisation solutions
│   ├── settings_screen.dart           # Paramètres
│   └── custom_colors_screen.dart      # Personnalisation couleurs
└── utils/                       # Utilitaires
    └── time_format.dart        # Formatage temps
```

---

## 📦 Modèles de données

### 1. `pentominos.dart` - Les 12 pièces

Définit les 12 pièces de pentomino avec toutes leurs rotations/symétries.

**Structure `Pento`** :
```dart
class Pento {
  final int id;              // 1-12
  final int size;            // Toujours 5 (pentomino)
  final int numPositions;    // 1-8 (selon symétries)
  final List<int> baseShape; // Forme de base (numéros 1-25 sur grille 5×5)
  final List<List<int>> positions; // Toutes rotations/symétries
  final int bit6;            // Code unique 6 bits (1-12)
}
```

**Ordre des pièces** (trié par nb de positions, pour optimiser le solver) :
- Pièce 1 : 1 position (croix symétrique)
- Pièce 12 : 2 positions (ligne droite)
- Pièces 3,6,7,10,11 : 4 positions
- Pièces 2,4,5,8,9 : 8 positions

**Utilisation** :
```dart
import 'package:pentapol/models/pentominos.dart';

// Liste globale des 12 pièces
final pieces = pentominos;

// Accéder à une pièce
final piece1 = pentominos[0]; // Pièce id=1
print('${piece1.numPositions} orientations'); // 1
```

---

### 2. `plateau.dart` - Grille de jeu

Représente une grille 6×10 (ou dimension variable).

**Structure `Plateau`** :
```dart
class Plateau {
  final int width;   // 6
  final int height;  // 10
  List<List<int>> grid; // -1=caché, 0=libre, 1-12=pièce
  
  // Factories
  Plateau.empty(int w, int h);       // Tout caché
  Plateau.allVisible(int w, int h);  // Tout visible
  
  // Méthodes
  int getCell(int x, int y);
  void setCell(int x, int y, int value);
  Plateau copy();
  int get numVisibleCells;
  int get numFreeCells;
}
```

**Utilisation** :
```dart
// Créer un plateau 6×10 vide
final plateau = Plateau.allVisible(6, 10);

// Modifier une case
plateau.setCell(0, 0, 1); // Place pièce 1 en (0,0)

// Compter cases libres
print('${plateau.numFreeCells} cases libres');
```

---

### 3. `bigint_plateau.dart` - Encodage BigInt

Version optimisée du plateau encodée sur 360 bits (60 cases × 6 bits).

**Structure `BigIntPlateau`** :
```dart
class BigIntPlateau {
  final BigInt pieces; // Codes bit6 de chaque case
  final BigInt mask;   // 0x3F si case occupée, 0 sinon
  
  // Factory
  factory BigIntPlateau.empty();
  
  // Méthodes
  BigIntPlateau placePiece({
    required int pieceId,
    required Iterable<int> cellIndices,
    required Map<int, int> bit6ById,
  });
  
  BigIntPlateau clearCells(Iterable<int> cellIndices);
  int getCell(int x, int y); // Retourne 0 ou 1-12
}
```

**Encodage** :
- Chaque case = 6 bits (codes 1-12 pour les pièces)
- Case 0 → bits 354-359
- Case 59 → bits 0-5
- Total : 360 bits (45 octets)

**Utilisation** :
```dart
final plateau = BigIntPlateau.empty();

// Placer une pièce sur les cases [0, 1, 6, 7, 12]
final updated = plateau.placePiece(
  pieceId: 1,
  cellIndices: [0, 1, 6, 7, 12],
  bit6ById: {for (var p in pentominos) p.id: p.bit6},
);

// Lire une case
final pieceId = updated.getCell(0, 0); // 1
```

---

### 4. `game_piece.dart` - Pièce interactive

Wrapper autour de `Pento` pour le jeu interactif.

**Structure `GamePiece`** :
```dart
class GamePiece {
  final Pento piece;
  final int currentOrientation;  // 0 à numPositions-1
  final bool isPlaced;
  final int? placedX, placedY;
  
  // Méthodes
  GamePiece rotate();
  GamePiece place(int x, int y);
  GamePiece unplace();
  List<Point> get currentCoordinates;
  List<Point>? get absoluteCoordinates;
}
```

---

### 5. `game.dart` - État complet d'une partie

**Structure `Game`** :
```dart
class Game {
  final Plateau plateau;
  final List<GamePiece> pieces;
  final DateTime createdAt;
  final int? seed;
  
  // Factory
  static Game create({
    required Plateau plateau,
    required List<int> pieceIds,
    int? seed,
  });
  
  // Méthodes
  bool get isCompleted;
  int get numPlacedPieces;
  bool canPlacePiece(int pieceIndex, int x, int y);
  Game? placePieceAt(int pieceIndex, int x, int y);
  Game? removePiece(int pieceIndex);
}
```

---

## ⚙️ Services

### 1. `solution_matcher.dart` - Comparaison solutions BigInt

Service central pour comparer un plateau avec les 2339 solutions canoniques.

**Classe `SolutionMatcher`** :
```dart
class SolutionMatcher {
  late final List<BigInt> _solutions; // ~9356 solutions
  
  // Initialisation (appelée au démarrage)
  void initWithBigIntSolutions(List<BigInt> canonicalSolutions);
  
  // Comptage
  int countCompatibleFromBigInts(BigInt piecesBits, BigInt maskBits);
  
  // Récupération
  List<BigInt> getCompatibleSolutionsFromBigInts(
    BigInt piecesBits, 
    BigInt maskBits,
  );
  
  // Propriétés
  int get totalSolutions; // ~9356
  List<BigInt> get allSolutions;
}

// Singleton global
final solutionMatcher = SolutionMatcher();
```

**Transformations générées** :
Pour chaque solution canonique (2339), on génère 4 variantes :
1. Identité
2. Rotation 180°
3. Miroir horizontal
4. Miroir vertical

Total : 2339 × 4 = 9356 solutions

**Comparaison** :
```dart
// Vérification compatibilité
bool _isCompatibleBigInt(BigInt piecesBits, BigInt maskBits, BigInt solution) {
  return (solution & maskBits) == piecesBits;
}
```

**Utilisation** :
```dart
// Dans main.dart, au démarrage
final solutions = await loadNormalizedSolutionsAsBigInt();
solutionMatcher.initWithBigIntSolutions(solutions);

// Compter solutions compatibles
final count = solutionMatcher.countCompatibleFromBigInts(
  piecesBits, 
  maskBits,
);
```

---

### 2. `pentapol_solutions_loader.dart` - Chargement binaire

Charge le fichier `assets/data/solutions_6x10_normalisees.bin`.

**Format du fichier** :
- 45 octets par solution (360 bits ÷ 8)
- 2339 solutions × 45 octets = 105 255 octets
- Encodage bit-packed 6 bits par case

**Fonction principale** :
```dart
Future<List<BigInt>> loadNormalizedSolutionsAsBigInt() async {
  final data = await rootBundle.load(
    'assets/data/solutions_6x10_normalisees.bin'
  );
  final bytes = data.buffer.asUint8List();
  
  // Décode chaque bloc de 45 octets en BigInt
  final solutions = <BigInt>[];
  // ... décodage
  return solutions;
}
```

**Utilisation** :
```dart
// Dans main.dart
final solutions = await loadNormalizedSolutionsAsBigInt();
print('${solutions.length} solutions chargées'); // 2339
```

---

### 3. `plateau_solution_counter.dart` - Extension Plateau

Ajoute des méthodes au `Plateau` pour compter les solutions.

**Extension** :
```dart
extension PlateauSolutionCounter on Plateau {
  // Compte les solutions compatibles
  int? countPossibleSolutions();
  
  // Récupère les solutions compatibles (BigInt)
  List<BigInt> getCompatibleSolutionsBigInt();
}
```

**Conversion interne** :
```dart
_PlateauBigIntMask _toBigIntMask() {
  // Convertit Plateau en (piecesBits, maskBits)
  BigInt piecesBits = BigInt.zero;
  BigInt maskBits = BigInt.zero;
  
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final cellValue = getCell(x, y); // 0 ou 1-12
      
      piecesBits = piecesBits << 6;
      maskBits = maskBits << 6;
      
      if (cellValue > 0) {
        final code = bit6ById[cellValue];
        piecesBits |= BigInt.from(code);
        maskBits |= BigInt.from(0x3F);
      }
    }
  }
  
  return _PlateauBigIntMask(piecesBits, maskBits);
}
```

**Utilisation** :
```dart
final plateau = Plateau.allVisible(6, 10);
plateau.setCell(0, 0, 1);
plateau.setCell(0, 1, 1);

// Compter solutions
final count = plateau.countPossibleSolutions();
print('$count solutions compatibles');

// Récupérer solutions
final solutions = plateau.getCompatibleSolutionsBigInt();
```

---

### 4. `pentomino_solver.dart` - Backtracking

Algorithme de résolution par backtracking avec heuristiques avancées.

**Structure `PlacementInfo`** :
```dart
class PlacementInfo {
  final int pieceIndex;
  final int orientation;
  final int targetCell;      // 1-60
  final int offsetX, offsetY;
  final List<int> occupiedCells;
}
```

**Classe `PentominoSolver`** :
```dart
class PentominoSolver {
  int maxSeconds = 30; // Timeout
  
  // Résolution
  List<PlacementInfo>? solve();
  List<PlacementInfo>? findNext(); // Solution suivante
  
  // Heuristiques
  bool areIsolatedRegionsValid();
  int findSmallestFreeCell();
  bool canPlaceWithOffset(...);
}
```

**Optimisations** :
1. **Timeout 30s** : Évite blocages infinis
2. **Détection zones isolées** : Élagage précoce
3. **Flood fill** : Détecte régions impossibles
4. **Ordre fixe des pièces** : Reproductibilité

**Utilisation** :
```dart
final solver = PentominoSolver();
final solution = solver.solve();

if (solution != null) {
  print('Solution trouvée en ${solution.length} placements');
  
  // Chercher solution suivante
  final next = solver.findNext();
}
```

---

## 📱 Écrans

### 1. `plateau_editor_screen.dart` - Éditeur de plateau

Interface pour créer et tester des plateaux personnalisés.

**Fonctionnalités** :
- ✅ Grille 6×10 interactive (tap pour toggle case)
- ✅ Slider nombre de pièces (1-12)
- ✅ Bouton "Valider" : teste toutes combinaisons
- ✅ Bouton "Suivante" : cherche solution alternative
- ✅ Affichage visuel de la solution (couleurs + numéros)
- ✅ Compteur "✓ N°1", "✓ N°2", etc.

**Composants** :
```dart
class PlateauEditorScreen extends ConsumerWidget {
  Widget _buildInfoPanel();        // Stats en haut
  Widget _buildPlateauGrid();      // Grille 6×10
  Widget _buildControlPanel();     // Slider + boutons
  Widget _CellWidget();            // Case individuelle
}
```

**États** :
- `idle` : Rien à afficher
- `solving` : Validation en cours
- `solved` : Solution trouvée
- `error` : Erreur (ex: pas de solution)

---

### 2. `pentomino_game_screen.dart` - Jeu interactif

Interface de jeu complète avec drag & drop.

**Fonctionnalités** :
- ✅ Drag & drop des pièces depuis slider
- ✅ Rotation (double-tap ou bouton)
- ✅ Placement avec validation visuelle
- ✅ Déplacement pièces déjà placées
- ✅ Retrait pièce (long-press)
- ✅ Undo/Reset
- ✅ Haptic feedback
- ✅ Scroll infini dans slider
- ✅ Message victoire

**Composants** :
```dart
class PentominoGameScreen extends ConsumerStatefulWidget {
  Widget _buildGameBoard();         // Plateau avec DragTarget
  Widget _buildPieceSlider();       // Slider horizontal pièces
  Widget _buildDraggablePiece();    // Pièce draggable
  Widget _DraggablePieceWidget();   // Gestion gestures
}
```

**Gestures** :
- **Tap** : Sélectionner pièce placée
- **Double-tap** : Rotation
- **Long-press** : Retrait ou drag depuis slider
- **Drag** : Déplacement avec preview

---

### 3. `solutions_browser_screen.dart` - Navigateur solutions

Affiche et navigue dans les solutions.

**Fonctionnalités** :
- ✅ Affichage grille 6×10 colorée
- ✅ Navigation flèches (← →)
- ✅ Compteur "X / Y"
- ✅ Boucle infinie
- ✅ Titre personnalisé (optionnel)

**Constructeurs** :
```dart
// Toutes les solutions
const SolutionsBrowserScreen();

// Solutions filtrées
SolutionsBrowserScreen.forSolutions(
  solutions: compatibleSolutions,
  title: 'Solutions compatibles',
);
```

**Utilisation** :
```dart
// Navigation vers navigateur
Navigator.push(context, MaterialPageRoute(
  builder: (_) => SolutionsBrowserScreen.forSolutions(
    solutions: plateau.getCompatibleSolutionsBigInt(),
    title: '$count solutions',
  ),
));
```

---

### 4. `home_screen.dart` - Menu principal (Nouveau)

Menu principal moderne avec accès aux différents modes :
- Jeu Classique
- Mode Duel (multijoueur temps réel)
- Solutions (navigateur)
- Tutoriels (à venir)
- Paramètres

---

## 🔄 Providers (Riverpod)

### 1. `plateau_editor_provider.dart` - Logique éditeur

**Notifier** :
```dart
class PlateauEditorNotifier extends Notifier<PlateauEditorState> {
  void toggleCell(int x, int y);
  void setNumPieces(int n);
  void reset();
  Future<void> validate();        // Teste toutes combinaisons
  Future<void> findNextSolution();
}

final plateauEditorProvider = NotifierProvider<
  PlateauEditorNotifier, 
  PlateauEditorState
>(PlateauEditorNotifier.new);
```

**Validation exhaustive** :
```dart
Future<void> validate() async {
  // Génère C(12, p) combinaisons de p pièces parmi 12
  final combinations = _generateCombinations(pieceIds, numPieces);
  
  // Teste chaque combinaison
  for (final combo in combinations) {
    final solver = PentominoSolver();
    final solution = solver.solve();
    if (solution != null) {
      // Solution trouvée !
      break;
    }
  }
}
```

---

### 2. `plateau_editor_state.dart` - État éditeur

**Structure** :
```dart
class PlateauEditorState {
  final Plateau plateau;
  final int numPieces;
  final bool isSolving;
  final bool? hasSolution;
  final String? errorMessage;
  final List<PlacementInfo>? solution;
  final PentominoSolver? solver;
  final List<int>? selectedPieces;
  final int solutionIndex;
  
  // Timestamp pour forcer rebuild Riverpod
  final int _timestamp;
  
  factory PlateauEditorState.initial();
  PlateauEditorState copyWith({...});
}
```

**Truc important** : Le `_timestamp` force Riverpod à détecter **toujours** un changement d'état, même si les autres champs sont identiques.

---

### 3. `pentomino_game_provider.dart` - Logique jeu

**Notifier** :
```dart
class PentominoGameNotifier extends Notifier<PentominoGameState> {
  void reset();
  void selectPiece(int pieceIndex);
  void cyclePosition();
  void tryPlacePiece(int gridX, int gridY, int cellX, int cellY);
  void cancelSelection();
  void selectPlacedPiece(int index);
  void removePlacedPiece(int index);
  void undoLastPlacement();
  void updatePreview(int? gridX, int? gridY);
  void clearPreview();
  int? getPlacedPieceAt(int gridX, int gridY);
}
```

**Système case de référence** :
```dart
void selectPiece(int pieceIndex) {
  // Définir case de référence (coin sup gauche)
  final shape = currentShape;
  final coords = GamePiece.shapeToCoordinates(shape);
  final minX = coords.map((p) => p.x).reduce(min);
  final minY = coords.map((p) => p.y).reduce(min);
  
  state = state.copyWith(
    selectedCellInPiece: Point(minX, minY),
  );
}
```

---

### 4. `pentomino_game_state.dart` - État jeu

**Structure** :
```dart
class PentominoGameState {
  final Plateau plateau;
  final List<Pento> availablePieces;
  final List<PlacedPiece> placedPieces;
  final int? selectedPieceIndex;
  final int selectedPositionIndex;
  final int? selectedPlacedPieceIndex;
  final Map<int, int> piecePositionIndices;
  final Point? selectedCellInPiece;
  final int? previewX, previewY;
  final bool isPreviewValid;
  
  factory PentominoGameState.initial();
  PentominoGameState copyWith({...});
  bool canPlacePiece(int pieceIndex, int gridX, int gridY);
}

class PlacedPiece {
  final Pento piece;
  final int positionIndex;
  final int gridX, gridY;
  
  List<Point> getOccupiedCells();
  PlacedPiece copyWith({...});
}
```

---

## 🎲 Système de solutions

### Architecture globale

```
┌─────────────────────────────────────────────────────────────┐
│                         DÉMARRAGE APP                        │
│                                                              │
│  1. loadNormalizedSolutionsAsBigInt()                       │
│     └─> Charge assets/data/solutions_6x10_normalisees.bin  │
│         └─> 2339 solutions canoniques (45 octets chacune)  │
│                                                              │
│  2. solutionMatcher.initWithBigIntSolutions(solutions)      │
│     └─> Génère 4 transformations par solution              │
│         ├─> Identité                                        │
│         ├─> Rotation 180°                                   │
│         ├─> Miroir horizontal                               │
│         └─> Miroir vertical                                 │
│     └─> Résultat : ~9356 solutions BigInt en mémoire       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    UTILISATION RUNTIME                       │
│                                                              │
│  Plateau.countPossibleSolutions()                           │
│    └─> Convertit Plateau en (piecesBits, maskBits)         │
│        └─> solutionMatcher.countCompatibleFromBigInts()    │
│            └─> Compare avec les 9356 solutions             │
│                ├─> (solution & mask) == pieces ?           │
│                └─> Retourne compteur                        │
│                                                              │
│  Plateau.getCompatibleSolutionsBigInt()                     │
│    └─> Récupère List<BigInt> des solutions compatibles     │
│        └─> Utilisé pour navigateur de solutions            │
└─────────────────────────────────────────────────────────────┘
```

### Format BigInt (360 bits)

```
┌────────────────────────────────────────────────┐
│  Grille 6×10 = 60 cases                       │
│  Chaque case = 6 bits (codes 1-12)           │
│  Total = 60 × 6 = 360 bits                    │
│                                                │
│  Case 0  (y=0, x=0) → bits 354-359           │
│  Case 1  (y=0, x=1) → bits 348-353           │
│  ...                                           │
│  Case 59 (y=9, x=5) → bits 0-5               │
│                                                │
│  BigInt construction :                         │
│    acc = BigInt.zero;                         │
│    for (code in codes_0_to_59) {             │
│      acc = (acc << 6) | BigInt.from(code);  │
│    }                                           │
└────────────────────────────────────────────────┘
```

### Codes bit6 des pièces

```dart
// Dans pentominos.dart
const pentominos = [
  Pento(id: 1, bit6: 1, ...),   // 0b000001
  Pento(id: 2, bit6: 2, ...),   // 0b000010
  Pento(id: 3, bit6: 3, ...),   // 0b000011
  // ...
  Pento(id: 12, bit6: 12, ...), // 0b001100
];
```

### Exemple de comparaison

```dart
// Plateau avec 2 pièces placées
Plateau plateau = ...;
plateau.setCell(0, 0, 1); // Pièce 1 en (0,0)
plateau.setCell(0, 1, 1); // Pièce 1 en (0,1)

// Conversion en BigInt
piecesBits = 0b000001_000001_000000_...  // 60 × 6 bits
maskBits   = 0b111111_111111_000000_...  // 0x3F pour cases occupées

// Comparaison avec une solution
solution = solutionMatcher.allSolutions[0];
isCompatible = (solution & maskBits) == piecesBits;
```

---

## 🎮 Déplacement des pièces

### Vue d'ensemble

Le système de déplacement des pièces du slider vers le plateau utilise le mécanisme **Drag & Drop** de Flutter avec une architecture en 3 couches :

1. **DraggablePieceWidget** : Gère le drag & drop
2. **GameBoard** : Plateau avec DragTarget
3. **PentominoGameProvider** : Logique métier et validation

### Flux simplifié

```
1. User TAP pièce → Sélection (selectedPiece = index)
2. User DRAG → Feedback visuel (pièce suit le doigt)
3. Survol plateau → Preview (vert=valide, rouge=invalide)
4. User DROP → Validation + Placement (ajout à placedPieces)
```

### Système de coordonnées

Le système utilise **3 types de coordonnées** :

- **Shape** : Grille 5×5 de la pièce (numéros 1-25)
- **Relative** : Origine au coin de la pièce (Point x,y)
- **Absolute** : Position sur le plateau (gridX, gridY)

**Cellule de référence** : Toujours le coin supérieur gauche de la pièce, calculée à la sélection.

### Validation du placement

```dart
bool canPlacePiece(int pieceIndex, int gridX, int gridY) {
  // Vérifications :
  // 1. Dans les limites du plateau
  // 2. Pas sur case cachée (-1)
  // 3. Pas sur case occupée
  // 4. Pas de collision avec pièces placées
  return true/false;
}
```

### Haptic feedback

- **Selection** : `selectionClick()`
- **Placement réussi** : `mediumImpact()`
- **Placement échoué** : `heavyImpact()`
- **Victoire** : `heavyImpact()`

### Composants clés

| Composant | Fichier | Lignes | Rôle |
|-----------|---------|--------|------|
| DraggablePieceWidget | `draggable_piece_widget.dart` | 134 | Drag & drop |
| GameBoard | `game_board.dart` | 388 | DragTarget + plateau |
| PieceSlider | `piece_slider.dart` | 176 | Liste pièces |
| PieceRenderer | `piece_renderer.dart` | 108 | Affichage pièce |

### Documentation complète

Pour les détails complets du mécanisme (diagrammes de séquence, code détaillé, cas particuliers), consulter **[MOVEPIECE.md](MOVEPIECE.md)**.

---

## 🔄 Transformations avec mastercase fixe (Pentoscope)

### Vue d'ensemble

Le mode Pentoscope implémente un système de transformations (rotations et symétries) où la **mastercase** (cellule sélectionnée par l'utilisateur) reste **fixe** à sa position absolue sur le plateau, même après transformation.

### Principe fondamental

**Mastercase** : Cellule d'une pièce placée sur le plateau désignée par l'utilisateur comme point de référence pour les transformations.

**Comportement attendu** :
- **Rotation** : La mastercase est le centre de rotation → elle reste fixe
- **Symétrie** : L'axe de symétrie passe par la mastercase → elle reste fixe

### Architecture

**Fichiers clés** :
- `lib/pentoscope/pentoscope_provider.dart` : Logique de transformation
- `lib/pentoscope/screens/pentoscope_game_screen.dart` : UI avec messages

**Enum `TransformationResult`** :
```dart
enum TransformationResult {
  success,      // Transformation réussie sans ajustement
  recentered,   // Transformation réussie avec recentrage
  impossible,   // Transformation impossible
}
```

### Système de coordonnées

Le système utilise **3 systèmes de coordonnées** :

1. **Coordonnées brutes** : Position dans la grille 5×5 (0-4, 0-4)
2. **Coordonnées normalisées** : Position relative dans la pièce (décalée pour commencer à 0,0)
3. **Coordonnées absolues** : Position sur le plateau 6×10 (gridX, gridY)

**Conversion** :
```dart
// Dans selectPlacedPiece : convertir coordonnées brutes → normalisées
final rawLocalX = absoluteX - placed.gridX;
final rawLocalY = absoluteY - placed.gridY;

// Trouver la cellule correspondante dans les coordonnées normalisées
final normalizedCoords = coords.map((p) => Point(p.x - minX, p.y - minY)).toList();
final mastercase = normalizedCoords[index];
```

### Calcul de position avec mastercase fixe

**Méthode `_calculatePositionForFixedMastercase`** :

```dart
Point _calculatePositionForFixedMastercase({
  required PentoscopePlacedPiece originalPiece,
  required PentoscopePlacedPiece transformedPiece,
  required Point mastercase, // Coordonnées normalisées
}) {
  // 1. Trouver le numéro de cellule correspondant à la mastercase
  final mastercaseIndex = normalizedOrigCoords.indexWhere(
    (p) => p.x == mastercase.x && p.y == mastercase.y
  );
  final mastercaseCellNum = originalPosition[mastercaseIndex];

  // 2. Trouver cette cellule dans la position transformée
  final cellIndexInTransformed = transformedPosition.indexOf(mastercaseCellNum);

  // 3. Calculer les coordonnées normalisées dans la nouvelle orientation
  final normalizedTransCoords = ...;
  final newMastercaseLocal = normalizedTransCoords[cellIndexInTransformed];

  // 4. Calculer gridX, gridY pour maintenir la position absolue
  final mastercaseAbsX = originalPiece.gridX + mastercase.x;
  final mastercaseAbsY = originalPiece.gridY + mastercase.y;
  
  final newLocalX = minXTrans + newMastercaseLocal.x;
  final newLocalY = minYTrans + newMastercaseLocal.y;
  
  final newGridX = mastercaseAbsX - newLocalX;
  final newGridY = mastercaseAbsY - newLocalY;

  return Point(newGridX, newGridY);
}
```

### Recherche de position valide

**Méthode `_findNearestValidPosition`** :

Si la transformation cause un chevauchement ou une sortie du plateau, le système recherche automatiquement la position valide la plus proche autour de la mastercase.

**Algorithme** :
1. Recherche en spirale autour de la position initiale (rayon max = 5 cases)
2. Teste chaque position candidate pour validité
3. Retourne la première position valide trouvée
4. Retourne `null` si aucune position valide n'est trouvée

```dart
Point? _findNearestValidPosition({
  required PentoscopePlacedPiece piece,
  required Point mastercaseAbs,
  required Point mastercaseLocal,
  int maxRadius = 5,
}) {
  // Recherche en spirale
  for (int radius = 0; radius <= maxRadius; radius++) {
    // Générer candidats à cette distance
    final candidates = ...;
    
    for (final candidate in candidates) {
      if (_canPlacePieceWithoutChecker(testPiece)) {
        return candidate;
      }
    }
  }
  return null; // Impossible
}
```

### Messages utilisateur

**Affichage des résultats** :

```dart
void _handleTransformationResult(BuildContext context, TransformationResult result) {
  switch (result) {
    case TransformationResult.success:
      // Pas de message
      break;
    case TransformationResult.recentered:
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recentrage'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      break;
    case TransformationResult.impossible:
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transformation impossible'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      break;
  }
}
```

### Flux de transformation

```
1. User sélectionne pièce placée → selectPlacedPiece()
   └─> Calcule mastercase en coordonnées normalisées
   
2. User clique bouton transformation → applyIsometryRotationCW/TW/SymmetryH/V()
   └─> _applyIsoUsingLookup()
       ├─> Change positionIndex (orientation)
       ├─> _calculatePositionForFixedMastercase()
       │   └─> Calcule gridX, gridY pour mastercase fixe
       ├─> Vérifie validité avec _canPlacePieceWithoutChecker()
       │   ├─> Si valide → TransformationResult.success
       │   └─> Si invalide → _findNearestValidPosition()
       │       ├─> Si trouvé → TransformationResult.recentered
       │       └─> Si null → TransformationResult.impossible
       └─> Met à jour selectedCellInPiece avec nouvelle position relative
```

### Points importants

1. **Coordonnées normalisées** : La mastercase doit toujours être stockée en coordonnées normalisées, pas en coordonnées brutes
2. **Mise à jour après transformation** : `selectedCellInPiece` doit être recalculé après chaque transformation pour suivre la mastercase
3. **Fallback** : Si la mastercase disparaît dans la nouvelle orientation, garder la position originale
4. **Recentrage automatique** : Si la transformation cause un conflit, chercher la position valide la plus proche

### Cas limites gérés

- ✅ Mastercase disparaît dans nouvelle orientation → Fallback position originale
- ✅ Pièce chevauche après transformation → Recentrage automatique
- ✅ Pièce sort du plateau → Recentrage automatique
- ✅ Aucune position valide trouvée → Message "Transformation impossible"

---

## ⚙️ Configuration

### `pubspec.yaml`

**Dépendances clés** :
```yaml
dependencies:
  flutter_riverpod: ^3.0.3  # Gestion d'état
  supabase_flutter: ^2.10.3 # Backend
  drift: ^2.29.0            # SQLite
  package_info_plus: ^9.0.0
  url_launcher: ^6.3.2
  share_plus: ^12.0.1
  path_provider: ^2.1.0

assets:
  - assets/data/solutions_6x10_normalisees.bin
```

### `main.dart` - Point d'entrée

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pré-chargement solutions en arrière-plan
  Future.microtask(() async {
    final solutions = await loadNormalizedSolutionsAsBigInt();
    solutionMatcher.initWithBigIntSolutions(solutions);
    debugPrint('✅ ${solutionMatcher.totalSolutions} solutions');
  });
  
  runApp(const ProviderScope(child: MyApp()));
}
```

**Navigation** :
- Route principale : `HomeScreen` (menu avec cartes)
- Route `/game` : `PentominoGameScreen`

---

## 📊 Statistiques

### Nombre de solutions

- **2 339** solutions canoniques (une par classe de symétrie)
- **9 356** solutions totales (avec 4 transformations)
- **45 octets** par solution dans le fichier .bin
- **105 KB** taille du fichier binaire

### Nombre de combinaisons (C(12,p))

| Pièces | Combinaisons | Temps validation |
|--------|--------------|------------------|
| 2      | 66           | < 1 minute       |
| 3      | 220          | ~1-5 minutes     |
| 4      | 495          | ~5-15 minutes    |
| 5      | 792          | ~15-60 minutes   |
| 6      | 924          | ~30-120 minutes  |
| 12     | 1            | ~9 minutes       |

### Performances

- **Chargement solutions** : ~200-500ms
- **Génération transformations** : ~100-300ms
- **Comptage compatible** : ~10-50ms (pour 9356 solutions)
- **Validation plateau** : 1-60 minutes (selon nb de pièces)

---

## 🐛 Debugging

### Logs importants

```dart
// Dans main.dart
debugPrint('🔄 Pré-chargement des solutions...');
debugPrint('✅ $count solutions BigInt chargées en ${duration}ms');

// Dans solution_matcher.dart
debugPrint('[SOLUTION_MATCHER] ✓ ${_solutions.length} solutions générées');

// Dans plateau_editor_provider.dart
print('[VALIDATE] Combinaison: ${combo.join(",")}');
print('[VALIDATE] ✓ Solution trouvée !');
```

### Vérifications

```dart
// Vérifier init du matcher
assert(solutionMatcher.totalSolutions == 9356);

// Vérifier format BigInt
assert(solution.bitLength <= 360);

// Vérifier plateau
assert(plateau.width == 6 && plateau.height == 10);
```

### Outils de debug

- Logs détaillés dans les providers
- `print()` statements dans les services
- Git history propre pour tracking

---

## 🔧 Réorganisation progressive (complète Phase 1-2)

### Objectif
Découper `pentomino_game_screen.dart` (1350+ lignes) en modules réutilisables et maintenables.

### Phase 1 : Utilitaires ✅ (18 nov 2025)
**Fichiers créés** :
- `lib/screens/pentomino_game/utils/game_constants.dart` - Dimensions, bordures, constantes
- `lib/screens/pentomino_game/utils/game_colors.dart` - Palette complète
- `lib/screens/pentomino_game/utils/game_utils.dart` - Export centralisé

### Phase 2 : Widgets ✅ (18 nov 2025)
**Fichiers créés** :
- `widgets/shared/piece_renderer.dart` - Affichage pièce (120 lignes)
- `widgets/shared/draggable_piece_widget.dart` - Drag & drop (170 lignes)
- `widgets/shared/piece_border_calculator.dart` - Bordures (120 lignes)
- `widgets/shared/action_slider.dart` - Actions paysage (310 lignes)
- `widgets/game_mode/piece_slider.dart` - Slider pièces (175 lignes)

### Résultats
- **Avant** : 1350 lignes (monolithique)
- **Après** : 650 lignes (orchestrateur)
- **Gain** : -700 lignes (-52%) 🎯
- **Imports** : Tous en absolu depuis `lib/`

**Usage** :
```dart
// Imports absolus
import 'package:pentapol/screens/pentomino_game/utils/game_utils.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_renderer.dart';

// Utilisation
final width = GameConstants.boardWidth;
final color = GameColors.masterCellBorderColor;
```

### Phases futures (optionnelles)
- **Phase 3** : Extraire `game_board.dart` (~400 lignes)
- **Phase 4** : Extraire AppBars (~100 lignes)
- **Phase 5** : Vues complètes des modes

**Approche** : Extraction progressive, sans breaking changes, tests continus.

---

## 🚀 Prochaines étapes

### Court terme
- [x] Réorganisation pentomino_game Phase 1-2 (-52%)
- [ ] Optimiser validation (paralléliser avec isolates)
- [ ] Ajouter progress bar pendant validation
- [ ] Sauvegarder/charger plateaux
- [ ] Améliorer UI navigateur solutions

### Moyen terme
- [ ] Mode Mini-puzzles (2×5, 3×5, 4×5, 5×5)
- [ ] Mode challenge avec objectifs
- [ ] Statistiques et analytics
- [ ] Partage de configurations
- [ ] Tutoriels supplémentaires

### Long terme
- [ ] Générateur de puzzles avec difficulté
- [ ] Classements et achievements globaux
- [ ] Support autres formats (non 6×10)
- [ ] Tournois en mode Duel

---

## 📝 Notes importantes

### ⚠️ Points d'attention

1. **Timeout solver** : 30s par défaut, ajustable
2. **Mémoire** : Les 9356 solutions BigInt occupent ~100KB en RAM
3. **Validation** : Peut prendre du temps avec 5-11 pièces
4. **Système Race supprimé** : Mode multijoueur asynchrone retiré (1er déc 2025)

### ✅ Bonnes pratiques

1. Toujours initialiser `solutionMatcher` au démarrage
2. Utiliser `copyWith()` pour l'immutabilité
3. Préférer `BigInt` pour les comparaisons (performances)
4. Ajouter logs pour debugging

### 🔗 Liens utiles

**Documentation externe** :
- Flutter : https://flutter.dev
- Riverpod : https://riverpod.dev
- Supabase : https://supabase.com
- Pentominos : https://en.wikipedia.org/wiki/Pentomino

**Documentation projet** :
- **DOCIA.md** : Documentation opérationnelle (résumé)
- **MOVEPIECE.md** : Mécanisme drag & drop détaillé
- **TUTORIAL_ARCHITECTURE.md** : Architecture système tutoriel
- **CODE_STANDARDS.md** : Standards de code
- **CLEANUP_RACE_SYSTEM.md** : Historique suppression système Race

---

**Dernière mise à jour : 1er janvier 2026**

**Mainteneur : Documentation générée automatiquement**

**Changements récents** :
- 1er janvier 2026 : Système de mastercase fixe pour transformations (Pentoscope), messages fugaces, recentrage automatique
- 1er décembre 2025 : Suppression système Race, nouveau HomeScreen moderne
