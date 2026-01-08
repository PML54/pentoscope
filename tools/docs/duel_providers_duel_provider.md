# duel/providers/duel_provider.dart

**Module:** duel

## Fonctions

### DuelNotifier

Configuration du serveur
Provider pour l'état du duel


```dart
return DuelNotifier();
```

### build

Notifier pour gérer l'état du duel
Service WebSocket
Subscription aux messages
Subscription à l'état de connexion
Timer pour le compte à rebours local
Nom du joueur local


```dart
DuelState build() {
```

### createRoom

Créer une nouvelle room


```dart
Future<bool> createRoom(String playerName) async {
```

### joinRoom

Rejoindre une room existante


```dart
Future<bool> joinRoom(String roomCode, String playerName) async {
```

### leaveRoom

Quitter la room actuelle


```dart
void leaveRoom() {
```

### placePiece

Placer une pièce


```dart
void placePiece({
```

### setReady

Signaler que le joueur est prêt


```dart
void setReady() {
```

