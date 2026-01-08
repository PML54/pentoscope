# providers/settings_provider.dart

**Module:** providers

## Fonctions

### SettingsDatabase

Provider pour la base de données des paramètres


```dart
return SettingsDatabase();
```

### SettingsNotifier

Provider pour les paramètres de l'application


```dart
return SettingsNotifier();
```

### build

```dart
AppSettings build() {
```

### recordDuelGame

Enregistrer le résultat d'une partie (isWin: true=victoire, false=défaite, null=égalité)


```dart
Future<void> recordDuelGame({required bool? isWin}) async {
```

### resetDuelSettings

Réinitialiser tous les paramètres Duel (garder nom et stats)


```dart
Future<void> resetDuelSettings() async {
```

### resetDuelStats

Réinitialiser les statistiques Duel


```dart
Future<void> resetDuelStats() async {
```

### resetToDefaults

Réinitialise tous les paramètres par défaut


```dart
Future<void> resetToDefaults() async {
```

### setColorScheme

Change le schéma de couleurs des pièces


```dart
Future<void> setColorScheme(PieceColorScheme scheme) async {
```

### setCustomColors

Définit les couleurs personnalisées


```dart
Future<void> setCustomColors(List<Color> colors) async {
```

### setDifficulty

Change le niveau de difficulté


```dart
Future<void> setDifficulty(GameDifficulty difficulty) async {
```

### setDuelCustomDuration

Définir la durée personnalisée (en secondes)


```dart
Future<void> setDuelCustomDuration(int seconds) async {
```

### setDuelDuration

Définir la durée de partie


```dart
Future<void> setDuelDuration(DuelDuration duration) async {
```

### setDuelGuideOpacity

Définir l'opacité du guide (0.1 - 0.5)


```dart
Future<void> setDuelGuideOpacity(double opacity) async {
```

### setDuelHatchOpacity

Définir l'opacité des hachures (0.2 - 0.6)


```dart
Future<void> setDuelHatchOpacity(double opacity) async {
```

### setDuelPlayerName

Définir le nom du joueur


```dart
Future<void> setDuelPlayerName(String? name) async {
```

### setDuelShowGuide

Activer/désactiver le guide de solution


```dart
Future<void> setDuelShowGuide(bool show) async {
```

### setDuelShowHatch

Activer/désactiver les hachures sur pièces adversaires


```dart
Future<void> setDuelShowHatch(bool show) async {
```

### setDuelShowOpponentProgress

Activer/désactiver l'affichage des pièces adversaires


```dart
Future<void> setDuelShowOpponentProgress(bool show) async {
```

### setDuelShowPieceNumbers

Activer/désactiver les numéros sur le guide


```dart
Future<void> setDuelShowPieceNumbers(bool show) async {
```

### setDuelSounds

Activer/désactiver les sons


```dart
Future<void> setDuelSounds(bool enable) async {
```

### setDuelVibration

Activer/désactiver les vibrations


```dart
Future<void> setDuelVibration(bool enable) async {
```

### setEnableAnimations

Active/désactive les animations


```dart
Future<void> setEnableAnimations(bool enable) async {
```

### setEnableHaptics

Active/désactive le retour haptique


```dart
Future<void> setEnableHaptics(bool enable) async {
```

### setEnableHints

Active/désactive les indices


```dart
Future<void> setEnableHints(bool enable) async {
```

### setEnableTimer

Active/désactive le chronomètre


```dart
Future<void> setEnableTimer(bool enable) async {
```

### setIconSize

Change la taille des icônes


```dart
Future<void> setIconSize(double size) async {
```

### setIsometriesAppBarColor

Change la couleur de fond de l'AppBar en mode isométries


```dart
Future<void> setIsometriesAppBarColor(Color color) async {
```

### setLongPressDuration

Change la durée du long press


```dart
Future<void> setLongPressDuration(int duration) async {
```

### setPieceOpacity

Change l'opacité des pièces


```dart
Future<void> setPieceOpacity(double opacity) async {
```

### setShowGridLines

Active/désactive l'affichage des lignes de grille


```dart
Future<void> setShowGridLines(bool show) async {
```

### setShowPieceNumbers

Active/désactive l'affichage des numéros sur les pièces


```dart
Future<void> setShowPieceNumbers(bool show) async {
```

### setShowSolutionCounter

Active/désactive le compteur de solutions


```dart
Future<void> setShowSolutionCounter(bool show) async {
```

