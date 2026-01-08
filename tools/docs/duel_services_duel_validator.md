# duel/services/duel_validator.dart

**Module:** duel

## Fonctions

### initialize

Résultat de validation d'un placement
Service de validation des placements pour le mode Duel
Grille de la solution (6x10) - pieceId (1-12) par cellule
Map de conversion bit6 → pieceId (initialisée dans le constructeur)
Construit la map de conversion bit6 → pieceId


```dart
void initialize(List<BigInt> solutions) {
```

### loadSolution

Convertit un bit6 en pieceId
Charge une solution et la décode en grille


```dart
Future<bool> loadSolution(int solutionId) async {
```

### validatePlacement

Décode un BigInt en grille 6x10 avec conversion bit6 → pieceId
Affiche la grille pour debug
Retourne la grille de la solution
Valide un placement


```dart
PlacementValidation validatePlacement({
```

### reset

```dart
void reset() {
```

