# services/plateau_solution_counter.dart

**Module:** services

## Fonctions

### StateError

```dart
throw StateError( 'countPossibleSolutions() est défini pour un plateau 6x10, ' 'reçu ${width}x$height.',
```

### StateError

```dart
throw StateError('Aucun bit6 pour pieceId=$cellValue');
```

### getCompatibleSolutionsBigInt

Compte les solutions compatibles (comme avant).
Retourne la liste des solutions compatibles (BigInt) pour le plateau courant.
Renvoie [] en cas d'erreur.


```dart
List<BigInt> getCompatibleSolutionsBigInt() {
```

### getCompatibleSolutionIndices

Retourne les indices des solutions compatibles (0-9355).
Utile pour stocker/identifier les solutions possibles.


```dart
List<int> getCompatibleSolutionIndices() {
```

### findExactSolutionIndex

Retourne l'index de la solution si le plateau est complet et correspond
exactement à une solution connue. Retourne -1 sinon.


```dart
int findExactSolutionIndex() {
```

