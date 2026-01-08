// lib/pentoscope_multiplayer/models/pentoscope_mp_state.dart
// États du jeu Pentoscope Multiplayer (1-4 joueurs)

import 'package:pentapol/pentoscope/pentoscope_generator.dart';

/// États possibles du jeu multiplayer
enum PentoscopeMPGameState {
  /// Pas encore connecté
  disconnected,
  
  /// Connexion en cours
  connecting,
  
  /// Attente de joueurs dans la room
  waiting,
  
  /// Countdown avant le départ (3, 2, 1...)
  countdown,
  
  /// Partie en cours
  playing,
  
  /// Partie terminée
  finished,
  
  /// Erreur de connexion
  error,
}

/// Résumé d'une pièce placée (pour affichage mini-plateau)
class MPPlacedPiece {
  final int pieceId;
  final int x;
  final int y;
  final int positionIndex;

  const MPPlacedPiece({
    required this.pieceId,
    required this.x,
    required this.y,
    required this.positionIndex,
  });

  factory MPPlacedPiece.fromJson(Map<String, dynamic> json) {
    return MPPlacedPiece(
      pieceId: json['pieceId'] as int,
      x: (json['x'] ?? json['gridX']) as int,
      y: (json['y'] ?? json['gridY']) as int,
      positionIndex: json['positionIndex'] as int,
    );
  }
}

/// Informations sur un joueur
class MPPlayer {
  final String id;
  final String name;
  final bool isMe;
  final bool isHost;
  
  /// Nombre de pièces placées (progression)
  final int placedCount;
  
  /// Détails des pièces placées (pour affichage mini-plateau)
  final List<MPPlacedPiece> placedPieces;
  
  /// Temps de complétion (null si pas terminé)
  final int? completionTime;
  
  /// Rang final (1 = premier, null si pas terminé)
  final int? rank;
  
  /// Connecté ou déconnecté
  final bool isConnected;

  const MPPlayer({
    required this.id,
    required this.name,
    this.isMe = false,
    this.isHost = false,
    this.placedCount = 0,
    this.placedPieces = const [],
    this.completionTime,
    this.rank,
    this.isConnected = true,
  });

  /// Le joueur a terminé ?
  bool get isCompleted => completionTime != null;

  MPPlayer copyWith({
    String? id,
    String? name,
    bool? isMe,
    bool? isHost,
    int? placedCount,
    List<MPPlacedPiece>? placedPieces,
    int? completionTime,
    bool clearCompletionTime = false,
    int? rank,
    bool clearRank = false,
    bool? isConnected,
  }) {
    return MPPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      isMe: isMe ?? this.isMe,
      isHost: isHost ?? this.isHost,
      placedCount: placedCount ?? this.placedCount,
      placedPieces: placedPieces ?? this.placedPieces,
      completionTime: clearCompletionTime ? null : (completionTime ?? this.completionTime),
      rank: clearRank ? null : (rank ?? this.rank),
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  String toString() => 'MPPlayer($name, placed: $placedCount, rank: $rank)';
}

/// Configuration de la partie
class MPGameConfig {
  /// Format du plateau (ex: "5x5", "6x5", "7x5")
  final String format;
  
  /// Largeur du plateau
  final int width;
  
  /// Hauteur du plateau
  final int height;
  
  /// Nombre de pièces
  final int pieceCount;
  
  /// Temps limite en secondes (0 = pas de limite)
  final int timeLimit;

  const MPGameConfig({
    required this.format,
    required this.width,
    required this.height,
    required this.pieceCount,
    this.timeLimit = 0,
  });

  /// Crée une config à partir d'un PentoscopeSize
  factory MPGameConfig.fromSize(PentoscopeSize size, {int timeLimit = 0}) {
    return MPGameConfig(
      format: '${size.width}x${size.height}',
      width: size.width,
      height: size.height,
      pieceCount: size.numPieces,
      timeLimit: timeLimit,
    );
  }

  /// Crée une config à partir d'un format string
  factory MPGameConfig.fromFormat(String format, {int timeLimit = 0}) {
    final parts = format.split('x');
    final width = int.parse(parts[0]);
    final height = int.parse(parts[1]);
    final pieceCount = (width * height) ~/ 5; // 5 cellules par pièce
    
    return MPGameConfig(
      format: format,
      width: width,
      height: height,
      pieceCount: pieceCount,
      timeLimit: timeLimit,
    );
  }

  /// Convertit en PentoscopeSize
  PentoscopeSize toPentoscopeSize() {
    return PentoscopeSize.values.firstWhere(
      (s) => s.width == width && s.height == height,
      orElse: () => PentoscopeSize.size5x5,
    );
  }

  @override
  String toString() => 'MPGameConfig($format, $pieceCount pièces)';
}

/// État global du jeu multiplayer
class PentoscopeMPState {
  /// État actuel du jeu
  final PentoscopeMPGameState gameState;
  
  /// Code de la room (ex: "ABCD")
  final String? roomCode;
  
  /// ID du joueur local
  final String? myPlayerId;
  
  /// Configuration de la partie
  final MPGameConfig? config;
  
  /// Liste des joueurs (incluant moi)
  final List<MPPlayer> players;
  
  /// Seed pour générer le puzzle (identique pour tous)
  final int? seed;
  
  /// IDs des pièces à utiliser
  final List<int>? pieceIds;
  
  /// Valeur du countdown (3, 2, 1, 0)
  final int? countdownValue;
  
  /// Temps écoulé depuis le début (en secondes)
  final int elapsedSeconds;
  
  /// Message d'erreur éventuel
  final String? errorMessage;
  
  /// Suis-je le host (créateur de la room) ?
  final bool isHost;

  const PentoscopeMPState({
    this.gameState = PentoscopeMPGameState.disconnected,
    this.roomCode,
    this.myPlayerId,
    this.config,
    this.players = const [],
    this.seed,
    this.pieceIds,
    this.countdownValue,
    this.elapsedSeconds = 0,
    this.errorMessage,
    this.isHost = false,
  });

  /// État initial
  factory PentoscopeMPState.initial() => const PentoscopeMPState();

  /// Mon joueur
  MPPlayer? get me => players.where((p) => p.isMe).firstOrNull;

  /// Les adversaires (tous sauf moi)
  List<MPPlayer> get opponents => players.where((p) => !p.isMe).toList();

  /// Nombre de joueurs connectés
  int get playerCount => players.where((p) => p.isConnected).length;

  /// La partie peut commencer ? (≥2 joueurs et je suis host)
  bool get canStart => isHost && playerCount >= 2 && gameState == PentoscopeMPGameState.waiting;

  /// Classement actuel (triés par temps de complétion)
  List<MPPlayer> get rankings {
    final completed = players.where((p) => p.isCompleted).toList();
    completed.sort((a, b) => a.completionTime!.compareTo(b.completionTime!));
    
    final notCompleted = players.where((p) => !p.isCompleted).toList();
    notCompleted.sort((a, b) => b.placedCount.compareTo(a.placedCount));
    
    return [...completed, ...notCompleted];
  }

  /// Tous les joueurs ont terminé ?
  bool get allCompleted => players.isNotEmpty && players.every((p) => p.isCompleted);

  PentoscopeMPState copyWith({
    PentoscopeMPGameState? gameState,
    String? roomCode,
    bool clearRoomCode = false,
    String? myPlayerId,
    bool clearMyPlayerId = false,
    MPGameConfig? config,
    bool clearConfig = false,
    List<MPPlayer>? players,
    int? seed,
    bool clearSeed = false,
    List<int>? pieceIds,
    bool clearPieceIds = false,
    int? countdownValue,
    bool clearCountdownValue = false,
    int? elapsedSeconds,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isHost,
  }) {
    return PentoscopeMPState(
      gameState: gameState ?? this.gameState,
      roomCode: clearRoomCode ? null : (roomCode ?? this.roomCode),
      myPlayerId: clearMyPlayerId ? null : (myPlayerId ?? this.myPlayerId),
      config: clearConfig ? null : (config ?? this.config),
      players: players ?? this.players,
      seed: clearSeed ? null : (seed ?? this.seed),
      pieceIds: clearPieceIds ? null : (pieceIds ?? this.pieceIds),
      countdownValue: clearCountdownValue ? null : (countdownValue ?? this.countdownValue),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isHost: isHost ?? this.isHost,
    );
  }

  @override
  String toString() => 'PentoscopeMPState($gameState, room: $roomCode, players: ${players.length})';
}

