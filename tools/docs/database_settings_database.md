# database/settings_database.dart

**Module:** database

## Fonctions

### LazyDatabase

```dart
return LazyDatabase(() async {
```

### NativeDatabase

```dart
return NativeDatabase(file);
```

### getSetting

Table pour stocker les paramètres de l'application
Table pour sauvegarder les sessions de jeu (solutions résolues)
Table pour les statistiques agrégées par solution
Récupère une valeur de paramètre


```dart
Future<String?> getSetting(String key) async {
```

### setSetting

Définit une valeur de paramètre


```dart
Future<void> setSetting(String key, String value) async {
```

### into

```dart
await into(settings).insertOnConflictUpdate( SettingsCompanion.insert( key: key, value: value, ), );
```

### deleteSetting

Supprime un paramètre


```dart
Future<void> deleteSetting(String key) async {
```

### clearAllSettings

Supprime tous les paramètres


```dart
Future<void> clearAllSettings() async {
```

### delete

```dart
await delete(settings).go();
```

### saveGameSession

Sauvegarder une session de jeu complétée


```dart
Future<void> saveGameSession({
```

### into

```dart
await into(gameSessions).insert( GameSessionsCompanion( solutionNumber: Value(solutionNumber), elapsedSeconds: Value(elapsedSeconds), score: Value(score), piecesPlaced: Value(piecesPlaced), numUndos: Value(numUndos), isometriesCount: Value(isometriesCount), solutionsViewCount: Value(solutionsViewCount), playerNotes: Value(playerNotes), ), );
```

### getFastestCompletion

Récupérer l'historique des sessions (les plus récentes en premier)
Récupérer les sessions pour une solution spécifique
Récupérer le record du meilleur temps


```dart
Future<GameSession?> getFastestCompletion() async {
```

### getHighestScore

Récupérer le meilleur score


```dart
Future<GameSession?> getHighestScore() async {
```

### getTotalSessionsCount

Nombre total de sessions complétées


```dart
Future<int> getTotalSessionsCount() async {
```

### getUniqueSolutionsCount

Nombre de solutions uniques résolues


```dart
Future<int> getUniqueSolutionsCount() async {
```

### getSolutionStats

Récupérer les stats d'une solution


```dart
Future<SolutionStat?> getSolutionStats(int solutionNumber) async {
```

### update

Mettre à jour les stats après une completion


```dart
await update(solutionStats).replace( SolutionStatsCompanion( id: Value(existing.id), solutionNumber: Value(solutionNumber), timesPlayed: Value(existing.timesPlayed + 1), bestTime: Value(seconds < existing.bestTime ? seconds : existing.bestTime), averageTime: Value(newAverage), bestScore: Value(newBestScore), lastPlayed: Value(DateTime.now()), ), );
```

### into

```dart
await into(solutionStats).insert( SolutionStatsCompanion( solutionNumber: Value(solutionNumber), timesPlayed: Value(1), bestTime: Value(seconds), averageTime: Value(seconds), bestScore: Value(score), firstPlayed: Value(DateTime.now()), lastPlayed: Value(DateTime.now()), ), );
```

