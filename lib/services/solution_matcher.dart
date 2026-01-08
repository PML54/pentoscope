// lib/services/solution_matcher.dart
// =============================================================================
// SERVICE DE GESTION DES SOLUTIONS PENTOMINOS 6×10
// =============================================================================
//
// Ce service gère les 9356 solutions du puzzle pentomino 6×10 :
// - Chargement des solutions depuis le fichier binaire
// - Encodage/décodage BigInt ↔ grille
// - Recherche de compatibilité avec un plateau partiel
// - Reconstruction des PlacedPiece à partir d'une solution
//
// =============================================================================
// ARCHITECTURE DES SOLUTIONS
// =============================================================================
//
// 1. SOLUTIONS CANONIQUES (2339)
//    - Issues du fichier `solutions_6x10_normalisees.bin`
//    - Chaque classe d'équivalence symétrique a une seule représentante
//
// 2. VARIANTES GÉNÉRÉES (×4 = 9356 solutions)
//    Pour chaque solution canonique, on génère 4 variantes :
//      - Index % 4 == 0 : Identité (solution originale)
//      - Index % 4 == 1 : Rotation 180°
//      - Index % 4 == 2 : Miroir horizontal (gauche ↔ droite)
//      - Index % 4 == 3 : Miroir vertical (haut ↔ bas)
//
// 3. NUMÉROTATION
//    - Index absolu : 0 à 9355
//    - Index canonique : index ~/ 4 (0 à 2338)
//    - Type de variante : index % 4
//
// =============================================================================
// ENCODAGE BigInt (360 BITS)
// =============================================================================
//
// Chaque solution est encodée en un BigInt de 360 bits :
//   - 60 cases × 6 bits par case = 360 bits
//   - Chaque case contient le code `bit6` de la pièce qui l'occupe
//
// Construction du BigInt :
//   BigInt acc = BigInt.zero;
//   for (int cellIndex = 0; cellIndex < 60; cellIndex++) {
//     acc = (acc << 6) | BigInt.from(bit6Code);
//   }
//
// Disposition de la grille 6×10 (60 cases) :
//   - width = 6 colonnes (x: 0-5)
//   - height = 10 lignes (y: 0-9)
//   - cellIndex = y * 6 + x
//
//   Indices des cases :
//   ┌───────────────────────┐
//   │  0   1   2   3   4   5│ y=0
//   │  6   7   8   9  10  11│ y=1
//   │ 12  13  14  15  16  17│ y=2
//   │ 18  19  20  21  22  23│ y=3
//   │ 24  25  26  27  28  29│ y=4
//   │ 30  31  32  33  34  35│ y=5
//   │ 36  37  38  39  40  41│ y=6
//   │ 42  43  44  45  46  47│ y=7
//   │ 48  49  50  51  52  53│ y=8
//   │ 54  55  56  57  58  59│ y=9
//   └───────────────────────┘
//
// =============================================================================
// CODES BIT6 DES PIÈCES
// =============================================================================
//
// Chaque pentomino a un code unique sur 6 bits :
//
//   ┌──────────┬────────┬────────────┐
//   │  Pièce   │  bit6  │  Binaire   │
//   ├──────────┼────────┼────────────┤
//   │  X (1)   │    7   │  0b000111  │
//   │  F (2)   │   11   │  0b001011  │
//   │  T (3)   │   19   │  0b010011  │
//   │  W (4)   │   35   │  0b100011  │
//   │  Z (5)   │   13   │  0b001101  │
//   │  U (6)   │   21   │  0b010101  │
//   │  V (7)   │   37   │  0b100101  │
//   │  Y (8)   │   25   │  0b011001  │
//   │  N (9)   │   41   │  0b101001  │
//   │  P (10)  │   49   │  0b110001  │
//   │  L (11)  │   14   │  0b001110  │
//   │  I (12)  │   22   │  0b010110  │
//   └──────────┴────────┴────────────┘
//
// =============================================================================
// ALGORITHME DE COMPATIBILITÉ
// =============================================================================
//
// Pour vérifier si un plateau partiel est compatible avec une solution :
//
// 1. Convertir le plateau en deux BigInt :
//    - piecesBits : codes bit6 des pièces placées (0 pour cases vides)
//    - maskBits   : 0x3F (6 bits à 1) pour cases occupées, 0 sinon
//
// 2. Tester chaque solution :
//    compatible = (solution & maskBits) == piecesBits
//
// Exemple :
//   Plateau avec pièce T aux cases 0,1,2 :
//   piecesBits = (19 << 354) | (19 << 348) | (19 << 342) | 0...0
//   maskBits   = (63 << 354) | (63 << 348) | (63 << 342) | 0...0
//
// =============================================================================
// RECONSTRUCTION PlacedPiece
// =============================================================================
//
// Pour reconstruire les PlacedPiece à partir d'un BigInt :
//
// 1. Décoder le BigInt en grille de 60 codes bit6
// 2. Grouper les cellules par code bit6 (= par pièce)
// 3. Pour chaque pièce :
//    a. Trouver le Pento correspondant au bit6
//    b. Calculer minX, minY des cellules → gridX, gridY
//    c. Normaliser les cellules (décaler vers origine 0,0)
//    d. Comparer avec cartesianCoords pour trouver positionIndex
//
// =============================================================================

import 'dart:math' show min;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/placed_piece.dart';
import 'package:pentapol/common/point.dart';

// =============================================================================
// CLASSE SolutionInfo
// =============================================================================

/// Information détaillée sur une solution identifiée.
///
/// Cette classe permet de retrouver l'origine complète d'une solution :
/// - Son index absolu parmi les 9356 solutions (0-9355)
/// - Sa solution canonique d'origine parmi les 2339 familles (0-2338)
/// - Le type de transformation géométrique appliquée
///
/// ## Exemple d'utilisation
/// ```dart
/// final info = SolutionInfo(42);
/// print(info.index);          // 42
/// print(info.canonicalIndex); // 10 (= 42 ~/ 4)
/// print(info.variantType);    // 2 (= 42 % 4 = miroir horizontal)
/// print(info.variantName);    // "miroir horizontal"
/// ```
///
/// ## Relation index ↔ canonique ↔ variante
/// ```
/// index = canonicalIndex * 4 + variantType
///
/// Exemple pour la famille canonique 10 :
///   Index 40 = famille 10, identité
///   Index 41 = famille 10, rotation 180°
///   Index 42 = famille 10, miroir horizontal
///   Index 43 = famille 10, miroir vertical
/// ```
class SolutionInfo {
  /// Index absolu de la solution (0-9355).
  ///
  /// Cet index est unique et identifie complètement une solution
  /// parmi toutes les variantes générées.
  final int index;

  /// Index de la solution canonique d'origine (0-2338).
  ///
  /// Identifie la "famille" de la solution, avant application
  /// des transformations géométriques.
  int get canonicalIndex => index ~/ 4;

  /// Type de variante appliquée à la solution canonique.
  ///
  /// Valeurs possibles :
  /// - 0 : Identité (solution originale)
  /// - 1 : Rotation 180°
  /// - 2 : Miroir horizontal (gauche ↔ droite)
  /// - 3 : Miroir vertical (haut ↔ bas)
  int get variantType => index % 4;

  /// Nom lisible de la variante en français.
  String get variantName => const [
        'identité',
        'rotation 180°',
        'miroir horizontal',
        'miroir vertical',
      ][variantType];

  /// Crée une instance à partir de l'index absolu.
  const SolutionInfo(this.index);

  @override
  String toString() =>
      'Solution #$index (canonique $canonicalIndex, $variantName)';
}

// =============================================================================
// CLASSE SolutionMatcher
// =============================================================================

/// Gestionnaire principal des solutions pentominos 6×10.
///
/// Ce singleton gère :
/// - Le chargement et l'expansion des 2339 solutions canoniques en 9356 variantes
/// - L'encodage/décodage BigInt ↔ grille de codes bit6
/// - La recherche de solutions compatibles avec un plateau partiel
/// - La reconstruction des [PlacedPiece] à partir d'une solution BigInt
///
/// ## Initialisation
///
/// Le matcher doit être initialisé au démarrage de l'application :
/// ```dart
/// final loader = PentapolSolutionsLoader();
/// await loader.load();
/// solutionMatcher.initWithBigIntSolutions(loader.bigIntSolutions);
/// ```
///
/// ## Recherche de compatibilité
///
/// Pour trouver les solutions compatibles avec un plateau partiel :
/// ```dart
/// // Convertir le plateau en masques BigInt
/// final (piecesBits, maskBits) = plateau.toBigIntMasks();
///
/// // Compter les solutions compatibles
/// final count = solutionMatcher.countCompatibleFromBigInts(piecesBits, maskBits);
///
/// // Ou obtenir les indices
/// final indices = solutionMatcher.getCompatibleSolutionIndices(piecesBits, maskBits);
/// ```
///
/// ## Reconstruction des pièces
///
/// Pour obtenir les [PlacedPiece] d'une solution :
/// ```dart
/// final pieces = solutionMatcher.getPlacedPiecesByIndex(42);
/// for (final p in pieces!) {
///   print('${p.piece.id} à (${p.gridX}, ${p.gridY}) pos=${p.positionIndex}');
/// }
/// ```
class SolutionMatcher {
  // ---------------------------------------------------------------------------
  // ÉTAT INTERNE
  // ---------------------------------------------------------------------------

  /// Liste des 9356 solutions (4 variantes × 2339 canoniques).
  ///
  /// Chaque solution est un BigInt de 360 bits encodant les 60 cases
  /// du plateau 6×10 avec le code bit6 de chaque pièce.
  late final List<BigInt> _solutions;

  /// Indique si le matcher a été initialisé.
  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // CONSTANTES
  // ---------------------------------------------------------------------------

  /// Nombre de cases du plateau 6×10.
  static const int _cells = 60;

  /// Masque pour extraire 6 bits (0x3F = 0b111111 = 63).
  static const int _bitMask = 0x3F;

  /// Largeur du plateau en colonnes (x: 0 à 5).
  static const int _width = 6;

  /// Hauteur du plateau en lignes (y: 0 à 9).
  static const int _height = 10;

  // ---------------------------------------------------------------------------
  // CONSTRUCTEUR
  // ---------------------------------------------------------------------------

  /// Crée une instance du matcher (non initialisée).
  ///
  /// Appeler [initWithBigIntSolutions] pour charger les solutions.
  SolutionMatcher() {
    debugPrint(
        '[SOLUTION_MATCHER] Créé (en attente d\'initialisation BigInt)...');
  }

  // ---------------------------------------------------------------------------
  // INITIALISATION
  // ---------------------------------------------------------------------------

  /// Initialise le matcher avec les solutions canoniques.
  ///
  /// Cette méthode :
  /// 1. Reçoit les 2339 solutions canoniques (BigInt)
  /// 2. Génère 4 variantes pour chacune (identité, rot180, mirrorH, mirrorV)
  /// 3. Stocke les 9356 solutions résultantes
  ///
  /// ## Paramètres
  /// - [canonicalSolutions] : Liste des 2339 BigInt canoniques
  ///
  /// ## Note
  /// Cette méthode ne peut être appelée qu'une fois. Les appels suivants
  /// sont ignorés avec un message de debug.
  void initWithBigIntSolutions(List<BigInt> canonicalSolutions) {
    if (_initialized) {
      debugPrint(
          '[SOLUTION_MATCHER] initWithBigIntSolutions déjà appelé, on ignore.');
      return;
    }

    final startTime = DateTime.now();
    final expanded = <BigInt>[];

    for (final canonical in canonicalSolutions) {
      // 1) Décoder le BigInt canonique vers 60 codes bit6
      final baseBoard = _decodeBigIntToBit6Board(canonical);

      // 2) Générer les 4 variantes géométriques
      final rot180 = _rotate180(baseBoard);
      final mirrorH = _mirrorHorizontal(baseBoard);
      final mirrorV = _mirrorVertical(baseBoard);

      // 3) Ré-encoder en BigInt et ajouter dans l'ordre
      expanded.add(_bit6BoardToBigInt(baseBoard)); // index % 4 == 0 : identité
      expanded.add(_bit6BoardToBigInt(rot180)); // index % 4 == 1 : rot 180°
      expanded.add(_bit6BoardToBigInt(mirrorH)); // index % 4 == 2 : miroir H
      expanded.add(_bit6BoardToBigInt(mirrorV)); // index % 4 == 3 : miroir V
    }

    _solutions = List<BigInt>.unmodifiable(expanded);
    _initialized = true;

    final duration = DateTime.now().difference(startTime);
    debugPrint(
      '[SOLUTION_MATCHER] ✓ ${canonicalSolutions.length} solutions canoniques '
      '→ ${_solutions.length} solutions BigInt générées en ${duration.inMilliseconds}ms',
    );
  }

  /// Vérifie que le matcher est initialisé, sinon lève une exception.
  void _checkInitialized() {
    if (!_initialized) {
      throw StateError(
        'SolutionMatcher non initialisé.\n'
        'Appelle solutionMatcher.initWithBigIntSolutions(...) au démarrage.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // ACCESSEURS
  // ---------------------------------------------------------------------------

  /// Nombre total de solutions chargées.
  ///
  /// Retourne 9356 si initialisé correctement, 0 sinon.
  int get totalSolutions {
    if (!_initialized) return 0;
    return _solutions.length;
  }

  /// Accès en lecture seule à toutes les solutions.
  ///
  /// Retourne une liste immuable des 9356 BigInt.
  /// Utile pour le navigateur de solutions.
  ///
  /// ## Lève
  /// [StateError] si le matcher n'est pas initialisé.
  List<BigInt> get allSolutions {
    _checkInitialized();
    return _solutions;
  }

  // ---------------------------------------------------------------------------
  // ENCODAGE / DÉCODAGE BigInt ↔ GRILLE
  // ---------------------------------------------------------------------------

  /// Décode un BigInt (360 bits) en liste de 60 codes bit6.
  ///
  /// ## Convention d'encodage
  /// Le BigInt a été construit ainsi :
  /// ```dart
  /// acc = BigInt.zero;
  /// for (cellIndex in 0..59) {
  ///   acc = (acc << 6) | BigInt.from(bit6Code);
  /// }
  /// ```
  ///
  /// Les bits de poids fort correspondent à la case 0,
  /// les bits de poids faible à la case 59.
  ///
  /// ## Retour
  /// Liste de 60 entiers (0-63), un par case du plateau.
  List<int> _decodeBigIntToBit6Board(BigInt value) {
    final board = List<int>.filled(_cells, 0);
    var v = value;

    // On lit en partant de la fin : case 59, 58, ..., 0
    for (int i = _cells - 1; i >= 0; i--) {
      final code = (v & BigInt.from(_bitMask)).toInt();
      board[i] = code;
      v = v >> 6;
    }

    return board;
  }

  /// Encode une liste de 60 codes bit6 vers un BigInt 360 bits.
  ///
  /// ## Paramètres
  /// - [boardBit6] : Liste de 60 codes (0-63)
  ///
  /// ## Retour
  /// BigInt de 360 bits représentant la solution.
  ///
  /// ## Lève
  /// [ArgumentError] si la liste n'a pas exactement 60 éléments.
  BigInt _bit6BoardToBigInt(List<int> boardBit6) {
    if (boardBit6.length != _cells) {
      throw ArgumentError('Un plateau doit avoir exactement $_cells cases.');
    }

    BigInt acc = BigInt.zero;
    for (final code in boardBit6) {
      acc = (acc << 6) | BigInt.from(code);
    }
    return acc;
  }

  // ---------------------------------------------------------------------------
  // TRANSFORMATIONS GÉOMÉTRIQUES
  // ---------------------------------------------------------------------------

  /// Applique une rotation de 180° au plateau.
  ///
  /// Équivalent à retourner le plateau "tête en bas".
  /// La case (x, y) devient (width-1-x, height-1-y).
  ///
  /// ## Implémentation
  /// Pour un tableau linéaire, `grid[i]` devient `grid[59-i]`.
  List<int> _rotate180(List<int> grid) {
    final rotated = List<int>.filled(_cells, 0);
    for (int i = 0; i < _cells; i++) {
      rotated[i] = grid[_cells - 1 - i];
    }
    return rotated;
  }

  /// Applique un miroir horizontal (gauche ↔ droite).
  ///
  /// La case (x, y) devient (width-1-x, y).
  /// Les colonnes sont inversées, les lignes restent en place.
  List<int> _mirrorHorizontal(List<int> grid) {
    final mirrored = List<int>.filled(_cells, 0);

    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        final srcIndex = y * _width + x;
        final dstIndex = y * _width + (_width - 1 - x);
        mirrored[dstIndex] = grid[srcIndex];
      }
    }
    return mirrored;
  }

  /// Applique un miroir vertical (haut ↔ bas).
  ///
  /// La case (x, y) devient (x, height-1-y).
  /// Les lignes sont inversées, les colonnes restent en place.
  List<int> _mirrorVertical(List<int> grid) {
    final mirrored = List<int>.filled(_cells, 0);

    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        final srcIndex = y * _width + x;
        final dstIndex = (_height - 1 - y) * _width + x;
        mirrored[dstIndex] = grid[srcIndex];
      }
    }
    return mirrored;
  }

  // ---------------------------------------------------------------------------
  // RECHERCHE DE COMPATIBILITÉ
  // ---------------------------------------------------------------------------

  /// Vérifie si une solution est compatible avec un plateau partiel.
  ///
  /// ## Algorithme
  /// Une solution est compatible si, pour toutes les cases occupées
  /// du plateau, la solution a la même pièce.
  ///
  /// Formule : `(solution & maskBits) == piecesBits`
  ///
  /// ## Paramètres
  /// - [piecesBits] : BigInt avec les codes bit6 des pièces placées (0 si vide)
  /// - [maskBits] : BigInt avec 0x3F pour cases occupées, 0 sinon
  /// - [solution] : BigInt de la solution à tester
  ///
  /// ## Retour
  /// `true` si la solution est compatible.
  bool _isCompatibleBigInt(
      BigInt piecesBits, BigInt maskBits, BigInt solution) {
    return (solution & maskBits) == piecesBits;
  }

  /// Compte les solutions compatibles avec un plateau partiel.
  ///
  /// ## Paramètres
  /// - [piecesBits] : Codes bit6 des pièces placées
  /// - [maskBits] : Masque des cases occupées
  ///
  /// ## Retour
  /// Nombre de solutions compatibles (0 à 9356).
  ///
  /// ## Lève
  /// [StateError] si le matcher n'est pas initialisé.
  int countCompatibleFromBigInts(BigInt piecesBits, BigInt maskBits) {
    _checkInitialized();
    int count = 0;
    for (final solution in _solutions) {
      if (_isCompatibleBigInt(piecesBits, maskBits, solution)) {
        count++;
      }
    }
    return count;
  }

  /// Retourne les solutions compatibles sous forme de BigInt.
  ///
  /// Utile pour le navigateur de solutions ou le debug.
  ///
  /// ## Paramètres
  /// - [piecesBits] : Codes bit6 des pièces placées
  /// - [maskBits] : Masque des cases occupées
  ///
  /// ## Retour
  /// Liste des BigInt solutions compatibles.
  List<BigInt> getCompatibleSolutionsFromBigInts(
    BigInt piecesBits,
    BigInt maskBits,
  ) {
    _checkInitialized();
    final out = <BigInt>[];
    for (final solution in _solutions) {
      if (_isCompatibleBigInt(piecesBits, maskBits, solution)) {
        out.add(solution);
      }
    }
    return out;
  }

  /// Retourne les indices des solutions compatibles (0-9355).
  ///
  /// Permet d'identifier et stocker les solutions trouvées.
  ///
  /// ## Paramètres
  /// - [piecesBits] : Codes bit6 des pièces placées
  /// - [maskBits] : Masque des cases occupées
  ///
  /// ## Retour
  /// Liste des indices (0-9355) des solutions compatibles.
  ///
  /// ## Exemple
  /// ```dart
  /// final indices = solutionMatcher.getCompatibleSolutionIndices(piecesBits, maskBits);
  /// for (final idx in indices) {
  ///   final info = SolutionInfo(idx);
  ///   print('Solution $idx (famille ${info.canonicalIndex})');
  /// }
  /// ```
  List<int> getCompatibleSolutionIndices(BigInt piecesBits, BigInt maskBits) {
    _checkInitialized();
    final indices = <int>[];
    for (int i = 0; i < _solutions.length; i++) {
      if (_isCompatibleBigInt(piecesBits, maskBits, _solutions[i])) {
        indices.add(i);
      }
    }
    return indices;
  }

  /// Trouve l'index d'une solution complète exacte.
  ///
  /// Utilisé quand le plateau est complet pour identifier
  /// quelle solution le joueur a trouvée.
  ///
  /// ## Paramètres
  /// - [completeSolution] : BigInt représentant un plateau complet
  ///
  /// ## Retour
  /// - Index de la solution (0-9355) si trouvée
  /// - -1 si la solution n'existe pas dans la base
  int findSolutionIndex(BigInt completeSolution) {
    _checkInitialized();
    for (int i = 0; i < _solutions.length; i++) {
      if (_solutions[i] == completeSolution) {
        return i;
      }
    }
    return -1;
  }

  /// Récupère une solution par son index.
  ///
  /// ## Paramètres
  /// - [index] : Index de la solution (0-9355)
  ///
  /// ## Retour
  /// - BigInt de la solution si l'index est valide
  /// - `null` si l'index est hors limites
  BigInt? getSolutionByIndex(int index) {
    _checkInitialized();
    if (index < 0 || index >= _solutions.length) return null;
    return _solutions[index];
  }

  // ---------------------------------------------------------------------------
  // RECONSTRUCTION BigInt → PlacedPiece
  // ---------------------------------------------------------------------------

  /// Table de correspondance bit6 → pieceId (1-12).
  ///
  /// Construite automatiquement à partir de la liste [pentominos].
  static final Map<int, int> _pieceIdByBit6 = {
    for (final p in pentominos) p.bit6: p.id,
  };

  /// Reconstruit une liste de [PlacedPiece] à partir d'un BigInt solution.
  ///
  /// Cette méthode permet de "désérialiser" une solution compacte
  /// en objets exploitables pour l'affichage ou la manipulation.
  ///
  /// ## Algorithme
  /// 1. Décode le BigInt en grille de 60 codes bit6
  /// 2. Groupe les cellules par code bit6 (= par pièce)
  /// 3. Pour chaque pièce :
  ///    - Trouve le [Pento] correspondant au bit6
  ///    - Calcule minX, minY des cellules → gridX, gridY
  ///    - Normalise les cellules (décale vers origine 0,0)
  ///    - Compare avec [Pento.cartesianCoords] pour trouver positionIndex
  ///
  /// ## Paramètres
  /// - [solution] : BigInt de 360 bits représentant une solution complète
  ///
  /// ## Retour
  /// Liste de 12 [PlacedPiece], une par pentomino.
  ///
  /// ## Exemple
  /// ```dart
  /// final solution = solutionMatcher.getSolutionByIndex(42)!;
  /// final pieces = solutionMatcher.solutionToPlacedPieces(solution);
  ///
  /// for (final p in pieces) {
  ///   print('Pièce ${p.piece.id}:');
  ///   print('  Position: (${p.gridX}, ${p.gridY})');
  ///   print('  Orientation: ${p.positionIndex}');
  ///   print('  Cellules: ${p.absoluteCells.toList()}');
  /// }
  /// ```
  ///
  /// ## Note
  /// Si un code bit6 inconnu est rencontré (ne devrait pas arriver
  /// avec des solutions valides), un message de debug est affiché
  /// et la pièce est ignorée.
  List<PlacedPiece> solutionToPlacedPieces(BigInt solution) {
    final board = _decodeBigIntToBit6Board(solution);
    final result = <PlacedPiece>[];

    // Grouper les cellules par bit6 (pièce)
    final cellsByBit6 = <int, List<Point>>{};
    for (int i = 0; i < _cells; i++) {
      final bit6 = board[i];
      if (bit6 == 0) continue; // case vide (ne devrait pas arriver)
      final x = i % _width;
      final y = i ~/ _width;
      cellsByBit6.putIfAbsent(bit6, () => []).add(Point(x, y));
    }

    // Pour chaque pièce, retrouver le positionIndex
    for (final entry in cellsByBit6.entries) {
      final bit6 = entry.key;
      final cells = entry.value;

      // Trouver le Pento par bit6
      final pieceId = _pieceIdByBit6[bit6];
      if (pieceId == null) {
        debugPrint('[SOLUTION_MATCHER] ⚠ bit6 inconnu: $bit6');
        continue;
      }
      final pento = pentominos[pieceId - 1]; // pieceId est 1-based

      // Calculer les coordonnées minimales (= position d'ancrage)
      final minX = cells.map((c) => c.x).reduce(min);
      final minY = cells.map((c) => c.y).reduce(min);

      // Normaliser les cellules (décaler vers origine 0,0)
      final normalized = cells.map((c) => [c.x - minX, c.y - minY]).toSet();

      // Chercher le positionIndex qui match avec cartesianCoords
      int positionIndex = 0;
      for (int i = 0; i < pento.cartesianCoords.length; i++) {
        final coords = pento.cartesianCoords[i].map((c) => [c[0], c[1]]).toSet();
        if (const SetEquality<List<int>>(ListEquality<int>())
            .equals(coords, normalized)) {
          positionIndex = i;
          break;
        }
      }

      result.add(PlacedPiece(
        piece: pento,
        positionIndex: positionIndex,
        gridX: minX,
        gridY: minY,
      ));
    }

    return result;
  }

  /// Reconstruit les [PlacedPiece] d'une solution par son index.
  ///
  /// Raccourci combinant [getSolutionByIndex] et [solutionToPlacedPieces].
  ///
  /// ## Paramètres
  /// - [index] : Index de la solution (0-9355)
  ///
  /// ## Retour
  /// - Liste de 12 [PlacedPiece] si l'index est valide
  /// - `null` si l'index est hors limites
  ///
  /// ## Exemple
  /// ```dart
  /// final pieces = solutionMatcher.getPlacedPiecesByIndex(42);
  /// if (pieces != null) {
  ///   print('Solution 42 contient ${pieces.length} pièces');
  /// }
  /// ```
  List<PlacedPiece>? getPlacedPiecesByIndex(int index) {
    final solution = getSolutionByIndex(index);
    if (solution == null) return null;
    return solutionToPlacedPieces(solution);
  }
}

// =============================================================================
// SINGLETON GLOBAL
// =============================================================================

/// Instance singleton du [SolutionMatcher].
///
/// Évite de recharger les solutions à chaque utilisation.
/// Doit être initialisé au démarrage de l'application.
///
/// ## Initialisation typique (dans main.dart ou bootstrap.dart)
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Charger les solutions
///   final loader = PentapolSolutionsLoader();
///   await loader.load();
///   solutionMatcher.initWithBigIntSolutions(loader.bigIntSolutions);
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Utilisation
/// ```dart
/// // Compter les solutions compatibles
/// final count = solutionMatcher.countCompatibleFromBigInts(piecesBits, maskBits);
///
/// // Obtenir les pièces d'une solution
/// final pieces = solutionMatcher.getPlacedPiecesByIndex(42);
/// ```
final solutionMatcher = SolutionMatcher();
