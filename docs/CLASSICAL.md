# Classical - Documentation Technique

## Vue d'ensemble

**Classical** est le mode de jeu principal de Pentapol : un puzzle de pentominos sur un plateau fixe 6×10 avec les 12 pièces. Ce mode utilise les **9356 solutions pré-calculées** stockées dans un fichier binaire pour offrir des fonctionnalités avancées comme le comptage de solutions compatibles et les indices (hints).

### Caractéristiques principales

- **Plateau fixe** : 6 colonnes × 10 lignes = 60 cases
- **12 pièces** : Toutes les formes pentominos (5 carrés chacune)
- **9356 solutions** : Pré-calculées et normalisées
- **Compteur de solutions** : Affiche en temps réel les solutions compatibles
- **Système de hints** : Suggère une pièce depuis une solution compatible
- **Timer et scoring** : Chronomètre et score basé sur la rapidité
- **Sauvegarde** : Sessions stockées dans la base de données SQLite

---

## Architecture des fichiers

```
lib/classical/
├── pentomino_game_provider.dart  # State management (Riverpod Notifier)
├── pentomino_game_state.dart     # Définition de l'état
└── pentomino_game_screen.dart    # Écran de jeu

lib/services/
├── solution_matcher.dart         # Gestion des 9356 solutions
└── plateau_solution_counter.dart # Extension pour compter les solutions
```

---

## Composants principaux

### 1. PentominoGameState (`pentomino_game_state.dart`)

Définit l'état complet du jeu.

#### Champs principaux

| Champ | Type | Description |
|-------|------|-------------|
| `plateau` | `Plateau` | Grille 6×10 |
| `availablePieces` | `List<Pento>` | Pièces dans le slider |
| `placedPieces` | `List<PlacedPiece>` | Pièces sur le plateau |
| `selectedPiece` | `Pento?` | Pièce sélectionnée (slider) |
| `selectedPlacedPiece` | `PlacedPiece?` | Pièce placée sélectionnée |
| `selectedPositionIndex` | `int` | Index rotation/orientation |
| `selectedCellInPiece` | `Point?` | Mastercase |
| `previewX`, `previewY` | `int?` | Position prévisualisation |
| `isPreviewValid` | `bool` | Preview valide |
| `isSnapped` | `bool` | Preview aimantée |
| `solutionsCount` | `int?` | Nombre de solutions compatibles |
| `solvedSolutionIndex` | `int?` | Index solution trouvée (0-9355) |
| `elapsedSeconds` | `int` | Temps écoulé |
| `isometriesCount` | `int` | Isométries appliquées |
| `solutionsViewCount` | `int` | Consultations du browser |
| `boardIsValid` | `bool` | Pas de chevauchement |
| `overlappingCells` | `Set<Point>` | Cases en conflit |
| `isInTutorial` | `bool` | Mode tutoriel actif |
| `highlightedSliderPiece` | `int?` | Pièce surlignée (tutoriel) |
| `cellHighlights` | `Map<Point, Color>` | Cases surlignées |
| `viewOrientation` | `ViewOrientation` | Portrait/Landscape |

### 2. PentominoGameNotifier (`pentomino_game_provider.dart`)

Gestionnaire d'état Riverpod avec logique de jeu complète.

#### Initialisation

```dart
@override
PentominoGameState build() {
  final initialState = PentominoGameState.initial();
  // Plateau vide = 9356 solutions
  final totalSolutions = Plateau.allVisible(6, 10).countPossibleSolutions();
  return initialState.copyWith(solutionsCount: totalSolutions);
}
```

#### Méthodes principales

```dart
// === SÉLECTION ===
void selectPiece(Pento piece)                    // Sélectionner du slider
void selectPlacedPiece(PlacedPiece placed, ...)  // Sélectionner sur plateau
void cancelSelection()                            // Annuler sélection

// === PLACEMENT ===
bool tryPlacePiece(int gridX, int gridY)         // Placer la pièce
void removePlacedPiece(PlacedPiece placed)       // Retirer du plateau
void undoLastPlacement()                          // Annuler dernier placement

// === ISOMÉTRIES ===
void applyIsometryRotationCW()   // Rotation 90° horaire
void applyIsometryRotationTW()   // Rotation 90° anti-horaire
void applyIsometrySymmetryH()    // Symétrie horizontale
void applyIsometrySymmetryV()    // Symétrie verticale
void cycleToNextOrientation()    // Cycle rapide

// === HINT ===
void applyHint()                 // Placer une pièce suggérée

// === TIMER ===
void startTimer()                // Démarrer le chronomètre
void _stopTimer()                // Arrêter le chronomètre

// === COMPLÉTION ===
Future<void> onPuzzleCompleted() // Appelé quand 12 pièces placées
int calculateScore(int seconds)  // Calculer le score

// === RESET ===
void reset()                     // Réinitialiser le jeu

// === COMPTEURS ===
void incrementSolutionsViewCount()  // +1 consultation solutions
```

#### Système de Hint

```dart
void applyHint() {
  // 1. Récupérer les solutions compatibles
  final compatibleIndices = state.plateau.getCompatibleSolutionIndices();

  // 2. Choisir une solution au hasard
  final randomIndex = compatibleIndices[random.nextInt(compatibleIndices.length)];

  // 3. Décoder en PlacedPiece
  final allPieces = solutionMatcher.getPlacedPiecesByIndex(randomIndex);

  // 4. Trouver une pièce non encore placée
  final hintPiece = allPieces.firstWhereOrNull(
    (p) => !placedPieceIds.contains(p.piece.id),
  );

  // 5. Placer sur le plateau + retirer du slider
  // 6. Recalculer solutionsCount
}
```

### 3. SolutionMatcher (`solution_matcher.dart`)

Service singleton gérant les 9356 solutions pré-calculées.

#### Encodage BigInt

Chaque solution est encodée sur **360 bits** (60 cases × 6 bits) :

```
Position 0-5   → Case (0,0) : bit6 de la pièce
Position 6-11  → Case (1,0) : bit6 de la pièce
...
Position 354-359 → Case (5,9) : bit6 de la pièce
```

#### Codes bit6

| Pièce | ID | bit6 |
|-------|-----|------|
| X | 1 | 0x01 |
| P | 2 | 0x02 |
| T | 3 | 0x03 |
| ... | ... | ... |
| I | 12 | 0x0C |
| Vide | 0 | 0x00 |

#### Méthodes principales

```dart
/// Charger les solutions depuis le fichier binaire
Future<void> loadSolutions()

/// Compter les solutions compatibles avec un état partiel
int countCompatibleSolutions(BigInt piecesBits, BigInt maskBits)

/// Retourner les indices des solutions compatibles
List<int> getCompatibleSolutionIndices(BigInt piecesBits, BigInt maskBits)

/// Trouver l'index exact d'une solution complète
int findSolutionIndex(BigInt completeSolution)

/// Récupérer une solution par son index
BigInt? getSolutionByIndex(int index)

/// Convertir BigInt → List<PlacedPiece>
List<PlacedPiece> solutionToPlacedPieces(BigInt solution)

/// Raccourci : index → List<PlacedPiece>
List<PlacedPiece>? getPlacedPiecesByIndex(int index)
```

### 4. PlateauSolutionCounter (`plateau_solution_counter.dart`)

Extension sur `Plateau` pour faciliter le comptage de solutions.

```dart
extension PlateauSolutionCounter on Plateau {
  /// Compte les solutions compatibles avec l'état actuel
  int? countPossibleSolutions()

  /// Retourne les indices des solutions compatibles
  List<int> getCompatibleSolutionIndices()

  /// Trouve l'index de la solution exacte (puzzle complet)
  int findExactSolutionIndex()
}
```

---

## Écran de jeu (`pentomino_game_screen.dart`)

### Structure UI

```
┌─────────────────────────────────────┐
│ AppBar                              │
│ [X] [Chrono] [Solutions] [💡] [❌]  │
├─────────────────────────────────────┤
│                                     │
│           GameBoard                 │
│         (6×10 plateau)              │
│                                     │
├─────────────────────────────────────┤
│         PieceSlider                 │
│    (pièces disponibles)             │
└─────────────────────────────────────┘
```

### AppBar - Mode Normal

| Position | Élément | Description |
|----------|---------|-------------|
| Leading | ❌ + Chrono | Bouton quitter + temps écoulé |
| Title | 🟢 [N] | Bouton vert avec nombre de solutions |
| Actions | 💡 | Bouton hint (ampoule) |

### AppBar - Mode Transformation (pièce sélectionnée)

| Actions | Description |
|---------|-------------|
| ↺ | Rotation anti-horaire |
| ↻ | Rotation horaire |
| ↔ | Symétrie horizontale |
| ↕ | Symétrie verticale |
| 🗑 | Supprimer (si pièce placée) |

### Dialog de complétion

Affiché quand les 12 pièces sont placées :

```
🎉 Bravo!
Puzzle complété en MM:SS!
Score: XX ⭐

Solution #NNNN
Famille XXX • [Identité|Rotation 180°|Miroir H|Miroir V]

[Rejouer] [Terminer]
```

---

## Flux de données

### Placement d'une pièce

```
1. User sélectionne pièce (slider/plateau)
   └─→ selectPiece() / selectPlacedPiece()

2. User déplace (drag)
   └─→ updatePreview(gridX, gridY)
       └─→ Calcul preview valide/invalide
       └─→ Snapping si proche d'une position valide

3. User relâche (drop)
   └─→ tryPlacePiece(gridX, gridY)
       ├─→ Vérification canPlacePiece()
       ├─→ Mise à jour plateau
       ├─→ Retrait du slider
       ├─→ Recalcul solutionsCount
       └─→ Si 12 pièces → onPuzzleCompleted()
```

### Complétion du puzzle

```
onPuzzleCompleted()
├─→ Arrêter le timer
├─→ Trouver l'index de solution (findExactSolutionIndex)
├─→ Calculer le score
├─→ Sauvegarder en base (GameSession)
└─→ Afficher dialog de victoire
```

---

## Score et métriques

### Calcul du score

```dart
int calculateScore(int elapsedSeconds) {
  // Score = 100 - (secondes / 2)
  // Max 100 (< 10 sec), Min 0 (> 200 sec)
  return (100 - (elapsedSeconds ~/ 2)).clamp(0, 100);
}
```

### Métriques sauvegardées (GameSession)

| Champ | Description |
|-------|-------------|
| `solutionNumber` | Numéro de solution (1-9356) |
| `elapsedSeconds` | Temps de résolution |
| `score` | Score calculé (0 actuellement) |
| `piecesPlaced` | Nombre de pièces (12) |
| `numUndos` | Nombre d'annulations |
| `isometriesCount` | Isométries utilisées |
| `solutionsViewCount` | Consultations du browser |

---

## Solutions et normalisation

### Les 9356 solutions

- **2339 solutions canoniques** (formes de base)
- **×4 variants** par solution :
  - Identité (solution originale)
  - Rotation 180°
  - Miroir horizontal
  - Miroir vertical
- Total : 2339 × 4 = **9356 solutions**

### SolutionInfo

```dart
class SolutionInfo {
  final int index;            // 0-9355
  final int canonicalIndex;   // 0-2338 (famille)
  final int variant;          // 0-3 (type de transformation)

  String get variantName {
    switch (variant) {
      case 0: return 'Identité';
      case 1: return 'Rotation 180°';
      case 2: return 'Miroir horizontal';
      case 3: return 'Miroir vertical';
    }
  }
}
```

---

## Intégration avec les autres modules

### Services partagés

- `SolutionMatcher` : Singleton global (`solutionMatcher`)
- `PlateauSolutionCounter` : Extension sur `Plateau`
- `PlacedPiece` : Classe commune (`lib/common/placed_piece.dart`)

### Base de données

- `SettingsDatabase` : Accès via `settingsDatabaseProvider`
- `GameSessions` : Table pour sauvegarder les parties
- Migrations : Schema version 1 (pas de migration complexe)

### Tutorial

Le mode Classical supporte le système de tutoriel :
- Highlights de pièces dans le slider
- Highlights de cases sur le plateau
- Highlights d'icônes d'isométrie
- Sauvegarde/restauration de l'état

---

## Différences avec Pentoscope

| Aspect | Classical | Pentoscope |
|--------|-----------|------------|
| Plateau | Fixe 6×10 | Variable |
| Pièces | 12 (toutes) | 3 à 8 |
| Solutions | 9356 pré-calculées | Générées dynamiquement |
| Compteur | Temps réel (BigInt) | Non disponible |
| Hint | ✅ Oui | ❌ Non |
| Score | Basé sur temps | Basé sur efficacité |
| Timer | ✅ Oui | ❌ Non |
| Sauvegarde | ✅ GameSession | ❌ Non |
| Browser solutions | ✅ Oui | ❌ Non |







