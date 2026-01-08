# duel/models/duel_messages.dart

**Module:** duel

## Fonctions

### toJson

Types de messages client → serveur
Types de messages serveur → client
Message de base client


```dart
Map<String, dynamic> toJson();
```

### encode

```dart
String encode() => jsonEncode({
```

### toJson

Créer une room


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Rejoindre une room


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Quitter une room


```dart
Map<String, dynamic> toJson() => {};
```

### toJson

Placer une pièce


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Joueur prêt


```dart
Map<String, dynamic> toJson() => {};
```

### toJson

Ping (keep-alive)


```dart
Map<String, dynamic> toJson() => {};
```

### PongMessage

Message de base serveur
Parse un message JSON du serveur


```dart
return PongMessage();
```

### RoomCreatedMessage

Room créée


```dart
return RoomCreatedMessage( roomCode: json['roomCode'] as String, playerId: json['playerId'] as String, );
```

### RoomJoinedMessage

Room rejointe


```dart
return RoomJoinedMessage( roomCode: json['roomCode'] as String, playerId: json['playerId'] as String, opponentId: json['opponentId'] as String?, opponentName: json['opponentName'] as String?, );
```

### PlayerJoinedMessage

Joueur a rejoint


```dart
return PlayerJoinedMessage( playerId: json['playerId'] as String, playerName: json['playerName'] as String, );
```

### PlayerLeftMessage

Joueur a quitté


```dart
return PlayerLeftMessage( playerId: json['playerId'] as String, );
```

### GameStartMessage

Partie commence


```dart
return GameStartMessage( solutionId: json['solutionId'] as int, timeLimit: json['timeLimit'] as int, );
```

### CountdownMessage

Compte à rebours


```dart
return CountdownMessage( value: json['value'] as int, );
```

### PiecePlacedMessage

Pièce placée (broadcast)


```dart
return PiecePlacedMessage( pieceId: json['pieceId'] as int, x: json['x'] as int, y: json['y'] as int, orientation: json['orientation'] as int, // Fallback: accepte ownerId OU playerId ownerId: (json['ownerId'] ?? json['playerId']) as String, ownerName: (json['ownerName'] ?? json['playerName']) as String, // Fallback: timestamp optionnel timestamp: (json['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch, );
```

### PlacementRejectedMessage

Placement refusé


```dart
return PlacementRejectedMessage( pieceId: (json['pieceId'] as int?) ?? 0, reason: json['reason'] as String, );
```

### GameStateMessage

État complet du jeu (synchronisation)


```dart
return GameStateMessage( players: (json['players'] as List).cast<Map<String, dynamic>>(), placedPieces: (json['placedPieces'] as List).cast<Map<String, dynamic>>(), timeRemaining: json['timeRemaining'] as int, );
```

### GameEndMessage

Fin de partie


```dart
return GameEndMessage( winnerId: json['winnerId'] as String, winnerName: json['winnerName'] as String, winnerScore: json['winnerScore'] as int, loserId: json['loserId'] as String, loserName: json['loserName'] as String, loserScore: json['loserScore'] as int, reason: json['reason'] as String, );
```

### isDraw

```dart
bool isDraw() => winnerScore == loserScore;
```

### ErrorMessage

Erreur


```dart
return ErrorMessage( code: json['code'] as String, message: json['message'] as String, );
```

