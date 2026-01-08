# data/solution_database.dart

**Module:** data

## Fonctions

### init

Base de données des solutions pentomino précalculées.

Charge les formes canoniques depuis assets/solutions_canonical.bin
et fournit des méthodes de recherche/filtrage.
Base de données en mémoire des solutions pentomino.
Solutions canoniques chargées (ou null si pas encore initialisé).
Nombre de solutions chargées.
Indique si la base est initialisée.
Charge les solutions depuis assets/solutions_canonical.bin.

Doit être appelé au démarrage de l'app (main.dart):
```dart
await SolutionDatabase.init();
```

Durée: ~5-10 ms pour 35 Ko


```dart
static Future<void> init() async {
```

### StateError

Désérialise le format binaire en List<List<int>>.

Format: [nombre (int32)] + [solution1: 8×int32] + [solution2: 8×int32] + ...
Trouve les solutions compatibles avec un plateau donné.

Un plateau est compatible si:
- Les cellules cachées correspondent (-1)
- Les cellules libres peuvent être remplies (0)


```dart
throw StateError('SolutionDatabase non initialisé. Appelez init() d\'abord.');
```

### decodeSolution

Vérifie si un plateau est compatible avec une solution.
Décode une solution en Plateau.


```dart
static Plateau decodeSolution(List<int> encoded) {
```

### hasSolution

Trouve si un plateau a une solution (recherche rapide).


```dart
static bool hasSolution(Plateau plateau) {
```

### findMatchingSolutions

```dart
return findMatchingSolutions(plateau).isNotEmpty;
```

### getStats

Statistiques de la base de données.


```dart
static Map<String, dynamic> getStats() {
```

### reset

Réinitialise la base (utile pour les tests).


```dart
static void reset() {
```

