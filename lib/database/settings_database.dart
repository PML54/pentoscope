// Modified: 2025-11-16 10:15:00 → 251226
// lib/database/settings_database.dart
// Base de données SQLite pour Pentapol (Drift)
// VERSION CORRIGÉE - Sans erreurs d'initialisation

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'settings_database.g.dart';

// ✨ IMPORTANT: Cette fonction DOIT être AVANT la classe
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pentapol_settings.db'));
    return NativeDatabase(file);
  });
}

/// Table pour stocker les paramètres de l'application
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Table pour sauvegarder les sessions de jeu (solutions résolues)
@DataClassName('GameSession')
class GameSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Le numéro unique de la solution trouvée (1, 2, 3, ...)
  IntColumn get solutionNumber => integer()();

  // Temps écoulé en secondes (225 = 3:45)
  IntColumn get elapsedSeconds => integer()();

  // Score calculé (1000 - seconds, clamped 0-1000)
  IntColumn get score => integer().nullable()();

  // Nombre de pièces placées (pour vérifier completion)
  IntColumn get piecesPlaced => integer().nullable()();

  // Nombre de "mauvaises tentatives" (placements annulés)
  IntColumn get numUndos => integer().nullable()();

  // 🆕 Nombre d'isométries appliquées pendant la session
  IntColumn get isometriesCount => integer().nullable()();

  // 🆕 Nombre de fois où le user a consulté les solutions
  IntColumn get solutionsViewCount => integer().nullable()();

  // Timestamp de complétion
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();

  // Notes utilisateur (optionnel)
  TextColumn get playerNotes => text().nullable()();
}

/// Table pour les statistiques agrégées par solution
@DataClassName('SolutionStat')
class SolutionStats extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Numéro de solution (1, 2, 3, ...)
  IntColumn get solutionNumber => integer().unique()();

  // Nombre de fois cette solution a été jouée
  IntColumn get timesPlayed => integer().withDefault(const Constant(0))();

  // Meilleur temps en secondes (-1 si jamais jouée)
  IntColumn get bestTime => integer().withDefault(const Constant(-1))();

  // Temps moyen en secondes
  IntColumn get averageTime => integer().nullable()();

  // Meilleur score
  IntColumn get bestScore => integer().nullable()();

  // Quand cette solution a été jouée pour la première fois
  DateTimeColumn get firstPlayed => dateTime().nullable()();

  // Quand elle a été jouée pour la dernière fois
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

// ✨ MAINTENANT la classe (après la fonction et les tables)
@DriftDatabase(tables: [Settings, GameSessions, SolutionStats])
class SettingsDatabase extends _$SettingsDatabase {
  // ✨ CORRECTION: super(_openConnection()) au lieu de super._openConnection()
  SettingsDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ============================================================================
  // SETTINGS - Paramètres de l'application (ancien code, intacte)
  // ============================================================================

  /// Récupère une valeur de paramètre
  Future<String?> getSetting(String key) async {
    final query = select(settings)..where((tbl) => tbl.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  /// Définit une valeur de paramètre
  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
      ),
    );
  }

  /// Supprime un paramètre
  Future<void> deleteSetting(String key) async {
    await (delete(settings)..where((tbl) => tbl.key.equals(key))).go();
  }

  /// Supprime tous les paramètres
  Future<void> clearAllSettings() async {
    await delete(settings).go();
  }

  // ============================================================================
  // GAME SESSIONS - Sauvegarder les solutions résolues
  // ============================================================================

  /// Sauvegarder une session de jeu complétée
  Future<void> saveGameSession({
    required int solutionNumber,
    required int elapsedSeconds,
    int? score,
    int? piecesPlaced,
    int? numUndos,
    int? isometriesCount,
    int? solutionsViewCount,
    String? playerNotes,
  }) async {
    await into(gameSessions).insert(
      GameSessionsCompanion(
        solutionNumber: Value(solutionNumber),
        elapsedSeconds: Value(elapsedSeconds),
        score: Value(score),
        piecesPlaced: Value(piecesPlaced),
        numUndos: Value(numUndos),
        isometriesCount: Value(isometriesCount),
        solutionsViewCount: Value(solutionsViewCount),
        playerNotes: Value(playerNotes),
      ),
    );

    // Mettre à jour les stats
    await _updateSolutionStats(solutionNumber, elapsedSeconds, score);
  }

  /// Récupérer l'historique des sessions (les plus récentes en premier)
  Future<List<GameSession>> getGameHistory({int limit = 20}) async {
    return (select(gameSessions)
      ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)])
      ..limit(limit))
        .get();
  }

  /// Récupérer les sessions pour une solution spécifique
  Future<List<GameSession>> getSolutionHistory(int solutionNumber) async {
    return (select(gameSessions)
      ..where((s) => s.solutionNumber.equals(solutionNumber))
      ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Récupérer le record du meilleur temps
  Future<GameSession?> getFastestCompletion() async {
    return (select(gameSessions)
      ..orderBy([(t) => OrderingTerm(expression: t.elapsedSeconds, mode: OrderingMode.asc)])
      ..limit(1))
        .getSingleOrNull();
  }

  /// Récupérer le meilleur score
  Future<GameSession?> getHighestScore() async {
    return (select(gameSessions)
      ..orderBy([(t) => OrderingTerm(expression: t.score, mode: OrderingMode.desc)])
      ..limit(1))
        .getSingleOrNull();
  }

  /// Nombre total de sessions complétées
  Future<int> getTotalSessionsCount() async {
    return (select(gameSessions)).get().then((list) => list.length);
  }

  /// Nombre de solutions uniques résolues
  Future<int> getUniqueSolutionsCount() async {
    return (select(gameSessions).get()).then((list) {
      final unique = <int>{};
      for (var session in list) {
        unique.add(session.solutionNumber);
      }
      return unique.length;
    });
  }

  // ============================================================================
  // SOLUTION STATS - Statistiques agrégées
  // ============================================================================

  /// Récupérer les stats d'une solution
  Future<SolutionStat?> getSolutionStats(int solutionNumber) async {
    return (select(solutionStats)
      ..where((s) => s.solutionNumber.equals(solutionNumber)))
        .getSingleOrNull();
  }

  /// Mettre à jour les stats après une completion
  Future<void> _updateSolutionStats(int solutionNumber, int seconds, int? score) async {
    final existing = await getSolutionStats(solutionNumber);

    if (existing != null) {
      // UPDATE
      final newAverage = ((existing.averageTime ?? 0) * existing.timesPlayed + seconds) ~/ (existing.timesPlayed + 1);
      final newBestScore = score != null && score > (existing.bestScore ?? 0) ? score : existing.bestScore;

      await update(solutionStats).replace(
        SolutionStatsCompanion(
          id: Value(existing.id),
          solutionNumber: Value(solutionNumber),
          timesPlayed: Value(existing.timesPlayed + 1),
          bestTime: Value(seconds < existing.bestTime ? seconds : existing.bestTime),
          averageTime: Value(newAverage),
          bestScore: Value(newBestScore),
          lastPlayed: Value(DateTime.now()),
        ),
      );
    } else {
      // INSERT - première fois cette solution
      await into(solutionStats).insert(
        SolutionStatsCompanion(
          solutionNumber: Value(solutionNumber),
          timesPlayed: Value(1),
          bestTime: Value(seconds),
          averageTime: Value(seconds),
          bestScore: Value(score),
          firstPlayed: Value(DateTime.now()),
          lastPlayed: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Récupérer les stats générales
  Future<Map<String, dynamic>> getGlobalStats() async {
    final sessions = await select(gameSessions).get();
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'uniqueSolutions': 0,
        'totalTime': 0,
        'averageTime': 0,
        'bestScore': 0,
      };
    }

    final totalTime = sessions.fold<int>(0, (sum, s) => sum + s.elapsedSeconds);
    final avgTime = totalTime ~/ sessions.length;
    final bestScore = sessions.fold<int>(0, (max, s) => max > (s.score ?? 0) ? max : (s.score ?? 0));
    final unique = <int>{};
    for (var session in sessions) {
      unique.add(session.solutionNumber);
    }

    return {
      'totalSessions': sessions.length,
      'uniqueSolutions': unique.length,
      'totalTime': totalTime,
      'averageTime': avgTime,
      'bestScore': bestScore,
    };
  }
}