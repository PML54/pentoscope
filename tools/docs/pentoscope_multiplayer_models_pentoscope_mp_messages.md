# pentoscope_multiplayer/models/pentoscope_mp_messages.dart

**Module:** pentoscope_multiplayer

## Fonctions

### toJson

Types de messages Client → Serveur
Types de messages Serveur → Client
Message de base client


```dart
Map<String, dynamic> toJson();
```

### encode

```dart
String encode() => jsonEncode(toJson());
```

### toJson

Créer une room (Host)


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Rejoindre une room


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Lancer la partie (Host uniquement)


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Progression (pièce placée/retirée)
Optionnel : détails des pièces placées pour afficher le mini-plateau


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Résumé d'une pièce placée (pour sync mini-plateau)


```dart
Map<String, dynamic> toJson() => {
```

### PlacedPieceSummary

```dart
return PlacedPieceSummary( pieceId: json['pieceId'] as int, x: json['x'] as int, y: json['y'] as int, positionIndex: json['positionIndex'] as int, );
```

### toJson

Puzzle terminé !


```dart
Map<String, dynamic> toJson() => {
```

### toJson

Quitter la room


```dart
Map<String, dynamic> toJson() => {'type': type};
```

### fromJson

Message de base serveur


```dart
return fromJson(json);
```

### RoomCreatedMessage

Room créée (pour le Host)


```dart
return RoomCreatedMessage( roomCode: json['roomCode'] as String, playerId: json['playerId'] as String, );
```

### RoomJoinedMessage

Room rejointe (pour les Guests)


```dart
return RoomJoinedMessage( roomCode: json['roomCode'] as String, playerId: json['playerId'] as String, format: json['format'] as String? ?? '5x5', timeLimit: json['timeLimit'] as int? ?? 0, players: playersList, );
```

### PlayerInfo

Info basique d'un joueur


```dart
return PlayerInfo( id: json['id'] as String, name: json['name'] as String, isHost: json['isHost'] as bool? ?? false, );
```

### PlayerJoinedMessage

Un joueur a rejoint


```dart
return PlayerJoinedMessage( playerId: json['playerId'] as String, playerName: json['playerName'] as String, );
```

### PlayerLeftMessage

Un joueur a quitté


```dart
return PlayerLeftMessage( playerId: json['playerId'] as String, );
```

### PuzzleReadyMessage

Puzzle prêt (envoyé à tous après start_game du Host)


```dart
return PuzzleReadyMessage( seed: json['seed'] as int? ?? 0, pieceIds: (json['pieceIds'] as List?)?.cast<int>() ?? [], format: config['format'] as String? ?? '5x5', width: config['width'] as int? ?? 5, height: config['height'] as int? ?? 5, pieceCount: config['pieceCount'] as int? ?? 5, timeLimit: config['timeLimit'] as int? ?? 0, );
```

### CountdownMessage

Countdown (3, 2, 1, 0)


```dart
return CountdownMessage( value: json['value'] as int, );
```

### GameStartMessage

Départ !


```dart
return GameStartMessage();
```

### OpponentProgressMessage

Progression d'un adversaire


```dart
return OpponentProgressMessage( playerId: json['playerId'] as String, placedCount: json['placedCount'] as int, placedPieces: pieces, );
```

### PlayerCompletedMessage

Un joueur a terminé


```dart
return PlayerCompletedMessage( playerId: json['playerId'] as String, playerName: json['playerName'] as String? ?? '', timeMs: json['timeMs'] as int? ?? json['time'] as int? ?? 0, rank: json['rank'] as int, );
```

### GameEndMessage

Fin de partie


```dart
return GameEndMessage(rankings: rankingsList);
```

### RankingEntry

Entrée de classement


```dart
return RankingEntry( playerId: json['playerId'] as String, playerName: json['playerName'] as String? ?? json['name'] as String? ?? '', timeMs: json['timeMs'] as int? ?? json['time'] as int?, rank: json['rank'] as int, isComplete: json['isComplete'] as bool? ?? false, placedCount: json['placedCount'] as int? ?? 0, );
```

### ErrorMessage

Message d'erreur


```dart
return ErrorMessage( message: json['message'] as String, code: json['code'] as String?, );
```

