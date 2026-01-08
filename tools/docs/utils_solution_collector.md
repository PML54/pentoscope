# utils/solution_collector.dart

**Module:** utils

## Fonctions

### onSolutionFound

Collecteur qui capture les solutions du solver et les exporte
Callback à passer au solver pour chaque solution trouvée


```dart
void onSolutionFound(List<PlacementInfo> placements) {
```

### finalize

Convertit une List<PlacementInfo> en grille 10x6
Sauvegarde finale et statistiques


```dart
Future<void> finalize() async {
```

### collectAllSolutions

Lance le comptage et la collecte des solutions de manière isolée


```dart
Future<void> collectAllSolutions({
```

