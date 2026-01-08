// Modified: 2025-11-30 - DuelSettings enrichi (durée, affichage, feedback, stats)
// lib/models/app_settings.dart
// Modèles pour les paramètres de l'application

import 'package:flutter/material.dart';

/// Schéma de couleurs pour les pièces
enum PieceColorScheme {
  classic,    // Couleurs vives classiques
  pastel,     // Couleurs pastel douces
  neon,       // Couleurs néon éclatantes
  monochrome, // Nuances de gris
  rainbow,    // Arc-en-ciel
  custom,     // Couleurs personnalisées
}

/// Niveau de difficulté du jeu
enum GameDifficulty {
  easy,       // Facile : indices visuels, pas de limite de temps
  normal,     // Normal : jeu standard
  hard,       // Difficile : moins d'indices, chronomètre
  expert,     // Expert : mode compétition
}

/// Durée de partie Duel prédéfinie
enum DuelDuration {
  short,    // 1 minute
  normal,   // 3 minutes (défaut)
  long,     // 5 minutes
  marathon, // 10 minutes
  custom,   // Durée personnalisée
}

extension DuelDurationExtension on DuelDuration {
  /// Durée en secondes
  int get seconds {
    switch (this) {
      case DuelDuration.short:
        return 60;
      case DuelDuration.normal:
        return 180;
      case DuelDuration.long:
        return 300;
      case DuelDuration.marathon:
        return 600;
      case DuelDuration.custom:
        return 180; // Valeur par défaut, sera override par customDurationSeconds
    }
  }

  /// Label pour l'UI
  String get label {
    switch (this) {
      case DuelDuration.short:
        return '1 min';
      case DuelDuration.normal:
        return '3 min';
      case DuelDuration.long:
        return '5 min';
      case DuelDuration.marathon:
        return '10 min';
      case DuelDuration.custom:
        return 'Perso';
    }
  }

  /// Icône pour l'UI
  String get icon {
    switch (this) {
      case DuelDuration.short:
        return '⚡';
      case DuelDuration.normal:
        return '⏱️';
      case DuelDuration.long:
        return '🕐';
      case DuelDuration.marathon:
        return '🏃';
      case DuelDuration.custom:
        return '⚙️';
    }
  }
}

/// Paramètres UI
class UISettings {
  final PieceColorScheme colorScheme;
  final List<Color> customColors;   // Couleurs personnalisées (12 pièces)
  final bool showPieceNumbers;      // Afficher les numéros sur les pièces
  final bool showGridLines;         // Afficher les lignes de grille
  final bool enableAnimations;      // Activer les animations
  final double pieceOpacity;        // Opacité des pièces (0.0 - 1.0)
  final Color isometriesAppBarColor; // Couleur de fond AppBar en mode isométries
  final double iconSize;            // Taille des icônes (16.0 - 48.0)

  const UISettings({
    this.colorScheme = PieceColorScheme.classic,
    this.customColors = const [],
    this.showPieceNumbers = true,
    this.showGridLines = false,
    this.enableAnimations = true,
    this.pieceOpacity = 1.0,
    this.isometriesAppBarColor = const Color(0xFF9575CD), // Violet clair par défaut
    this.iconSize = 48.0, // Taille par défaut : 48px (max)
  });

  UISettings copyWith({
    PieceColorScheme? colorScheme,
    List<Color>? customColors,
    bool? showPieceNumbers,
    bool? showGridLines,
    bool? enableAnimations,
    double? pieceOpacity,
    Color? isometriesAppBarColor,
    double? iconSize,
  }) {
    return UISettings(
      colorScheme: colorScheme ?? this.colorScheme,
      customColors: customColors ?? this.customColors,
      showPieceNumbers: showPieceNumbers ?? this.showPieceNumbers,
      showGridLines: showGridLines ?? this.showGridLines,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      pieceOpacity: pieceOpacity ?? this.pieceOpacity,
      isometriesAppBarColor: isometriesAppBarColor ?? this.isometriesAppBarColor,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  /// Obtenir la couleur d'une pièce selon le schéma actuel
  Color getPieceColor(int pieceId) {
    switch (colorScheme) {
      case PieceColorScheme.classic:
        return _getClassicColor(pieceId);
      case PieceColorScheme.pastel:
        return _getPastelColor(pieceId);
      case PieceColorScheme.neon:
        return _getNeonColor(pieceId);
      case PieceColorScheme.monochrome:
        return _getMonochromeColor(pieceId);
      case PieceColorScheme.rainbow:
        return _getRainbowColor(pieceId);
      case PieceColorScheme.custom:
        return _getCustomColor(pieceId);
    }
  }

  Color _getCustomColor(int pieceId) {
    if (customColors.isEmpty) {
      // Si pas de couleurs personnalisées, utiliser classique par défaut
      return _getClassicColor(pieceId);
    }
    return customColors[(pieceId - 1) % customColors.length];
  }
  /// Palette DUEL : 12 couleurs maximalement distinctes
  /// Conçue pour le mode compétitif où la distinction rapide est cruciale
  Color _getDuelColor(int pieceId) {
    const colors = [
      // Couleurs primaires pures
      Color(0xFFE53935), // 1  - ROUGE vif
      Color(0xFF43A047), // 2  - VERT franc
      Color(0xFF1E88E5), // 3  - BLEU roi

      // Couleurs secondaires
      Color(0xFFFFB300), // 4  - JAUNE OR
      Color(0xFFFF6D00), // 5  - ORANGE vif
      Color(0xFF8E24AA), // 6  - VIOLET profond

      // Couleurs tertiaires bien espacées
      Color(0xFF00BCD4), // 7  - CYAN
      Color(0xFFD81B60), // 8  - MAGENTA / Rose vif
      Color(0xFF5D4037), // 9  - MARRON foncé

      // Couleurs complémentaires
      Color(0xFFAEEA00), // 10 - LIME vif (plus jaune-vert)
      Color(0xFF303F9F), // 11 - INDIGO foncé
      Color(0xFF757575), // 12 - GRIS moyen (neutre, bien distinct)
    ];
    return colors[(pieceId - 1) % colors.length];
  }
  Color _getClassicColor(int pieceId) {
    const colors = [
      Color(0xFFE57373), // Rouge
      Color(0xFF81C784), // Vert
      Color(0xFF64B5F6), // Bleu
      Color(0xFFFFD54F), // Jaune
      Color(0xFFBA68C8), // Violet
      Color(0xFFFF8A65), // Orange
      Color(0xFF4DB6AC), // Turquoise
      Color(0xFFA1887F), // Marron
      Color(0xFF90A4AE), // Gris-bleu
      Color(0xFFF06292), // Rose
      Color(0xFF9575CD), // Violet clair
      Color(0xFF4DD0E1), // Cyan
    ];
    return colors[pieceId % colors.length];
  }

  Color _getPastelColor(int pieceId) {
    const colors = [
      Color(0xFFFFCDD2), // Rose pastel
      Color(0xFFC8E6C9), // Vert pastel
      Color(0xFFBBDEFB), // Bleu pastel
      Color(0xFFFFF9C4), // Jaune pastel
      Color(0xFFE1BEE7), // Violet pastel
      Color(0xFFFFCCBC), // Orange pastel
      Color(0xFFB2DFDB), // Turquoise pastel
      Color(0xFFD7CCC8), // Marron pastel
      Color(0xFFCFD8DC), // Gris pastel
      Color(0xFFF8BBD0), // Rose clair pastel
      Color(0xFFD1C4E9), // Violet clair pastel
      Color(0xFFB2EBF2), // Cyan pastel
    ];
    return colors[pieceId % colors.length];
  }

  Color _getNeonColor(int pieceId) {
    const colors = [
      Color(0xFFFF1744), // Rouge néon
      Color(0xFF00E676), // Vert néon
      Color(0xFF2979FF), // Bleu néon
      Color(0xFFFFEA00), // Jaune néon
      Color(0xFFD500F9), // Violet néon
      Color(0xFFFF6E40), // Orange néon
      Color(0xFF1DE9B6), // Turquoise néon
      Color(0xFFFF9100), // Ambre néon
      Color(0xFF00E5FF), // Cyan néon
      Color(0xFFFF4081), // Rose néon
      Color(0xFF651FFF), // Violet profond néon
      Color(0xFF00B0FF), // Bleu clair néon
    ];
    return colors[pieceId % colors.length];
  }

  Color _getMonochromeColor(int pieceId) {
    final shades = [
      Colors.grey[900]!,
      Colors.grey[800]!,
      Colors.grey[700]!,
      Colors.grey[600]!,
      Colors.grey[500]!,
      Colors.grey[400]!,
      Colors.grey[300]!,
      Colors.grey[200]!,
      Colors.grey[100]!,
      Colors.grey[50]!,
      Colors.blueGrey[300]!,
      Colors.blueGrey[100]!,
    ];
    return shades[pieceId % shades.length];
  }

  Color _getRainbowColor(int pieceId) {
    // Arc-en-ciel : Rouge -> Orange -> Jaune -> Vert -> Bleu -> Violet
    const colors = [
      Color(0xFFFF0000), // Rouge
      Color(0xFFFF7F00), // Orange
      Color(0xFFFFFF00), // Jaune
      Color(0xFF00FF00), // Vert
      Color(0xFF0000FF), // Bleu
      Color(0xFF4B0082), // Indigo
      Color(0xFF9400D3), // Violet
      Color(0xFFFF1493), // Rose vif
      Color(0xFF00CED1), // Turquoise foncé
      Color(0xFFFFD700), // Or
      Color(0xFF32CD32), // Vert citron
      Color(0xFF8A2BE2), // Bleu violet
    ];
    return colors[pieceId % colors.length];
  }

  Map<String, dynamic> toJson() {
    return {
      'colorScheme': colorScheme.index,
      'customColors': customColors.map((c) => c.value).toList(), // ignore: deprecated_member_use
      'showPieceNumbers': showPieceNumbers,
      'showGridLines': showGridLines,
      'enableAnimations': enableAnimations,
      'pieceOpacity': pieceOpacity,
      'isometriesAppBarColor': isometriesAppBarColor.value, // ignore: deprecated_member_use
      'iconSize': iconSize,
    };
  }

  factory UISettings.fromJson(Map<String, dynamic> json) {
    final customColorValues = json['customColors'] as List<dynamic>?;
    final customColors = customColorValues?.map((v) => Color(v as int)).toList() ?? [];

    return UISettings(
      colorScheme: PieceColorScheme.values[json['colorScheme'] ?? 0],
      customColors: customColors,
      showPieceNumbers: json['showPieceNumbers'] ?? true,
      showGridLines: json['showGridLines'] ?? false,
      enableAnimations: json['enableAnimations'] ?? true,
      pieceOpacity: json['pieceOpacity'] ?? 1.0,
      isometriesAppBarColor: Color(json['isometriesAppBarColor'] ?? 0xFF9575CD),
      iconSize: json['iconSize'] ?? 28.0,
    );
  }
}

/// Paramètres de jeu
class GameSettings {
  final GameDifficulty difficulty;
  final bool showSolutionCounter;   // Afficher le compteur de solutions
  final bool enableHints;           // Activer les indices
  final bool enableTimer;           // Activer le chronomètre
  final bool enableHaptics;         // Activer le retour haptique
  final int longPressDuration;      // Durée du long press en ms

  const GameSettings({
    this.difficulty = GameDifficulty.normal,
    this.showSolutionCounter = true,
    this.enableHints = false,
    this.enableTimer = false,
    this.enableHaptics = true,
    this.longPressDuration = 200,
  });

  GameSettings copyWith({
    GameDifficulty? difficulty,
    bool? showSolutionCounter,
    bool? enableHints,
    bool? enableTimer,
    bool? enableHaptics,
    int? longPressDuration,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      showSolutionCounter: showSolutionCounter ?? this.showSolutionCounter,
      enableHints: enableHints ?? this.enableHints,
      enableTimer: enableTimer ?? this.enableTimer,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      longPressDuration: longPressDuration ?? this.longPressDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.index,
      'showSolutionCounter': showSolutionCounter,
      'enableHints': enableHints,
      'enableTimer': enableTimer,
      'enableHaptics': enableHaptics,
      'longPressDuration': longPressDuration,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      difficulty: GameDifficulty.values[json['difficulty'] ?? 1],
      showSolutionCounter: json['showSolutionCounter'] ?? true,
      enableHints: json['enableHints'] ?? false,
      enableTimer: json['enableTimer'] ?? false,
      enableHaptics: json['enableHaptics'] ?? true,
      longPressDuration: json['longPressDuration'] ?? 200,
    );
  }
}

/// Paramètres du mode Duel - VERSION ENRICHIE
class DuelSettings {
  // === Identité joueur ===
  final String? playerName;

  // === Durée de partie ===
  final DuelDuration duration;
  final int customDurationSeconds; // Utilisé si duration == custom (60-1800)

  // === Affichage ===
  final bool showSolutionGuide;     // Afficher le guide (couleurs atténuées)
  final double guideOpacity;        // Opacité du guide (0.1 - 0.5)
  final bool showPieceNumbers;      // Afficher les numéros sur le guide

  // === Feedback ===
  final bool enableSounds;          // Sons de placement/victoire
  final bool enableVibration;       // Vibrations

  // === Affichage adversaire ===
  final bool showOpponentProgress;  // Voir les pièces de l'adversaire en temps réel
  final bool showHatchOnOpponent;   // Hachures sur pièces adversaire
  final double hatchOpacity;        // Opacité des hachures (0.2 - 0.6)

  // === Statistiques ===
  final int totalGamesPlayed;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;

  const DuelSettings({
    // Identité
    this.playerName,
    // Durée
    this.duration = DuelDuration.normal,
    this.customDurationSeconds = 180,
    // Affichage
    this.showSolutionGuide = true,
    this.guideOpacity = 0.35,
    this.showPieceNumbers = true,
    // Feedback
    this.enableSounds = true,
    this.enableVibration = true,
    // Affichage adversaire
    this.showOpponentProgress = true,
    this.showHatchOnOpponent = true,
    this.hatchOpacity = 0.4,
    // Stats
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalDraws = 0,
  });

  /// Durée effective en secondes
  int get effectiveDurationSeconds {
    if (duration == DuelDuration.custom) {
      return customDurationSeconds.clamp(60, 1800);
    }
    return duration.seconds;
  }

  /// Durée formatée pour affichage
  String get durationFormatted {
    final secs = effectiveDurationSeconds;
    final mins = secs ~/ 60;
    final remainingSecs = secs % 60;
    if (remainingSecs == 0) {
      return '$mins min';
    }
    return '$mins:${remainingSecs.toString().padLeft(2, '0')}';
  }

  /// Taux de victoire en pourcentage
  double get winRate {
    if (totalGamesPlayed == 0) return 0.0;
    return (totalWins / totalGamesPlayed) * 100;
  }

  DuelSettings copyWith({
    String? playerName,
    bool clearPlayerName = false,
    DuelDuration? duration,
    int? customDurationSeconds,
    bool? showSolutionGuide,
    double? guideOpacity,
    bool? showPieceNumbers,
    bool? enableSounds,
    bool? enableVibration,
    bool? showOpponentProgress,
    bool? showHatchOnOpponent,
    double? hatchOpacity,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalLosses,
    int? totalDraws,
  }) {
    return DuelSettings(
      playerName: clearPlayerName ? null : (playerName ?? this.playerName),
      duration: duration ?? this.duration,
      customDurationSeconds: customDurationSeconds ?? this.customDurationSeconds,
      showSolutionGuide: showSolutionGuide ?? this.showSolutionGuide,
      guideOpacity: guideOpacity ?? this.guideOpacity,
      showPieceNumbers: showPieceNumbers ?? this.showPieceNumbers,
      enableSounds: enableSounds ?? this.enableSounds,
      enableVibration: enableVibration ?? this.enableVibration,
      showOpponentProgress: showOpponentProgress ?? this.showOpponentProgress,
      showHatchOnOpponent: showHatchOnOpponent ?? this.showHatchOnOpponent,
      hatchOpacity: hatchOpacity ?? this.hatchOpacity,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalDraws: totalDraws ?? this.totalDraws,
    );
  }

  /// Incrémenter les stats après une partie
  DuelSettings recordGame({required bool? isWin}) {
    return copyWith(
      totalGamesPlayed: totalGamesPlayed + 1,
      totalWins: isWin == true ? totalWins + 1 : totalWins,
      totalLosses: isWin == false ? totalLosses + 1 : totalLosses,
      totalDraws: isWin == null ? totalDraws + 1 : totalDraws,
    );
  }

  /// Réinitialiser les stats uniquement
  DuelSettings resetStats() {
    return copyWith(
      totalGamesPlayed: 0,
      totalWins: 0,
      totalLosses: 0,
      totalDraws: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'duration': duration.index,
      'customDurationSeconds': customDurationSeconds,
      'showSolutionGuide': showSolutionGuide,
      'guideOpacity': guideOpacity,
      'showPieceNumbers': showPieceNumbers,
      'enableSounds': enableSounds,
      'enableVibration': enableVibration,
      'showOpponentProgress': showOpponentProgress,
      'showHatchOnOpponent': showHatchOnOpponent,
      'hatchOpacity': hatchOpacity,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalDraws': totalDraws,
    };
  }

  factory DuelSettings.fromJson(Map<String, dynamic> json) {
    return DuelSettings(
      playerName: json['playerName'] as String?,
      duration: DuelDuration.values[json['duration'] ?? 1],
      customDurationSeconds: json['customDurationSeconds'] ?? 180,
      showSolutionGuide: json['showSolutionGuide'] ?? true,
      guideOpacity: (json['guideOpacity'] ?? 0.35).toDouble(),
      showPieceNumbers: json['showPieceNumbers'] ?? true,
      enableSounds: json['enableSounds'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      showOpponentProgress: json['showOpponentProgress'] ?? true,
      showHatchOnOpponent: json['showHatchOnOpponent'] ?? true,
      hatchOpacity: (json['hatchOpacity'] ?? 0.4).toDouble(),
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      totalDraws: json['totalDraws'] ?? 0,
    );
  }

  static const DuelSettings defaults = DuelSettings();
}

/// Paramètres globaux de l'application
class AppSettings {
  final UISettings ui;
  final GameSettings game;
  final DuelSettings duel;

  const AppSettings({
    this.ui = const UISettings(),
    this.game = const GameSettings(),
    this.duel = DuelSettings.defaults,
  });

  AppSettings copyWith({
    UISettings? ui,
    GameSettings? game,
    DuelSettings? duel,
  }) {
    return AppSettings(
      ui: ui ?? this.ui,
      game: game ?? this.game,
      duel: duel ?? this.duel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ui': ui.toJson(),
      'game': game.toJson(),
      'duel': duel.toJson(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      ui: UISettings.fromJson(json['ui'] ?? {}),
      game: GameSettings.fromJson(json['game'] ?? {}),
      duel: json['duel'] != null
          ? DuelSettings.fromJson(json['duel'])
          : DuelSettings.defaults,
    );
  }
}