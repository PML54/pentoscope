# duel/services/websocket_service.dart

**Module:** duel

## Fonctions

### connect

Service de connexion WebSocket
URL du serveur WebSocket
Canal WebSocket
Stream controller pour les messages reçus
Stream controller pour l'état de connexion
État actuel de la connexion
Timer pour le ping/pong (keep-alive)
Timer pour la reconnexion
Nombre de tentatives de reconnexion
Stream des messages reçus
Stream de l'état de connexion
État actuel
Est connecté ?
Se connecter au serveur


```dart
Future<bool> connect() async {
```

### disconnect

Se déconnecter


```dart
Future<void> disconnect() async {
```

### send

Envoyer un message


```dart
void send(ClientMessage message) {
```

### sendRaw

Envoyer un message brut (pour debug)


```dart
void sendRaw(String message) {
```

### connect

```dart
await connect();
```

### dispose

```dart
void dispose() {
```

