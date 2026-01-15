# services/solution_matcher.dart

**Module:** services

## Fonctions

### SolutionInfo

Information détaillée sur une solution identifiée.

Cette classe permet de retrouver l'origine complète d'une solution :
- Son index absolu parmi les 9356 solutions (0-9355)
- Sa solution canonique d'origine parmi les 2339 familles (0-2338)
- Le type de transformation géométrique appliquée

## Exemple d'utilisation
```dart
final info = SolutionInfo(42);
print(info.index);          // 42
print(info.canonicalIndex); // 10 (= 42 ~/ 4)
print(info.variantType);    // 2 (= 42 % 4 = miroir horizontal)
print(info.variantName);    // "miroir horizontal"
```

## Relation index ↔ canonique ↔ variante
```
index = canonicalIndex * 4 + variantType

Exemple pour la famille canonique 10 :
Index 40 = famille 10, identité
Index 41 = famille 10, rotation 180°
Index 42 = famille 10, miroir horizontal
Index 43 = famille 10, miroir vertical
```
Index absolu de la solution (0-9355).

Cet index est unique et identifie complètement une solution
parmi toutes les variantes générées.
Index de la solution canonique d'origine (0-2338).

Identifie la "famille" de la solution, avant application
des transformations géométriques.
Type de variante appliquée à la solution canonique.

Valeurs possibles :
- 0 : Identité (solution originale)
- 1 : Rotation 180°
- 2 : Miroir horizontal (gauche ↔ droite)
- 3 : Miroir vertical (haut ↔ bas)
Nom lisible de la variante en français.
Crée une instance à partir de l'index absolu.


```dart
const SolutionInfo(this.index);
```

### toString

```dart
String toString() => 'Solution #$index (canonique $canonicalIndex, $variantName)';
```

### initWithBigIntSolutions

Gestionnaire principal des solutions pentominos 6×10.

Ce singleton gère :
- Le chargement et l'expansion des 2339 solutions canoniques en 9356 variantes
- L'encodage/décodage BigInt ↔ grille de codes bit6
- La recherche de solutions compatibles avec un plateau partiel
- La reconstruction des [PlacedPiece] à partir d'une solution BigInt

## Initialisation

Le matcher doit être initialisé au démarrage de l'application :
```dart
final loader = PentapolSolutionsLoader();
await loader.load();
solutionMatcher.initWithBigIntSolutions(loader.bigIntSolutions);
```

## Recherche de compatibilité

Pour trouver les solutions compatibles avec un plateau partiel :
```dart
// Convertir le plateau en masques BigInt
final (piecesBits, maskBits) = plateau.toBigIntMasks();

// Compter les solutions compatibles
final count = solutionMatcher.countCompatibleFromBigInts(piecesBits, maskBits);

// Ou obtenir les indices
final indices = solutionMatcher.getCompatibleSolutionIndices(piecesBits, maskBits);
```

## Reconstruction des pièces

Pour obtenir les [PlacedPiece] d'une solution :
```dart
final pieces = solutionMatcher.getPlacedPiecesByIndex(42);
for (final p in pieces!) {
print('${p.piece.id} à (${p.gridX}, ${p.gridY}) pos=${p.positionIndex}');
}
```
Liste des 9356 solutions (4 variantes × 2339 canoniques).

Chaque solution est un BigInt de 360 bits encodant les 60 cases
du plateau 6×10 avec le code bit6 de chaque pièce.
Indique si le matcher a été initialisé.
Nombre de cases du plateau 6×10.
Masque pour extraire 6 bits (0x3F = 0b111111 = 63).
Largeur du plateau en colonnes (x: 0 à 5).
Hauteur du plateau en lignes (y: 0 à 9).
Crée une instance du matcher (non initialisée).

Appeler [initWithBigIntSolutions] pour charger les solutions.
Initialise le matcher avec les solutions canoniques.

Cette méthode :
1. Reçoit les 2339 solutions canoniques (BigInt)
2. Génère 4 variantes pour chacune (identité, rot180, mirrorH, mirrorV)
3. Stocke les 9356 solutions résultantes

## Paramètres
- [canonicalSolutions] : Liste des 2339 BigInt canoniques

## Note
Cette méthode ne peut être appelée qu'une fois. Les appels suivants
sont ignorés avec un message de debug.


```dart
void initWithBigIntSolutions(List<BigInt> canonicalSolutions) {
```

### StateError

Vérifie que le matcher est initialisé, sinon lève une exception.


```dart
throw StateError( 'SolutionMatcher non initialisé.\n' 'Appelle solutionMatcher.initWithBigIntSolutions(...) au démarrage.', );
```

### ArgumentError

Nombre total de solutions chargées.

Retourne 9356 si initialisé correctement, 0 sinon.
Accès en lecture seule à toutes les solutions.

Retourne une liste immuable des 9356 BigInt.
Utile pour le navigateur de solutions.

## Lève
[StateError] si le matcher n'est pas initialisé.
Décode un BigInt (360 bits) en liste de 60 codes bit6.

## Convention d'encodage
Le BigInt a été construit ainsi :
```dart
acc = BigInt.zero;
for (cellIndex in 0..59) {
acc = (acc << 6) | BigInt.from(bit6Code);
}
```

Les bits de poids fort correspondent à la case 0,
les bits de poids faible à la case 59.

## Retour
Liste de 60 entiers (0-63), un par case du plateau.
Encode une liste de 60 codes bit6 vers un BigInt 360 bits.

## Paramètres
- [boardBit6] : Liste de 60 codes (0-63)

## Retour
BigInt de 360 bits représentant la solution.

## Lève
[ArgumentError] si la liste n'a pas exactement 60 éléments.


```dart
throw ArgumentError('Un plateau doit avoir exactement $_cells cases.');
```

### countCompatibleFromBigInts

Applique une rotation de 180° au plateau.

Équivalent à retourner le plateau "tête en bas".
La case (x, y) devient (width-1-x, height-1-y).

## Implémentation
Pour un tableau linéaire, `grid[i]` devient `grid[59-i]`.
Applique un miroir horizontal (gauche ↔ droite).

La case (x, y) devient (width-1-x, y).
Les colonnes sont inversées, les lignes restent en place.
Applique un miroir vertical (haut ↔ bas).

La case (x, y) devient (x, height-1-y).
Les lignes sont inversées, les colonnes restent en place.
Vérifie si une solution est compatible avec un plateau partiel.

## Algorithme
Une solution est compatible si, pour toutes les cases occupées
du plateau, la solution a la même pièce.

Formule : `(solution & maskBits) == piecesBits`

## Paramètres
- [piecesBits] : BigInt avec les codes bit6 des pièces placées (0 si vide)
- [maskBits] : BigInt avec 0x3F pour cases occupées, 0 sinon
- [solution] : BigInt de la solution à tester

## Retour
`true` si la solution est compatible.
Compte les solutions compatibles avec un plateau partiel.

## Paramètres
- [piecesBits] : Codes bit6 des pièces placées
- [maskBits] : Masque des cases occupées

## Retour
Nombre de solutions compatibles (0 à 9356).

## Lève
[StateError] si le matcher n'est pas initialisé.


```dart
int countCompatibleFromBigInts(BigInt piecesBits, BigInt maskBits) {
```

### getCompatibleSolutionsFromBigInts

Retourne les solutions compatibles sous forme de BigInt.

Utile pour le navigateur de solutions ou le debug.

## Paramètres
- [piecesBits] : Codes bit6 des pièces placées
- [maskBits] : Masque des cases occupées

## Retour
Liste des BigInt solutions compatibles.


```dart
List<BigInt> getCompatibleSolutionsFromBigInts( BigInt piecesBits, BigInt maskBits, ) {
```

### getCompatibleSolutionIndices

Retourne les indices des solutions compatibles (0-9355).

Permet d'identifier et stocker les solutions trouvées.

## Paramètres
- [piecesBits] : Codes bit6 des pièces placées
- [maskBits] : Masque des cases occupées

## Retour
Liste des indices (0-9355) des solutions compatibles.

## Exemple
```dart
final indices = solutionMatcher.getCompatibleSolutionIndices(piecesBits, maskBits);
for (final idx in indices) {
final info = SolutionInfo(idx);
print('Solution $idx (famille ${info.canonicalIndex})');
}
```


```dart
List<int> getCompatibleSolutionIndices(BigInt piecesBits, BigInt maskBits) {
```

### findSolutionIndex

Trouve l'index d'une solution complète exacte.

Utilisé quand le plateau est complet pour identifier
quelle solution le joueur a trouvée.

## Paramètres
- [completeSolution] : BigInt représentant un plateau complet

## Retour
- Index de la solution (0-9355) si trouvée
- -1 si la solution n'existe pas dans la base


```dart
int findSolutionIndex(BigInt completeSolution) {
```

### solutionToPlacedPieces

Récupère une solution par son index.

## Paramètres
- [index] : Index de la solution (0-9355)

## Retour
- BigInt de la solution si l'index est valide
- `null` si l'index est hors limites
Table de correspondance bit6 → pieceId (1-12).

Construite automatiquement à partir de la liste [pentominos].
Reconstruit une liste de [PlacedPiece] à partir d'un BigInt solution.

Cette méthode permet de "désérialiser" une solution compacte
en objets exploitables pour l'affichage ou la manipulation.

## Algorithme
1. Décode le BigInt en grille de 60 codes bit6
2. Groupe les cellules par code bit6 (= par pièce)
3. Pour chaque pièce :
- Trouve le [Pento] correspondant au bit6
- Calcule minX, minY des cellules → gridX, gridY
- Normalise les cellules (décale vers origine 0,0)
- Compare avec [Pento.cartesianCoords] pour trouver positionIndex

## Paramètres
- [solution] : BigInt de 360 bits représentant une solution complète

## Retour
Liste de 12 [PlacedPiece], une par pentomino.

## Exemple
```dart
final solution = solutionMatcher.getSolutionByIndex(42)!;
final pieces = solutionMatcher.solutionToPlacedPieces(solution);

for (final p in pieces) {
print('Pièce ${p.piece.id}:');
print('  Position: (${p.gridX}, ${p.gridY})');
print('  Orientation: ${p.positionIndex}');
print('  Cellules: ${p.absoluteCells.toList()}');
}
```

## Note
Si un code bit6 inconnu est rencontré (ne devrait pas arriver
avec des solutions valides), un message de debug est affiché
et la pièce est ignorée.


```dart
List<PlacedPiece> solutionToPlacedPieces(BigInt solution) {
```

### solutionToPlacedPieces

Reconstruit les [PlacedPiece] d'une solution par son index.

Raccourci combinant [getSolutionByIndex] et [solutionToPlacedPieces].

## Paramètres
- [index] : Index de la solution (0-9355)

## Retour
- Liste de 12 [PlacedPiece] si l'index est valide
- `null` si l'index est hors limites

## Exemple
```dart
final pieces = solutionMatcher.getPlacedPiecesByIndex(42);
if (pieces != null) {
print('Solution 42 contient ${pieces.length} pièces');
}
```


```dart
return solutionToPlacedPieces(solution);
```

