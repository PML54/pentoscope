# pentoscope/pentoscope_solver.dart

**Module:** pentoscope

## Fonctions

### SolverPlacement

Solution = liste de placements (pieceId, gridX, gridY, positionIndex)


```dart
const SolverPlacement({
```

### toString

```dart
String toString() => 'Placement(id=$pieceId, grid=($gridX,$gridY), pos=$positionIndex)';
```

### findFirstSolution

Cherche la PREMIÈRE solution (rapide, arrête dès trouvée)
Retourne true si elle existe


```dart
bool findFirstSolution( List<int> pieceIds, int width, int height, ) {
```

### findAllSolutions

Cherche TOUTES les solutions avec timeout (2s max)
Retourne {solutionCount, solutions}


```dart
Future<SolverResult> findAllSolutions( List<int> pieceIds, int width, int height, {
```

### backtrackAll

```dart
void backtrackAll(int pieceIndex) {
```

### SolverResult

```dart
return SolverResult( solutionCount: solutions.length, solutions: solutions, );
```

### SolverResult

============================================================================
HELPERS PRIVÉS
============================================================================
Vérifier si placement possible (pas collision, dans limites)
Placer une pièce sur le plateau
Retirer une pièce du plateau
Résultat du solveur complet (avec timeout)


```dart
const SolverResult({
```

### toString

```dart
String toString() => 'SolverResult(count=$solutionCount, solutions=${solutions.length})';
```

