// lib/pentoscope_multiplayer/models/pentoscope_mp_messages.dart
// Messages WebSocket pour Pentoscope Multiplayer

import 'dart:convert';

/// Types de messages Client → Serveur
enum MPClientMessageType {
  createRoom,
  joinRoom,
  startGame,
  progress,
  completed,
  leaveRoom,
}

/// Types de messages Serveur → Client
enum MPServerMessageType {
  roomCreated,
  roomJoined,
  playerJoined,
  playerLeft,
  puzzleReady,
  countdown,
  gameStart,
  opponentProgress,
  playerCompleted,
  gameEnd,
  error,
}

// ============================================================================
// MESSAGES CLIENT → SERVEUR
// ============================================================================

/// Message de base client
abstract class MPClientMessage {
  String get type;
  Map<String, dynamic> toJson();
  
  String encode() => jsonEncode(toJson());
}

/// Créer une room (Host)
class CreateRoomMessage extends MPClientMessage {
  final String playerName;
  final String format; // ex: "7x5"
  final int timeLimit; // 0 = pas de limite

  CreateRoomMessage({
    required this.playerName,
    required this.format,
    this.timeLimit = 0,
  });

  @override
  String get type => 'create_room';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'playerName': playerName,
    'format': format,
    'timeLimit': timeLimit,
  };
}

/// Rejoindre une room
class JoinRoomMessage extends MPClientMessage {
  final String roomCode;
  final String playerName;

  JoinRoomMessage({
    required this.roomCode,
    required this.playerName,
  });

  @override
  String get type => 'join_room';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'roomCode': roomCode,
    'playerName': playerName,
  };
}

/// Lancer la partie (Host uniquement)
class StartGameMessage extends MPClientMessage {
  final int seed;
  final List<int> pieceIds;

  StartGameMessage({
    required this.seed,
    required this.pieceIds,
  });

  @override
  String get type => 'start_game';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'seed': seed,
    'pieceIds': pieceIds,
  };
}

/// Progression (pièce placée/retirée)
class ProgressMessage extends MPClientMessage {
  final int placedCount;
  
  /// Optionnel : détails des pièces placées pour afficher le mini-plateau
  final List<PlacedPieceSummary>? placedPieces;

  ProgressMessage({
    required this.placedCount,
    this.placedPieces,
  });

  @override
  String get type => 'progress';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'placedCount': placedCount,
    if (placedPieces != null) 
      'placedPieces': placedPieces!.map((p) => p.toJson()).toList(),
  };
}

/// Résumé d'une pièce placée (pour sync mini-plateau)
class PlacedPieceSummary {
  final int pieceId;
  final int x;
  final int y;
  final int positionIndex;

  PlacedPieceSummary({
    required this.pieceId,
    required this.x,
    required this.y,
    required this.positionIndex,
  });

  Map<String, dynamic> toJson() => {
    'pieceId': pieceId,
    'x': x,
    'y': y,
    'positionIndex': positionIndex,
  };

  factory PlacedPieceSummary.fromJson(Map<String, dynamic> json) {
    return PlacedPieceSummary(
      pieceId: json['pieceId'] as int,
      x: json['x'] as int,
      y: json['y'] as int,
      positionIndex: json['positionIndex'] as int,
    );
  }
}

/// Puzzle terminé !
class CompletedMessage extends MPClientMessage {
  final int time; // Temps en secondes

  CompletedMessage({required this.time});

  @override
  String get type => 'completed';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'time': time,
  };
}

/// Quitter la room
class LeaveRoomMessage extends MPClientMessage {
  @override
  String get type => 'leave_room';

  @override
  Map<String, dynamic> toJson() => {'type': type};
}

// ============================================================================
// MESSAGES SERVEUR → CLIENT
// ============================================================================

/// Message de base serveur
abstract class MPServerMessage {
  static MPServerMessage? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    
    // Accepter camelCase et snake_case
    switch (type) {
      case 'roomCreated':
      case 'room_created':
        return RoomCreatedMessage.fromJson(json);
      case 'roomJoined':
      case 'room_joined':
        return RoomJoinedMessage.fromJson(json);
      case 'playerJoined':
      case 'player_joined':
        return PlayerJoinedMessage.fromJson(json);
      case 'playerLeft':
      case 'player_left':
        return PlayerLeftMessage.fromJson(json);
      case 'puzzleReady':
      case 'puzzle_ready':
        return PuzzleReadyMessage.fromJson(json);
      case 'countdown':
        return CountdownMessage.fromJson(json);
      case 'gameStart':
      case 'game_start':
        return GameStartMessage.fromJson(json);
      case 'opponentProgress':
      case 'opponent_progress':
        return OpponentProgressMessage.fromJson(json);
      case 'playerCompleted':
      case 'player_completed':
        return PlayerCompletedMessage.fromJson(json);
      case 'gameEnd':
      case 'game_end':
        return GameEndMessage.fromJson(json);
      case 'error':
        return ErrorMessage.fromJson(json);
      case 'pong':
        return null; // Ignorer les pongs
      case 'hostTransferred':
        return null; // TODO: gérer si besoin
      default:
        return null;
    }
  }

  static MPServerMessage? decode(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }
}

/// Room créée (pour le Host)
class RoomCreatedMessage extends MPServerMessage {
  final String roomCode;
  final String playerId;

  RoomCreatedMessage({
    required this.roomCode,
    required this.playerId,
  });

  factory RoomCreatedMessage.fromJson(Map<String, dynamic> json) {
    return RoomCreatedMessage(
      roomCode: json['roomCode'] as String,
      playerId: json['playerId'] as String,
    );
  }
}

/// Room rejointe (pour les Guests)
class RoomJoinedMessage extends MPServerMessage {
  final String roomCode;
  final String playerId;
  final String format;
  final int timeLimit;
  final List<PlayerInfo> players;

  RoomJoinedMessage({
    required this.roomCode,
    required this.playerId,
    required this.format,
    required this.timeLimit,
    required this.players,
  });

  factory RoomJoinedMessage.fromJson(Map<String, dynamic> json) {
    final playersList = (json['players'] as List?)
        ?.map((p) => PlayerInfo.fromJson(p as Map<String, dynamic>))
        .toList() ?? [];
    
    return RoomJoinedMessage(
      roomCode: json['roomCode'] as String,
      playerId: json['playerId'] as String,
      format: json['format'] as String? ?? '5x5',
      timeLimit: json['timeLimit'] as int? ?? 0,
      players: playersList,
    );
  }
}

/// Info basique d'un joueur
class PlayerInfo {
  final String id;
  final String name;
  final bool isHost;

  PlayerInfo({
    required this.id,
    required this.name,
    this.isHost = false,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      isHost: json['isHost'] as bool? ?? false,
    );
  }
}

/// Un joueur a rejoint
class PlayerJoinedMessage extends MPServerMessage {
  final String playerId;
  final String playerName;

  PlayerJoinedMessage({
    required this.playerId,
    required this.playerName,
  });

  factory PlayerJoinedMessage.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedMessage(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
    );
  }
}

/// Un joueur a quitté
class PlayerLeftMessage extends MPServerMessage {
  final String playerId;

  PlayerLeftMessage({required this.playerId});

  factory PlayerLeftMessage.fromJson(Map<String, dynamic> json) {
    return PlayerLeftMessage(
      playerId: json['playerId'] as String,
    );
  }
}

/// Puzzle prêt (envoyé à tous après start_game du Host)
class PuzzleReadyMessage extends MPServerMessage {
  final int seed;
  final List<int> pieceIds;
  final String format;
  final int width;
  final int height;
  final int pieceCount;
  final int timeLimit;

  PuzzleReadyMessage({
    required this.seed,
    required this.pieceIds,
    required this.format,
    required this.width,
    required this.height,
    required this.pieceCount,
    required this.timeLimit,
  });

  factory PuzzleReadyMessage.fromJson(Map<String, dynamic> json) {
    // Config peut être dans json['config'] ou directement dans json
    final config = json['config'] as Map<String, dynamic>? ?? json;
    
    return PuzzleReadyMessage(
      seed: json['seed'] as int? ?? 0,
      pieceIds: (json['pieceIds'] as List?)?.cast<int>() ?? [],
      format: config['format'] as String? ?? '5x5',
      width: config['width'] as int? ?? 5,
      height: config['height'] as int? ?? 5,
      pieceCount: config['pieceCount'] as int? ?? 5,
      timeLimit: config['timeLimit'] as int? ?? 0,
    );
  }
}

/// Countdown (3, 2, 1, 0)
class CountdownMessage extends MPServerMessage {
  final int value;

  CountdownMessage({required this.value});

  factory CountdownMessage.fromJson(Map<String, dynamic> json) {
    return CountdownMessage(
      value: json['value'] as int,
    );
  }
}

/// Départ !
class GameStartMessage extends MPServerMessage {
  GameStartMessage();
  
  factory GameStartMessage.fromJson(Map<String, dynamic> json) {
    return GameStartMessage();
  }
}

/// Progression d'un adversaire
class OpponentProgressMessage extends MPServerMessage {
  final String playerId;
  final int placedCount;
  final List<PlacedPieceSummary>? placedPieces;

  OpponentProgressMessage({
    required this.playerId,
    required this.placedCount,
    this.placedPieces,
  });

  factory OpponentProgressMessage.fromJson(Map<String, dynamic> json) {
    List<PlacedPieceSummary>? pieces;
    if (json['placedPieces'] != null) {
      pieces = (json['placedPieces'] as List)
          .map((p) => PlacedPieceSummary.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    
    return OpponentProgressMessage(
      playerId: json['playerId'] as String,
      placedCount: json['placedCount'] as int,
      placedPieces: pieces,
    );
  }
}

/// Un joueur a terminé
class PlayerCompletedMessage extends MPServerMessage {
  final String playerId;
  final String playerName;
  final int timeMs;
  final int rank;

  PlayerCompletedMessage({
    required this.playerId,
    required this.playerName,
    required this.timeMs,
    required this.rank,
  });

  factory PlayerCompletedMessage.fromJson(Map<String, dynamic> json) {
    return PlayerCompletedMessage(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String? ?? '',
      timeMs: json['timeMs'] as int? ?? json['time'] as int? ?? 0,
      rank: json['rank'] as int,
    );
  }
}

/// Fin de partie
class GameEndMessage extends MPServerMessage {
  final List<RankingEntry> rankings;

  GameEndMessage({required this.rankings});

  factory GameEndMessage.fromJson(Map<String, dynamic> json) {
    final rankingsList = (json['rankings'] as List)
        .map((r) => RankingEntry.fromJson(r as Map<String, dynamic>))
        .toList();
    
    return GameEndMessage(rankings: rankingsList);
  }
}

/// Entrée de classement
class RankingEntry {
  final String playerId;
  final String playerName;
  final int? timeMs; // null si pas terminé
  final int rank;
  final bool isComplete;
  final int placedCount;

  RankingEntry({
    required this.playerId,
    required this.playerName,
    this.timeMs,
    required this.rank,
    this.isComplete = false,
    this.placedCount = 0,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String? ?? json['name'] as String? ?? '',
      timeMs: json['timeMs'] as int? ?? json['time'] as int?,
      rank: json['rank'] as int,
      isComplete: json['isComplete'] as bool? ?? false,
      placedCount: json['placedCount'] as int? ?? 0,
    );
  }
}

/// Message d'erreur
class ErrorMessage extends MPServerMessage {
  final String message;
  final String? code;

  ErrorMessage({
    required this.message,
    this.code,
  });

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }
}

