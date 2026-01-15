# pentoscope_multiplayer/providers/pentoscope_mp_provider.dart

**Module:** pentoscope_multiplayer

## Fonctions

### build

URL du serveur HTTP
URL du serveur WebSocket
Canal WebSocket
Subscription aux messages
Timer pour le chrono
Timer ping/pong


```dart
PentoscopeMPState build() {
```

### createRoom

Créer une room (Host)


```dart
Future<bool> createRoom({
```

### Exception

```dart
throw Exception('Erreur création room: ${createResponse.statusCode}');
```

### joinRoom

Rejoindre une room


```dart
Future<bool> joinRoom({
```

### Exception

```dart
throw Exception('Room introuvable');
```

### Exception

```dart
throw Exception('Room introuvable ou fermée');
```

### leaveRoom

Quitter la room


```dart
Future<void> leaveRoom() async {
```

### startGame

Lancer la partie (Host uniquement)


```dart
Future<void> startGame() async {
```

### updateProgress

Mettre à jour la progression


```dart
void updateProgress(int placedCount, {List<PlacedPieceSummary>? placedPieces}) {
```

### complete

Puzzle terminé !


```dart
void complete() {
```

### startTimer

Démarre le chronomètre


```dart
void startTimer() {
```

### stopTimer

Arrête le chronomètre


```dart
void stopTimer() {
```

### getElapsedSeconds

Retourne le temps écoulé en secondes


```dart
int getElapsedSeconds() {
```

