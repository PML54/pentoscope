# pentoscope/pentoscope_generator.dart

**Module:** pentoscope

## Fonctions

### generate

Générateur de puzzles Pentoscope (lazy, sans table pré-calculée)
Génère un puzzle aléatoire pour une taille donnée
Boucle jusqu'à trouver une combinaison valide (avec 1+ solution)


```dart
Future<PentoscopePuzzle> generate(PentoscopeSize size) async {
```

### PentoscopePuzzle

```dart
return PentoscopePuzzle( size: size, pieceIds: pieceIds, solutionCount: result.solutionCount, solutions: result.solutions, );
```

### generateEasy

Génère un puzzle en favorisant ceux avec plus de solutions (faciles)
Boucle jusqu'à solutionCount >= threshold


```dart
Future<PentoscopePuzzle> generateEasy(PentoscopeSize size) async {
```

### PentoscopePuzzle

```dart
return PentoscopePuzzle( size: size, pieceIds: pieceIds, solutionCount: result.solutionCount, solutions: result.solutions, );
```

### generateHard

Génère un puzzle en favorisant ceux avec peu de solutions (durs)
Boucle jusqu'à solutionCount <= threshold


```dart
Future<PentoscopePuzzle> generateHard(PentoscopeSize size) async {
```

### PentoscopePuzzle

```dart
return PentoscopePuzzle( size: size, pieceIds: pieceIds, solutionCount: result.solutionCount, solutions: result.solutions, );
```

### PentoscopePuzzle

Sélectionne N pièces aléatoires parmi les 12 disponibles
Configuration d'un puzzle Pentoscope
Noms des pièces (X, P, T, F, Y, V, U, L, N, W, Z, I)


```dart
const PentoscopePuzzle({
```

### toString

Description lisible
Retourne les noms des pièces du puzzle


```dart
String toString() => 'PentoscopePuzzle($description)';
```

### PentoscopeSize

Tailles de plateau disponibles (TRANSPOSÉES pour portrait)


```dart
const PentoscopeSize( this.dataIndex, this.width, this.height, this.numPieces, this.label, );
```

### PentoscopeStats

Statistiques (optionnel - pas vraiment utilisé en lazy mode)


```dart
const PentoscopeStats({
```

### toString

```dart
String toString() => '$description';
```

