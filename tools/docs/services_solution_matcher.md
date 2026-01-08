# services/solution_matcher.dart

**Module:** services

## Fonctions

### SolutionInfo

Information détaillée sur une solution identifiée.

Permet de retrouver l'origine d'une solution :
- Son index absolu (0-9355)
- Sa solution canonique d'origine (0-2338)
- Le type de variante appliquée
Index absolu de la solution (0-9355)
Index de la solution canonique d'origine (0-2338)
Type de variante : 0=identité, 1=rot180, 2=mirrorH, 3=mirrorV
Nom lisible de la variante


```dart
const SolutionInfo(this.index);
```

### toString

```dart
String toString() => 'Solution #$index (canonique $canonicalIndex, $variantName)';
```

### initWithBigIntSolutions

Toutes les solutions utilisées (BigInt 360 bits chacune).
Initialise le matcher avec la liste des solutions canoniques (2339 BigInt).
On génère ensuite en interne les 4 variantes 6x10 pour chaque solution.


```dart
void initWithBigIntSolutions(List<BigInt> canonicalSolutions) {
```

### StateError

```dart
throw StateError( 'SolutionMatcher non initialisé.\n' 'Appelle solutionMatcher.initWithBigIntSolutions(...) au démarrage.', );
```

### ArgumentError

Nombre total de solutions chargées (devrait être ~9356).
Accès en lecture à toutes les solutions (pour le navigateur).
Decode un BigInt (360 bits) en liste de 60 codes bit6 (0..63).

Convention : le BigInt a été construit en faisant:
acc = (acc << 6) | code; pour les cases 0..59.
Encode une liste de 60 codes bit6 (0..63) vers un BigInt 360 bits.


```dart
throw ArgumentError('Un plateau doit avoir exactement $_cells cases.');
```

### countCompatibleFromBigInts

Rotation 180° sur un plateau 6x10 (indices 0..59).
Miroir horizontal (gauche-droite) sur un plateau 6x10.
Miroir vertical (haut-bas) sur un plateau 6x10.
Vérifie la compatibilité d'une solution [solution]
avec un plateau défini par [piecesBits] et [maskBits].

piecesBits : codes bit6 (0 si vide)
maskBits   : 0x3F (6 bits à 1) pour case occupée, 0 sinon

Compatibilité :
(solution & maskBits) == piecesBits
Compte les solutions compatibles pour un plateau donné.


```dart
int countCompatibleFromBigInts(BigInt piecesBits, BigInt maskBits) {
```

### getCompatibleSolutionsFromBigInts

Retourne la liste des solutions compatibles (pour debug / navigateur).


```dart
List<BigInt> getCompatibleSolutionsFromBigInts( BigInt piecesBits, BigInt maskBits, ) {
```

### getCompatibleSolutionIndices

Retourne les indices des solutions compatibles (0..9355).
Utile pour stocker/identifier les solutions trouvées.


```dart
List<int> getCompatibleSolutionIndices(BigInt piecesBits, BigInt maskBits) {
```

### findSolutionIndex

Retourne l'index d'une solution exacte (ou -1 si non trouvée).
Utile quand le plateau est complet.


```dart
int findSolutionIndex(BigInt completeSolution) {
```

