// Modified: 2025-11-15 06:45:00
// lib/data/solution_database.dart
/// Base de données des solutions pentomino précalculées.
/// 
/// Charge les formes canoniques depuis assets/solutions_canonical.bin
/// et fournit des méthodes de recherche/filtrage.
library;

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/utils/plateau_compressor.dart';

/// Base de données en mémoire des solutions pentomino.
class SolutionDatabase {
  static List<List<int>>? _allSolutions;
  static bool _isInitialized = false;
  
  /// Solutions canoniques chargées (ou null si pas encore initialisé).
  static List<List<int>>? get allSolutions => _allSolutions;
  
  /// Nombre de solutions chargées.
  static int get count => _allSolutions?.length ?? 0;
  
  /// Indique si la base est initialisée.
  static bool get isInitialized => _isInitialized;
  
  /// Charge les solutions depuis assets/solutions_canonical.bin.
  /// 
  /// Doit être appelé au démarrage de l'app (main.dart):
  /// ```dart
  /// await SolutionDatabase.init();
  /// ```
  /// 
  /// Durée: ~5-10 ms pour 35 Ko
  static Future<void> init() async {
    if (_isInitialized) {
      print('[SolutionDatabase] Déjà initialisé (${count} solutions)');
      return;
    }
    
    final startTime = DateTime.now();
    
    try {
      // Charger le fichier binaire
      final byteData = await rootBundle.load('assets/solutions_canonical.bin');
      
      // Désérialiser
      _allSolutions = _deserialize(byteData);
      _isInitialized = true;
      
      final duration = DateTime.now().difference(startTime);
      print('[SolutionDatabase] ✓ ${count} solutions chargées en ${duration.inMilliseconds}ms');
    } catch (e) {
      print('[SolutionDatabase] ✗ Erreur de chargement: $e');
      print('[SolutionDatabase] Fichier manquant? Exécutez: dart run tools/generate_canonical_solutions.dart');
      _allSolutions = [];
      _isInitialized = true;
    }
  }
  
  /// Désérialise le format binaire en List<List<int>>.
  /// 
  /// Format: [nombre (int32)] + [solution1: 8×int32] + [solution2: 8×int32] + ...
  static List<List<int>> _deserialize(ByteData byteData) {
    final buffer = byteData.buffer.asUint32List();
    
    // Lire le nombre de solutions
    final numSolutions = buffer[0];
    final solutions = <List<int>>[];
    
    // Lire chaque solution (8 int32)
    for (int i = 0; i < numSolutions; i++) {
      final offset = 1 + i * 8;
      final solution = buffer.sublist(offset, offset + 8);
      solutions.add(solution.toList());
    }
    
    return solutions;
  }
  
  /// Trouve les solutions compatibles avec un plateau donné.
  /// 
  /// Un plateau est compatible si:
  /// - Les cellules cachées correspondent (-1)
  /// - Les cellules libres peuvent être remplies (0)
  static List<List<int>> findMatchingSolutions(Plateau plateau) {
    if (!_isInitialized || _allSolutions == null) {
      throw StateError('SolutionDatabase non initialisé. Appelez init() d\'abord.');
    }
    
    final encoded = PlateauCompressor.encode(plateau);
    final matching = <List<int>>[];
    
    for (final solution in _allSolutions!) {
      if (_isCompatible(encoded, solution)) {
        matching.add(solution);
      }
    }
    
    return matching;
  }
  
  /// Vérifie si un plateau est compatible avec une solution.
  static bool _isCompatible(List<int> plateauEncoded, List<int> solutionEncoded) {
    for (int cellIndex = 0; cellIndex < 60; cellIndex++) {
      final intIndex = cellIndex ~/ 8;
      final bitOffset = (cellIndex % 8) * 4;
      
      final plateauValue = (plateauEncoded[intIndex] >> bitOffset) & 0xF;
      final solutionValue = (solutionEncoded[intIndex] >> bitOffset) & 0xF;
      
      // Si la cellule du plateau est cachée (13), la solution doit aussi l'être
      if (plateauValue == 13 && solutionValue != 13) {
        return false;
      }
      
      // Si la cellule du plateau a une pièce, la solution doit avoir la même
      if (plateauValue >= 1 && plateauValue <= 12 && plateauValue != solutionValue) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Décode une solution en Plateau.
  static Plateau decodeSolution(List<int> encoded) {
    return PlateauCompressor.decode(encoded);
  }
  
  /// Trouve si un plateau a une solution (recherche rapide).
  static bool hasSolution(Plateau plateau) {
    return findMatchingSolutions(plateau).isNotEmpty;
  }
  
  /// Statistiques de la base de données.
  static Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'count': count,
      'size_bytes': count * 8 * 4,
      'size_kb': (count * 32 / 1024).toStringAsFixed(1),
    };
  }
  
  /// Réinitialise la base (utile pour les tests).
  static void reset() {
    _allSolutions = null;
    _isInitialized = false;
  }
}

