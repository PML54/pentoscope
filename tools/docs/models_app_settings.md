# models/app_settings.dart

**Module:** models

## Fonctions

### UISettings

Schéma de couleurs pour les pièces
Niveau de difficulté du jeu
Durée de partie Duel prédéfinie
Durée en secondes
Label pour l'UI
Icône pour l'UI
Paramètres UI


```dart
const UISettings({
```

### copyWith

```dart
UISettings copyWith({
```

### UISettings

```dart
return UISettings( colorScheme: colorScheme ?? this.colorScheme, customColors: customColors ?? this.customColors, showPieceNumbers: showPieceNumbers ?? this.showPieceNumbers, showGridLines: showGridLines ?? this.showGridLines, enableAnimations: enableAnimations ?? this.enableAnimations, pieceOpacity: pieceOpacity ?? this.pieceOpacity, isometriesAppBarColor: isometriesAppBarColor ?? this.isometriesAppBarColor, iconSize: iconSize ?? this.iconSize, );
```

### getPieceColor

Obtenir la couleur d'une pièce selon le schéma actuel


```dart
Color getPieceColor(int pieceId) {
```

### toJson

Palette DUEL : 12 couleurs maximalement distinctes
Conçue pour le mode compétitif où la distinction rapide est cruciale


```dart
Map<String, dynamic> toJson() {
```

### UISettings

```dart
return UISettings( colorScheme: PieceColorScheme.values[json['colorScheme'] ?? 0], customColors: customColors, showPieceNumbers: json['showPieceNumbers'] ?? true, showGridLines: json['showGridLines'] ?? false, enableAnimations: json['enableAnimations'] ?? true, pieceOpacity: json['pieceOpacity'] ?? 1.0, isometriesAppBarColor: Color(json['isometriesAppBarColor'] ?? 0xFF9575CD), iconSize: json['iconSize'] ?? 28.0, );
```

### GameSettings

Paramètres de jeu


```dart
const GameSettings({
```

### copyWith

```dart
GameSettings copyWith({
```

### GameSettings

```dart
return GameSettings( difficulty: difficulty ?? this.difficulty, showSolutionCounter: showSolutionCounter ?? this.showSolutionCounter, enableHints: enableHints ?? this.enableHints, enableTimer: enableTimer ?? this.enableTimer, enableHaptics: enableHaptics ?? this.enableHaptics, longPressDuration: longPressDuration ?? this.longPressDuration, );
```

### toJson

```dart
Map<String, dynamic> toJson() {
```

### GameSettings

```dart
return GameSettings( difficulty: GameDifficulty.values[json['difficulty'] ?? 1], showSolutionCounter: json['showSolutionCounter'] ?? true, enableHints: json['enableHints'] ?? false, enableTimer: json['enableTimer'] ?? false, enableHaptics: json['enableHaptics'] ?? true, longPressDuration: json['longPressDuration'] ?? 200, );
```

### DuelSettings

Paramètres du mode Duel - VERSION ENRICHIE


```dart
const DuelSettings({
```

### copyWith

Durée effective en secondes
Durée formatée pour affichage
Taux de victoire en pourcentage


```dart
DuelSettings copyWith({
```

### DuelSettings

```dart
return DuelSettings( playerName: clearPlayerName ? null : (playerName ?? this.playerName), duration: duration ?? this.duration, customDurationSeconds: customDurationSeconds ?? this.customDurationSeconds, showSolutionGuide: showSolutionGuide ?? this.showSolutionGuide, guideOpacity: guideOpacity ?? this.guideOpacity, showPieceNumbers: showPieceNumbers ?? this.showPieceNumbers, enableSounds: enableSounds ?? this.enableSounds, enableVibration: enableVibration ?? this.enableVibration, showOpponentProgress: showOpponentProgress ?? this.showOpponentProgress, showHatchOnOpponent: showHatchOnOpponent ?? this.showHatchOnOpponent, hatchOpacity: hatchOpacity ?? this.hatchOpacity, totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed, totalWins: totalWins ?? this.totalWins, totalLosses: totalLosses ?? this.totalLosses, totalDraws: totalDraws ?? this.totalDraws, );
```

### recordGame

Incrémenter les stats après une partie


```dart
DuelSettings recordGame({required bool? isWin}) {
```

### copyWith

```dart
return copyWith( totalGamesPlayed: totalGamesPlayed + 1, totalWins: isWin == true ? totalWins + 1 : totalWins, totalLosses: isWin == false ? totalLosses + 1 : totalLosses, totalDraws: isWin == null ? totalDraws + 1 : totalDraws, );
```

### resetStats

Réinitialiser les stats uniquement


```dart
DuelSettings resetStats() {
```

### copyWith

```dart
return copyWith( totalGamesPlayed: 0, totalWins: 0, totalLosses: 0, totalDraws: 0, );
```

### toJson

```dart
Map<String, dynamic> toJson() {
```

### DuelSettings

```dart
return DuelSettings( playerName: json['playerName'] as String?, duration: DuelDuration.values[json['duration'] ?? 1], customDurationSeconds: json['customDurationSeconds'] ?? 180, showSolutionGuide: json['showSolutionGuide'] ?? true, guideOpacity: (json['guideOpacity'] ?? 0.35).toDouble(), showPieceNumbers: json['showPieceNumbers'] ?? true, enableSounds: json['enableSounds'] ?? true, enableVibration: json['enableVibration'] ?? true, showOpponentProgress: json['showOpponentProgress'] ?? true, showHatchOnOpponent: json['showHatchOnOpponent'] ?? true, hatchOpacity: (json['hatchOpacity'] ?? 0.4).toDouble(), totalGamesPlayed: json['totalGamesPlayed'] ?? 0, totalWins: json['totalWins'] ?? 0, totalLosses: json['totalLosses'] ?? 0, totalDraws: json['totalDraws'] ?? 0, );
```

### AppSettings

Paramètres globaux de l'application


```dart
const AppSettings({
```

### copyWith

```dart
AppSettings copyWith({
```

### AppSettings

```dart
return AppSettings( ui: ui ?? this.ui, game: game ?? this.game, duel: duel ?? this.duel, );
```

### toJson

```dart
Map<String, dynamic> toJson() {
```

### AppSettings

```dart
return AppSettings( ui: UISettings.fromJson(json['ui'] ?? {}),
```

