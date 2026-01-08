// lib/pentoscope/piece_difficulty.dart
// Modified: 2512161102
// Classement arbitraire de difficulté des pièces
// À affiner selon expérience réelle

/// Rang de difficulté pour chaque pièce (1-12)
/// 1 = très facile, 4 = très difficile
/// À modifier après tests réels
const Map<int, int> pieceDifficultyRank = {
  1: 3,   // X (croix) → difficile (symétrique, faut bien placer)
  2: 2,   // P → moyen
  3: 4,   // T → très difficile (peu de positions)
  4: 2,   // F → moyen
  5: 3,   // Y → difficile
  6: 2,   // V → moyen
  7: 2,   // U → moyen
  8: 1,   // L → facile (barre presque)
  9: 2,   // N → moyen
  10: 3,  // W → difficile
  11: 3,  // Z → difficile
  12: 1,  // I (barre) → très facile (une seule direction pratiquement)
};

/// Difficultés prédéfinies pour les puzzles
enum PentoscopeDifficulty {
  easy,
  random,
  hard,
}