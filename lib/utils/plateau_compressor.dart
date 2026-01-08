// Modified: 2025-11-15 06:45:00
// lib/utils/plateau_compressor.dart
/// Utilitaire pour compresser et canoniser les plateaux de pentomino.
/// 
/// Permet de:
/// - Encoder un plateau en 8 int32 (240 bits, 4 bits par cellule)
/// - Générer les 8 variantes (rotations + miroirs)
/// - Trouver la forme canonique (la plus petite numériquement)
/// - Détecter les doublons
library;

import 'package:pentapol/common/plateau.dart';

/// Compresseur de plateau avec détection de forme canonique.
class PlateauCompressor {
  /// Encode un plateau en List<int> compact (8 int32 = 240 bits).
  /// 
  /// Chaque cellule utilise 4 bits (0-15):
  /// - 0: vide
  /// - 1-12: numéro de pièce
  /// - 13: cellule cachée
  static List<int> encode(Plateau plateau) {
    final result = List<int>.filled(8, 0);
    
    for (int cellNum = 1; cellNum <= 60; cellNum++) {
      // Convertir cellNum en (x, y)
      final cellIndex = cellNum - 1;
      final x = cellIndex % 6;
      final y = cellIndex ~/ 6;
      
      final value = plateau.getCell(x, y);
      
      // Convertir en valeur 4 bits
      int encoded;
      if (value == 0) {
        encoded = 0; // Vide
      } else if (value == -1) {
        encoded = 13; // Cachée
      } else {
        encoded = value; // Pièce 1-12
      }
      
      // Stocker dans le bon int32
      final intIndex = cellIndex ~/ 8; // Quel int32 (0-7)
      final bitOffset = (cellIndex % 8) * 4; // Position dans l'int32 (0-28)
      
      result[intIndex] |= (encoded << bitOffset);
    }
    
    return result;
  }
  
  /// Décode un List<int> compact en Plateau.
  static Plateau decode(List<int> encoded) {
    final plateau = Plateau.allVisible(6, 10);
    
    for (int cellNum = 1; cellNum <= 60; cellNum++) {
      final cellIndex = cellNum - 1;
      final x = cellIndex % 6;
      final y = cellIndex ~/ 6;
      
      final intIndex = cellIndex ~/ 8;
      final bitOffset = (cellIndex % 8) * 4;
      
      final value = (encoded[intIndex] >> bitOffset) & 0xF;
      
      // Convertir en valeur plateau
      if (value == 0) {
        plateau.setCell(x, y, 0); // Vide
      } else if (value == 13) {
        plateau.setCell(x, y, -1); // Cachée
      } else {
        plateau.setCell(x, y, value); // Pièce 1-12
      }
    }
    
    return plateau;
  }
  
  /// Rotation 90° horaire.
  /// Transformation: (x, y) → (9-y, x)
  /// où x ∈ [0,5] et y ∈ [0,9]
  static List<int> rotate90(List<int> encoded) {
    final plateau = decode(encoded);
    final rotated = Plateau.allVisible(6, 10);
    
    for (int x = 0; x < 6; x++) {
      for (int y = 0; y < 10; y++) {
        final value = plateau.getCell(x, y);
        
        // Nouvelle position après rotation
        final newX = 9 - y;
        final newY = x;
        
        rotated.setCell(newX, newY, value);
      }
    }
    
    return encode(rotated);
  }
  
  /// Rotation 180°.
  static List<int> rotate180(List<int> encoded) {
    return rotate90(rotate90(encoded));
  }
  
  /// Rotation 270° horaire.
  static List<int> rotate270(List<int> encoded) {
    return rotate90(rotate180(encoded));
  }
  
  /// Miroir horizontal.
  /// Transformation: (x, y) → (5-x, y)
  static List<int> mirrorH(List<int> encoded) {
    final plateau = decode(encoded);
    final mirrored = Plateau.allVisible(6, 10);
    
    for (int x = 0; x < 6; x++) {
      for (int y = 0; y < 10; y++) {
        final value = plateau.getCell(x, y);
        
        // Nouvelle position après miroir
        final newX = 5 - x;
        final newY = y;
        
        mirrored.setCell(newX, newY, value);
      }
    }
    
    return encode(mirrored);
  }
  
  /// Génère les 8 variantes équivalentes (4 rotations × 2 miroirs).
  static List<List<int>> generateVariants(List<int> encoded) {
    final variants = <List<int>>[];
    
    // Original + 3 rotations
    variants.add(encoded);
    variants.add(rotate90(encoded));
    variants.add(rotate180(encoded));
    variants.add(rotate270(encoded));
    
    // Miroir + 3 rotations
    final mirrored = mirrorH(encoded);
    variants.add(mirrored);
    variants.add(rotate90(mirrored));
    variants.add(rotate180(mirrored));
    variants.add(rotate270(mirrored));
    
    return variants;
  }
  
  /// Compare deux encodages (ordre lexicographique).
  /// 
  /// Retourne:
  /// - < 0 si a < b
  /// - 0 si a == b
  /// - > 0 si a > b
  static int compare(List<int> a, List<int> b) {
    for (int i = 0; i < 8; i++) {
      // Comparaison non signée
      final ua = a[i] & 0xFFFFFFFF;
      final ub = b[i] & 0xFFFFFFFF;
      
      if (ua < ub) return -1;
      if (ua > ub) return 1;
    }
    return 0;
  }
  
  /// Trouve la forme canonique (la plus petite numériquement) parmi les 8 variantes.
  static List<int> findCanonical(List<int> encoded) {
    final variants = generateVariants(encoded);
    
    List<int> canonical = variants[0];
    
    for (int i = 1; i < variants.length; i++) {
      if (compare(variants[i], canonical) < 0) {
        canonical = variants[i];
      }
    }
    
    return canonical;
  }
  
  /// Convertit un List<int> en String pour débogage.
  static String toDebugString(List<int> encoded) {
    return encoded.map((i) => i.toRadixString(16).padLeft(8, '0')).join(' ');
  }
  
  /// Vérifie si deux encodages sont équivalents (même forme canonique).
  static bool areEquivalent(List<int> a, List<int> b) {
    final canonicalA = findCanonical(a);
    final canonicalB = findCanonical(b);
    return compare(canonicalA, canonicalB) == 0;
  }
}

