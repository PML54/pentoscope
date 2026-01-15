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

Solveur de pentominos optimisé pour Pentoscope

Utilise plusieurs techniques d'optimisation :
1. **Smallest Free Cell First** : Cible toujours la plus petite case libre
2. **Isolated Region Pruning** : Élimine les branches avec des zones impossibles
3. **Piece Ordering** : Essaie d'abord les pièces les plus contraintes
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
void backtrackAll() {
```

### SolverResult

```dart
return SolverResult( solutionCount: solutions.length, solutions: solutions, );
```

### canSolveFrom

Vérifie si au moins une solution existe depuis un état partiel
[pieceIds] : IDs des pièces restantes à placer
[plateau] : État actuel du plateau (0 = vide, sinon ID de la pièce)


```dart
bool canSolveFrom( List<int> pieceIds, int width, int height, List<List<int>> plateau, ) {
```

### SolverResult

Trouve une solution depuis un état partiel et retourne les placements
[pieceIds] : IDs des pièces restantes à placer
[plateau] : État actuel du plateau
Retourne la liste des placements pour les pièces restantes, ou null
Backtrack optimisé qui garde les placements trouvés
Trouve la plus petite case libre (parcours ligne par ligne)
Retourne l'index linéaire (y * width + x) ou null si plateau plein
Trouve un placement valide pour la pièce qui couvre la case cible
Retourne (gridX, gridY) ou null si impossible
Vérifie que toutes les zones vides sont valides :
- Pas de zone < 5 cases (impossible à remplir)
- Pas de zone avec un nombre de cases non-multiple de 5
Flood fill pour compter la taille d'une région connexe
Trie les pièces par nombre d'orientations (croissant)
Les pièces avec moins d'orientations sont plus contraintes → à placer d'abord
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

