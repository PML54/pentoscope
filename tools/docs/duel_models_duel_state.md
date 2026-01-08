# duel/models/duel_state.dart

**Module:** duel

## Fonctions

### DuelState

État d'une partie duel
Code de la room (ex: "ABC123")
État de la connexion
État de la partie
Joueur local (moi)
Joueur adverse
ID de la solution choisie (parmi les 9356)
Pièces placées sur le plateau partagé
Temps restant en secondes
Message d'erreur éventuel
Compte à rebours avant démarrage (3, 2, 1, null)


```dart
const DuelState({
```

### copyWith

État initial
Copie avec modifications


```dart
DuelState copyWith({
```

### DuelState

```dart
return DuelState( roomCode: clearRoomCode ? null : (roomCode ?? this.roomCode), connectionState: connectionState ?? this.connectionState, gameState: gameState ?? this.gameState, localPlayer: clearLocalPlayer ? null : (localPlayer ?? this.localPlayer), opponent: clearOpponent ? null : (opponent ?? this.opponent), solutionId: clearSolutionId ? null : (solutionId ?? this.solutionId), placedPieces: placedPieces ?? this.placedPieces, timeRemaining: clearTimeRemaining ? null : (timeRemaining ?? this.timeRemaining), errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage), countdown: clearCountdown ? null : (countdown ?? this.countdown), );
```

### DuelPlayer

Score du joueur local
Score de l'adversaire
La partie est-elle en cours ?
La partie est-elle terminée ?
Suis-je le gagnant ?
Est-ce une égalité ?
En attente d'un adversaire ?
État de la connexion WebSocket
État de la partie
Joueur dans une partie duel


```dart
const DuelPlayer({
```

### copyWith

```dart
DuelPlayer copyWith({
```

### DuelPlayer

```dart
return DuelPlayer( id: id ?? this.id, name: name ?? this.name, isReady: isReady ?? this.isReady, isConnected: isConnected ?? this.isConnected, );
```

### toJson

```dart
Map<String, dynamic> toJson() => {
```

### DuelPlayer

```dart
return DuelPlayer( id: json['id'] as String, name: json['name'] as String, isReady: json['isReady'] as bool? ?? false, isConnected: json['isConnected'] as bool? ?? true, );
```

### DuelPlacedPiece

Pièce placée dans une partie duel


```dart
const DuelPlacedPiece({
```

### toJson

```dart
Map<String, dynamic> toJson() => {
```

### DuelPlacedPiece

```dart
return DuelPlacedPiece( pieceId: json['pieceId'] as int, x: json['x'] as int, y: json['y'] as int, orientation: json['orientation'] as int, ownerId: json['ownerId'] as String, ownerName: json['ownerName'] as String, timestamp: json['timestamp'] as int, );
```

### isOwnedBy

Cette pièce appartient-elle à ce joueur ?


```dart
bool isOwnedBy(String playerId) => ownerId == playerId;
```

