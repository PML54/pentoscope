# pentoscope_multiplayer/models/pentoscope_mp_state.dart

**Module:** pentoscope_multiplayer

## Fonctions

### MPPlacedPiece

États possibles du jeu multiplayer
Pas encore connecté
Connexion en cours
Attente de joueurs dans la room
Countdown avant le départ (3, 2, 1...)
Partie en cours
Partie terminée
Erreur de connexion
Résumé d'une pièce placée (pour affichage mini-plateau)


```dart
const MPPlacedPiece({
```

### MPPlacedPiece

```dart
return MPPlacedPiece( pieceId: json['pieceId'] as int, x: (json['x'] ?? json['gridX']) as int, y: (json['y'] ?? json['gridY']) as int, positionIndex: json['positionIndex'] as int, );
```

### MPPlayer

Informations sur un joueur
Nombre de pièces placées (progression)
Détails des pièces placées (pour affichage mini-plateau)
Temps de complétion (null si pas terminé)
Rang final (1 = premier, null si pas terminé)
Connecté ou déconnecté


```dart
const MPPlayer({
```

### copyWith

Le joueur a terminé ?


```dart
MPPlayer copyWith({
```

### MPPlayer

```dart
return MPPlayer( id: id ?? this.id, name: name ?? this.name, isMe: isMe ?? this.isMe, isHost: isHost ?? this.isHost, placedCount: placedCount ?? this.placedCount, placedPieces: placedPieces ?? this.placedPieces, completionTime: clearCompletionTime ? null : (completionTime ?? this.completionTime), rank: clearRank ? null : (rank ?? this.rank), isConnected: isConnected ?? this.isConnected, );
```

### toString

```dart
String toString() => 'MPPlayer($name, placed: $placedCount, rank: $rank)';
```

### MPGameConfig

Configuration de la partie
Format du plateau (ex: "5x5", "6x5", "7x5")
Largeur du plateau
Hauteur du plateau
Nombre de pièces
Temps limite en secondes (0 = pas de limite)


```dart
const MPGameConfig({
```

### MPGameConfig

Crée une config à partir d'un PentoscopeSize


```dart
return MPGameConfig( format: '${size.width}x${size.height}',
```

### MPGameConfig

Crée une config à partir d'un format string


```dart
return MPGameConfig( format: format, width: width, height: height, pieceCount: pieceCount, timeLimit: timeLimit, );
```

### toPentoscopeSize

Convertit en PentoscopeSize


```dart
PentoscopeSize toPentoscopeSize() {
```

### toString

```dart
String toString() => 'MPGameConfig($format, $pieceCount pièces)';
```

### PentoscopeMPState

État global du jeu multiplayer
État actuel du jeu
Code de la room (ex: "ABCD")
ID du joueur local
Configuration de la partie
Liste des joueurs (incluant moi)
Seed pour générer le puzzle (identique pour tous)
IDs des pièces à utiliser
Valeur du countdown (3, 2, 1, 0)
Temps écoulé depuis le début (en secondes)
Message d'erreur éventuel
Suis-je le host (créateur de la room) ?


```dart
const PentoscopeMPState({
```

### copyWith

État initial
Mon joueur
Les adversaires (tous sauf moi)
Nombre de joueurs connectés
La partie peut commencer ? (≥2 joueurs et je suis host)
Classement actuel (triés par temps de complétion)
Tous les joueurs ont terminé ?


```dart
PentoscopeMPState copyWith({
```

### PentoscopeMPState

```dart
return PentoscopeMPState( gameState: gameState ?? this.gameState, roomCode: clearRoomCode ? null : (roomCode ?? this.roomCode), myPlayerId: clearMyPlayerId ? null : (myPlayerId ?? this.myPlayerId), config: clearConfig ? null : (config ?? this.config), players: players ?? this.players, seed: clearSeed ? null : (seed ?? this.seed), pieceIds: clearPieceIds ? null : (pieceIds ?? this.pieceIds), countdownValue: clearCountdownValue ? null : (countdownValue ?? this.countdownValue), elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds, errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage), isHost: isHost ?? this.isHost, );
```

### toString

```dart
String toString() => 'PentoscopeMPState($gameState, room: $roomCode, players: ${players.length})';
```

