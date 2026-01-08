// lib/pentoscope_multiplayer/providers/pentoscope_mp_provider.dart
// Provider Riverpod pour Pentoscope Multiplayer

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:pentapol/pentoscope/pentoscope_generator.dart';
import 'package:pentapol/pentoscope_multiplayer/models/pentoscope_mp_state.dart';
import 'package:pentapol/pentoscope_multiplayer/models/pentoscope_mp_messages.dart';

// ============================================================================
// PROVIDER
// ============================================================================

final pentoscopeMPProvider = NotifierProvider<PentoscopeMPNotifier, PentoscopeMPState>(
  PentoscopeMPNotifier.new,
);

// ============================================================================
// NOTIFIER
// ============================================================================

class PentoscopeMPNotifier extends Notifier<PentoscopeMPState> {
  /// URL du serveur HTTP
  static const String _serverHttpUrl = 'https://pentapol-duel.pentapml.workers.dev';
  
  /// URL du serveur WebSocket
  static const String _serverWsUrl = 'wss://pentapol-duel.pentapml.workers.dev';
  
  /// Canal WebSocket
  WebSocketChannel? _channel;
  
  /// Subscription aux messages
  StreamSubscription? _messageSubscription;
  
  /// Timer pour le chrono
  Timer? _gameTimer;
  DateTime? _startTime;
  
  /// Timer ping/pong
  Timer? _pingTimer;

  @override
  PentoscopeMPState build() {
    // Cleanup à la destruction
    ref.onDispose(() {
      _cleanup();
    });
    
    return PentoscopeMPState.initial();
  }

  // ==========================================================================
  // CONNEXION
  // ==========================================================================

  /// Créer une room (Host)
  Future<bool> createRoom({
    required String playerName,
    required PentoscopeSize size,
    int timeLimit = 0,
  }) async {
    if (state.gameState != PentoscopeMPGameState.disconnected) {
      debugPrint('[MP] ⚠️ Déjà connecté');
      return false;
    }

    state = state.copyWith(
      gameState: PentoscopeMPGameState.connecting,
      config: MPGameConfig.fromSize(size, timeLimit: timeLimit),
      isHost: true,
    );

    try {
      // 1. Créer la room via HTTP POST
      debugPrint('[MP] 📡 Création de la room: format=${state.config!.format}, ${size.width}x${size.height}, ${size.numPieces} pièces');
      final createResponse = await http.post(
        Uri.parse('$_serverHttpUrl/room/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'gameMode': 'pentoscope',
          'format': state.config!.format,
          'width': size.width,
          'height': size.height,
          'pieceCount': size.numPieces,
          'timeLimit': timeLimit,
        }),
      );

      if (createResponse.statusCode != 200) {
        throw Exception('Erreur création room: ${createResponse.statusCode}');
      }

      final createData = jsonDecode(createResponse.body);
      final roomCode = createData['roomCode'] as String;
      debugPrint('[MP] ✅ Room créée: $roomCode');

      // 2. Connexion WebSocket
      final wsUrl = '$_serverWsUrl/room/$roomCode/ws';
      debugPrint('[MP] 🔌 Connexion WebSocket à $wsUrl...');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;
      
      debugPrint('[MP] ✅ WebSocket connecté !');
      
      // Écouter les messages
      _messageSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      
      // Envoyer create_room (pour s'enregistrer comme host)
      _send(CreateRoomMessage(
        playerName: playerName,
        format: state.config!.format,
        timeLimit: timeLimit,
      ));
      
      // Stocker le roomCode
      state = state.copyWith(roomCode: roomCode);
      
      // Démarrer ping/pong
      _startPingTimer();
      
      return true;
    } catch (e) {
      debugPrint('[MP] ❌ Erreur de connexion: $e');
      state = state.copyWith(
        gameState: PentoscopeMPGameState.error,
        errorMessage: 'Impossible de se connecter au serveur',
      );
      return false;
    }
  }

  /// Rejoindre une room
  Future<bool> joinRoom({
    required String roomCode,
    required String playerName,
  }) async {
    if (state.gameState != PentoscopeMPGameState.disconnected) {
      debugPrint('[MP] ⚠️ Déjà connecté');
      return false;
    }

    final code = roomCode.toUpperCase();
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.connecting,
      roomCode: code,
      isHost: false,
    );

    try {
      // 1. Vérifier que la room existe
      debugPrint('[MP] 🔍 Vérification de la room $code...');
      final existsResponse = await http.get(
        Uri.parse('$_serverHttpUrl/room/$code/exists'),
      );

      if (existsResponse.statusCode != 200) {
        throw Exception('Room introuvable');
      }

      final existsData = jsonDecode(existsResponse.body);
      if (existsData['exists'] != true) {
        throw Exception('Room introuvable ou fermée');
      }

      debugPrint('[MP] ✅ Room trouvée (mode: ${existsData['gameMode']})');

      // 2. Connexion WebSocket
      final wsUrl = '$_serverWsUrl/room/$code/ws';
      debugPrint('[MP] 🔌 Connexion WebSocket à $wsUrl...');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;
      
      debugPrint('[MP] ✅ WebSocket connecté !');
      
      // Écouter les messages
      _messageSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      
      // Envoyer join_room
      _send(JoinRoomMessage(
        roomCode: code,
        playerName: playerName,
      ));
      
      // Démarrer ping/pong
      _startPingTimer();
      
      return true;
    } catch (e) {
      debugPrint('[MP] ❌ Erreur de connexion: $e');
      state = state.copyWith(
        gameState: PentoscopeMPGameState.error,
        errorMessage: e.toString().contains('introuvable') 
            ? 'Room introuvable ou fermée'
            : 'Impossible de se connecter',
      );
      return false;
    }
  }

  /// Quitter la room
  Future<void> leaveRoom() async {
    debugPrint('[MP] 🚪 Quitter la room...');
    
    _send(LeaveRoomMessage());
    await _cleanup();
    
    state = PentoscopeMPState.initial();
  }

  // ==========================================================================
  // ACTIONS HOST
  // ==========================================================================

  /// Lancer la partie (Host uniquement)
  Future<void> startGame() async {
    if (!state.isHost || !state.canStart) {
      debugPrint('[MP] ⚠️ Impossible de lancer la partie');
      return;
    }

    debugPrint('[MP] 🎮 Lancement de la partie...');

    // Générer un puzzle VALIDE (avec au moins une solution)
    final generator = PentoscopeGenerator();
    final size = state.config!.toPentoscopeSize();
    
    debugPrint('[MP] 🔍 Génération d\'un puzzle valide pour ${size.label}...');
    final puzzle = await generator.generate(size);
    
    final seed = DateTime.now().millisecondsSinceEpoch;
    final pieceIds = puzzle.pieceIds;

    debugPrint('[MP] ✅ Puzzle trouvé: seed=$seed, pièces=$pieceIds, solutions=${puzzle.solutionCount}');

    // Envoyer au serveur
    _send(StartGameMessage(
      seed: seed,
      pieceIds: pieceIds,
    ));

    // Stocker localement
    state = state.copyWith(
      seed: seed,
      pieceIds: pieceIds,
    );
  }

  // ==========================================================================
  // ACTIONS JEU
  // ==========================================================================

  /// Mettre à jour la progression
  void updateProgress(int placedCount, {List<PlacedPieceSummary>? placedPieces}) {
    if (state.gameState != PentoscopeMPGameState.playing) return;

    _send(ProgressMessage(
      placedCount: placedCount,
      placedPieces: placedPieces,
    ));

    // Mettre à jour mon état local
    final updatedPlayers = state.players.map((p) {
      if (p.isMe) {
        return p.copyWith(placedCount: placedCount);
      }
      return p;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
  }

  /// Puzzle terminé !
  void complete() {
    if (state.gameState != PentoscopeMPGameState.playing) return;

    final time = state.elapsedSeconds;
    debugPrint('[MP] 🏁 Terminé en ${time}s !');

    _send(CompletedMessage(time: time));
  }

  // ==========================================================================
  // HANDLERS MESSAGES SERVEUR
  // ==========================================================================

  void _onMessage(dynamic data) {
    if (data is! String) return;
    
    // Ignorer silencieusement les pongs
    if (data.contains('"type":"pong"')) {
      return;
    }
    
    debugPrint('[MP] 📥 Reçu: $data');
    
    final message = MPServerMessage.decode(data);
    if (message == null) {
      debugPrint('[MP] ⚠️ Message non reconnu');
      return;
    }

    switch (message) {
      case RoomCreatedMessage msg:
        _handleRoomCreated(msg);
      case RoomJoinedMessage msg:
        _handleRoomJoined(msg);
      case PlayerJoinedMessage msg:
        _handlePlayerJoined(msg);
      case PlayerLeftMessage msg:
        _handlePlayerLeft(msg);
      case PuzzleReadyMessage msg:
        _handlePuzzleReady(msg);
      case CountdownMessage msg:
        _handleCountdown(msg);
      case GameStartMessage _:
        _handleGameStart();
      case OpponentProgressMessage msg:
        _handleOpponentProgress(msg);
      case PlayerCompletedMessage msg:
        _handlePlayerCompleted(msg);
      case GameEndMessage msg:
        _handleGameEnd(msg);
      case ErrorMessage msg:
        _handleError(msg);
      default:
        debugPrint('[MP] ⚠️ Message non géré: ${message.runtimeType}');
    }
  }

  void _handleRoomCreated(RoomCreatedMessage msg) {
    debugPrint('[MP] ✅ Room créée: ${msg.roomCode}');
    
    final me = MPPlayer(
      id: msg.playerId,
      name: 'Moi', // TODO: récupérer le nom
      isMe: true,
      isHost: true,
    );
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.waiting,
      roomCode: msg.roomCode,
      myPlayerId: msg.playerId,
      players: [me],
    );
  }

  void _handleRoomJoined(RoomJoinedMessage msg) {
    debugPrint('[MP] ✅ Room rejointe: ${msg.roomCode}');
    
    // Construire la liste des joueurs
    final players = msg.players.map((p) => MPPlayer(
      id: p.id,
      name: p.name,
      isMe: p.id == msg.playerId,
      isHost: p.isHost,
    )).toList();
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.waiting,
      roomCode: msg.roomCode,
      myPlayerId: msg.playerId,
      config: MPGameConfig.fromFormat(msg.format, timeLimit: msg.timeLimit),
      players: players,
    );
  }

  void _handlePlayerJoined(PlayerJoinedMessage msg) {
    debugPrint('[MP] 👤 Joueur rejoint: ${msg.playerName}');
    
    final newPlayer = MPPlayer(
      id: msg.playerId,
      name: msg.playerName,
    );
    
    state = state.copyWith(
      players: [...state.players, newPlayer],
    );
  }

  void _handlePlayerLeft(PlayerLeftMessage msg) {
    debugPrint('[MP] 🚪 Joueur parti: ${msg.playerId}');
    
    final updatedPlayers = state.players
        .where((p) => p.id != msg.playerId)
        .toList();
    
    state = state.copyWith(players: updatedPlayers);
  }

  void _handlePuzzleReady(PuzzleReadyMessage msg) {
    debugPrint('[MP] 🧩 Puzzle prêt: seed=${msg.seed}, pièces=${msg.pieceIds}, format=${msg.format}, ${msg.width}x${msg.height}');
    
    // Utiliser les dimensions exactes du serveur
    final config = MPGameConfig(
      format: msg.format,
      width: msg.width,
      height: msg.height,
      pieceCount: msg.pieceCount,
      timeLimit: msg.timeLimit,
    );
    debugPrint('[MP] 📐 Config: ${config.width}x${config.height}, ${config.pieceCount} pièces');
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.countdown,
      seed: msg.seed,
      pieceIds: msg.pieceIds,
      config: config,
    );
  }

  void _handleCountdown(CountdownMessage msg) {
    debugPrint('[MP] ⏱️ Countdown: ${msg.value}');
    
    state = state.copyWith(
      countdownValue: msg.value,
    );
  }

  void _handleGameStart() {
    debugPrint('[MP] 🏁 GO !');
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.playing,
      clearCountdownValue: true,
      elapsedSeconds: 0,
    );
    
    // Démarrer le chrono
    _startGameTimer();
  }

  void _handleOpponentProgress(OpponentProgressMessage msg) {
    final updatedPlayers = state.players.map((p) {
      if (p.id == msg.playerId) {
        // Convertir les PlacedPieceSummary en MPPlacedPiece
        final pieces = msg.placedPieces?.map((ps) => MPPlacedPiece(
          pieceId: ps.pieceId,
          x: ps.x,
          y: ps.y,
          positionIndex: ps.positionIndex,
        )).toList() ?? p.placedPieces;
        
        return p.copyWith(
          placedCount: msg.placedCount,
          placedPieces: pieces,
        );
      }
      return p;
    }).toList();
    
    state = state.copyWith(players: updatedPlayers);
  }

  void _handlePlayerCompleted(PlayerCompletedMessage msg) {
    debugPrint('[MP] 🏆 ${msg.playerName} a terminé en ${msg.timeMs ~/ 1000}s (rang ${msg.rank})');
    
    final updatedPlayers = state.players.map((p) {
      if (p.id == msg.playerId) {
        return p.copyWith(
          completionTime: msg.timeMs ~/ 1000,
          rank: msg.rank,
        );
      }
      return p;
    }).toList();
    
    state = state.copyWith(players: updatedPlayers);
  }

  void _handleGameEnd(GameEndMessage msg) {
    debugPrint('[MP] 🎯 Fin de partie !');
    
    // Mettre à jour les rangs finaux
    final updatedPlayers = state.players.map((p) {
      final ranking = msg.rankings.where((r) => r.playerId == p.id).firstOrNull;
      if (ranking != null) {
        return p.copyWith(
          rank: ranking.rank,
          completionTime: ranking.timeMs != null ? ranking.timeMs! ~/ 1000 : null,
        );
      }
      return p;
    }).toList();
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.finished,
      players: updatedPlayers,
    );
    
    // Arrêter le chrono
    _gameTimer?.cancel();
  }

  void _handleError(ErrorMessage msg) {
    debugPrint('[MP] ❌ Erreur serveur: ${msg.message}');
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.error,
      errorMessage: msg.message,
    );
  }

  // ==========================================================================
  // HANDLERS CONNEXION
  // ==========================================================================

  void _onError(dynamic error) {
    debugPrint('[MP] ❌ Erreur WebSocket: $error');
    
    state = state.copyWith(
      gameState: PentoscopeMPGameState.error,
      errorMessage: 'Connexion perdue',
    );
  }

  void _onDone() {
    debugPrint('[MP] 🔌 Connexion fermée');
    
    if (state.gameState != PentoscopeMPGameState.disconnected &&
        state.gameState != PentoscopeMPGameState.finished) {
      state = state.copyWith(
        gameState: PentoscopeMPGameState.error,
        errorMessage: 'Connexion interrompue',
      );
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  void _send(MPClientMessage message) {
    if (_channel == null) {
      debugPrint('[MP] ⚠️ Non connecté, message ignoré');
      return;
    }
    
    debugPrint('[MP] 📤 Envoi: ${message.type}');
    _channel!.sink.add(message.encode());
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_channel != null) {
        debugPrint('[MP] 🏓 Ping...');
        _channel!.sink.add('{"type":"ping"}');
      }
    });
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _startTime = DateTime.now();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null && state.gameState == PentoscopeMPGameState.playing) {
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        state = state.copyWith(elapsedSeconds: elapsed);
      }
    });
  }

  Future<void> _cleanup() async {
    _pingTimer?.cancel();
    _gameTimer?.cancel();
    _messageSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }
}

