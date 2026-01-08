# MODELS - Documentation des modèles partagés

Modèles réutilisables utilisés par **Isopento** et d'autres modules (Pentapol, Pentoscope, etc.).

## 📋 Manifest des fichiers

| Fichier | Chemin | Modified | Lignes | Statut |
|---------|--------|----------|--------|--------|
| pentominos.dart | lib/models/pentominos.dart | 2512092000 | 390 | ✅ |
| plateau.dart | lib/models/plateau.dart | 2512091506 | 65 | ✅ |
| point.dart | lib/models/point.dart | 2512091506 | 22 | ✅ |

**Format timestamp** : YYMMDDHHM (année-mois-jour-heure-minute)

**Total** : 3 fichiers, ~477 lignes de code production

---

## 📝 En-têtes standardisés

```dart
// Format standard pour tous les models:
// lib/models/[model].dart
// Modified: YYMMDDHHM
```

### Headers détaillés

**pentominos.dart**
```dart
// lib/models/pentominos.dart
// Modified: 2512092000
// Pentominos avec numéros de cases sur grille 5×5
// Numérotation: ligne 1 (bas) = cases 1-5, ligne 2 = cases 6-10, etc.
// Les positions préservent l'ordre géométrique des cellules pour le tracking
```

**plateau.dart**
```dart
// lib/models/plateau.dart
// Modified: 2512091506
// Grille générique pour représenter plateaux de jeu
// Utilisé par isopento, pentomino_game, pentoscope, etc.
```

**point.dart**
```dart
// lib/models/point.dart
// Modified: 2512091506
// Classe simple pour représenter coordonnées (x, y) sur un plateau
// Immutable avec equality et hashCode
```

---

## 🔄 Historique des modifications

| Timestamp | Fichier | Modification |
|-----------|---------|--------------|
| 2512091506 | plateau.dart | Headers correction + copie |
| 2512091506 | point.dart | Headers correction + copie |
| 2512092000 | pentominos.dart | Headers correction + copie |

---

## Modèles détaillés

### 1. Pento (pentominos.dart)

**Rôle** : Représente un pentomino (pièce de 5 cellules) avec tous ses états géométriques.

**Classe unique** : `Pento` (const, immutable)

**Propriétés essentielles** :

```dart
final int id;                             // 1-12 (identifiant unique)
final int size;                           // Toujours 5 (pentomino = 5 cellules)
final List<List<int>> positions;          // Toutes les orientations distinctes
final List<List<List<int>>> cartesianCoords; // Coords (x,y) normalisées par orientation
final int numPositions;                   // Nombre d'orientations distinctes
final List<int> baseShape;                // Cellules de référence (ordre géométrique)
final int bit6;                           // Code binaire unique (6 bits, 0..63)
```

**Concepts clés** :

**Grille interne 5×5** :
- Chaque pentomino encodé dans grille 5×5 (cellules 1-25)
- Numérotation : ligne 1 (bas) = 1-5, ligne 2 = 6-10, etc.
- Conversion : `x = (cellNum - 1) % 5`, `y = (cellNum - 1) ~/ 5`

**Orientations** :
- Chaque pento peut avoir 1-8 orientations distinctes
- Stockées dans `positions[0..numPositions-1]`
- Ordre géométrique préservé pour tracking cellule-lettre (A-E)

**Lettres géométriques (A-E)** :
- Chaque cellule du pento identifiée par lettre fixe
- Basée sur ordre dans `baseShape`
- Invariante entre orientations grâce à préservation ordre géométrique

**Méthodes publiques** :

```dart
String getLetter(int cellNum)
→ Retourne lettre A-E pour une cellule donnée (globale)

String getLetterForPosition(int positionIndex, int cellNum)
→ Retourne lettre A-E pour une cellule dans une orientation spécifique

int findRotation90(int currentPositionIndex)
→ Trouve index orientation après rotation 90° CCW
→ Retourne -1 si symétrique (pas de nouvelle orientation)

int findSymmetryH(int currentPositionIndex)
→ Trouve index orientation après symétrie horizontale
→ Retourne -1 si non trouvée

int findSymmetryV(int currentPositionIndex)
→ Trouve index orientation après symétrie verticale
→ Retourne -1 si non trouvée
```

**Méthodes privées (isométries)** :

```dart
List<List<int>> _rotate90Coords(coords)     → (x,y) → (-y, x)
List<List<int>> _flipHCoords(coords)        → (x,y) → (-x, y)
List<List<int>> _flipVCoords(coords)        → (x,y) → (x, -y)
List<List<int>> _positionToCoordsNormalized(posIdx)
→ Convertit position 1-25 en coords (x,y) normalisées [0..3]
bool _coordsEqual(coords1, coords2)         → Comparaison normalisées
int _findTransformedPosition(posIdx, transform)
→ Générique pour trouver position transformée
```

**Normalisation** :
- Toutes les comparaisons utilisent coordonnées normalisées (min=0)
- Tri alphabétique pour comparaison robuste
- Permet détection orientations malgré décalages

**Data : 12 pentominos** :
```dart
final List<Pento> pentominos = [
  // 12 pièces avec :
  // - id: 1-12
  // - numPositions: 1-8 (dépend symétries)
  // - positions: liste des orientations (cellules 1-25)
  // - cartesianCoords: coords (x,y) normalisées pour chaque orientation
  // - baseShape: ordre géométrique de référence
  // - bit6: code unique pour bitmask
]
```

**Utilisé par** :
- isopento_solver.dart : validation placement, isométries
- isopento_provider.dart : sélection, transformation pièces
- isopento_piece_slider.dart : affichage pièces
- isopento_board.dart : rendu, interactions

---

### 2. Plateau (plateau.dart)

**Rôle** : Grille générique pour représenter état d'un plateau de jeu.

**Classe unique** : `Plateau` (immutable)

**Propriétés** :

```dart
final int width;              // Largeur plateau (3, 4, 5, 6, 10, etc.)
final int height;             // Hauteur plateau
final List<List<int>> grid;   // Grille 2D (height × width)
                              // -1 = invisible/off-board
                              //  0 = visible/libre
                              // >0 = occupée par pièce (id)
```

**Valeurs cellules** :

| Valeur | Signification |
|--------|--------------|
| -1 | Invisible / hors plateau / blocked |
| 0 | Visible et libre |
| 1-12 | Occupée par pièce (id pentomino) |

**Factories (constructeurs)** :

```dart
Plateau.empty(int width, int height)
→ Grille remplie de -1 (tout invisible)

Plateau.allVisible(int width, int height)
→ Grille remplie de 0 (tout visible et libre)

Plateau({width, height, grid})
→ Constructeur principal (grid fourni)
```

**Méthodes utilitaires** :

```dart
int get numVisibleCells
→ Compte cellules visibles (>= 0)

int get numFreeCells
→ Compte cellules libres (== 0)

bool isInBounds(int x, int y)
→ Vérifie si (x, y) est dans le plateau

int getCell(int x, int y)
→ Retourne valeur cellule (ou -1 si hors bounds)

void setCell(int x, int y, int value)
→ Modifie valeur cellule (si in bounds)

Plateau copy()
→ Crée copie profonde (grille clonée)
```

**Utilisé par** :

- isopento_solver.dart : placement validation, backtracking
- isopento_provider.dart : state plateau joueur, solutionPlateau
- isopento_board.dart : affichage grille + pièces
- pentomino_game : plateau 6×10
- pentoscope : plateaux mini (3×5, 4×5, 5×5)

**Exemple Isopento** :

```dart
// Créer plateau vierge 3×5
final plateau = Plateau.allVisible(5, 3);

// Placer pièce 2 aux coords (1, 1)
plateau.setCell(1, 1, 2);
plateau.setCell(2, 1, 2);
plateau.setCell(1, 2, 2);

// Vérifier placement
if (plateau.getCell(1, 1) != 0) {
  print('Case occupée');
}

// Copie pour validation backtracking
final backup = plateau.copy();
```

---

### 3. Point (point.dart)

**Rôle** : Représente coordonnées (x, y) sur un plateau. Immutable avec equality.

**Classe unique** : `Point`

**Propriétés** :

```dart
final int x;    // Coordonnée X
final int y;    // Coordonnée Y
```

**Caractéristiques** :

- ✅ **Immutable** : const constructor
- ✅ **Equality** : `operator ==` compare x et y
- ✅ **Hashable** : `get hashCode` pour utilisation dans Map/Set
- ✅ **Printable** : `toString()` retourne "(x, y)"

**Méthodes** :

```dart
const Point(int x, int y)
→ Constructeur

bool operator ==(Object other)
→ Equality par valeur (x et y)

int get hashCode
→ Hash pour collections

String toString()
→ "(x, y)"
```

**Equality / Hashcode** :

```dart
Point(1, 2) == Point(1, 2)  // true
Point(1, 2) == Point(2, 1)  // false
Point(1, 2).hashCode == Point(1, 2).hashCode  // true (même logique)

// Utilisable dans Set, Map, List.contains()
Set<Point> visited = {Point(0, 0), Point(1, 1)};
if (visited.contains(Point(0, 0))) { ... }  // O(1) lookup
```

**Utilisé par** :

- isopento_provider.dart : selectedCellInPiece (mastercase)
- isopento_board.dart : interactions drag, preview
- Tous les modules UI pour coordonnées

**Exemple** :

```dart
// Sélection mastercase
final cell = Point(2, 1);  // x=2, y=1

// Comparaison
if (cell == Point(2, 1)) {
  print('Mastercase au même endroit');
}

// Collections
List<Point> route = [Point(0, 0), Point(1, 0), Point(2, 0)];
if (route.contains(Point(1, 0))) {
  print('Passage par (1, 0)');
}
```

---

## Relationships avec Isopento

```
Pento (12 pièces)
  ├─ positions[0..numPositions] : List<int>
  ├─ cartesianCoords[0..numPositions] : List<List<int>>
  └─ Méthodes isométries (rotation, symétries)
     └─ Utilisées par isopento_provider pour calculs

Plateau (grille)
  ├─ grid[height][width] : List<List<int>>
  ├─ plateau : état joueur
  └─ solutionPlateau : solution de référence (semi-transparent)
     └─ Utilisés par isopento_board pour affichage

Point (coordonnées)
  └─ selectedCellInPiece : mastercase pour transformations
     └─ Utilisé par isopento_provider pour drag/drop
```

---

## Architecture Models

**Immutabilité** :
- ✅ Pento : const, propriétés finales
- ✅ Plateau : const constructor, mais grid mutable (caveat)
- ✅ Point : const, propriétés finales

**Séparation responsabilités** :
- **Pento** : géométrie pentomino + isométries
- **Plateau** : grille générique (domaine d'application agnostique)
- **Point** : coordonnées (utilitaire)

**Dépendances** :
```
Point → aucune dépendance
Plateau → aucune dépendance
Pento → aucune dépendance
```

→ Tous les trois indépendants, réutilisables

---

## Notes d'implémentation

### Pento

**Grille 5×5 interne** :
- Standard pour tous les pentominos
- Permet normalisation cohérente
- Conversion : `(cellNum - 1) % 5`, `(cellNum - 1) ~/ 5`

**Ordre géométrique** :
- `baseShape` et `positions` conservent ordre cellules
- Permet mapping stable cellule ↔ lettre (A-E)
- Essentiel pour shape recognition

**cartesianCoords pré-calculées** :
- Évite recalcul à chaque comparaison
- Normalisées (min=0) et triées
- Utilisées par solver + provider

### Plateau

**Grille mutable** :
- Bien que Plateau soit "const", grid est mutable (List)
- Accepté pour performance (évite copies constantes)
- Mais traiter comme immutable sauf contexte backtracking

**Valeur -1 vs 0** :
- -1 = invisible / off-board (mode 6×10 : zones bloquées)
- 0 = visible libre (mode isopento : tout visible)
- >0 = occupée par pièce

### Point

**Equality vs Identity** :
- `==` basée sur valeur, pas identité
- Permet `point1 == point2` même si objets différents
- Hashcode cohérent pour collections

---

## Checklist intégration

- [ ] Headers standardisés YYMMDDHHM dans les 3 fichiers
- [ ] Utilisation Pento.findRotation90/Symmetry cohérente
- [ ] Plateau.copy() pour sauvegarde état backtracking
- [ ] Point utilisé pour selectedCellInPiece (mastercase)
- [ ] Conversion cellNum ↔ (x, y) correcte (0-based)
- [ ] Normalization coords pour isométries robuste
- [ ] Lettres A-E stables entre orientations

---

## Améliorations possibles

**Performance** :
- Cache isométries (find*) si appelée souvent
- BigInt plateau pour grilles > 32 cellules

**Flexibilité** :
- Plateau generic T au lieu de int (pour metadata)
- Pento.scale() pour variantes (pentomino → hexomino)

**Robustesse** :
- Validation Pento à construction (positions valides)
- Plateau.validate() pour debug