// Généré automatiquement - Ne pas modifier manuellement
// Pentominos avec numéros de cases sur grille 5×5
// Numérotation: ligne 1 (bas) = cases 1-5, ligne 2 = cases 6-10, etc.

class Pento {
  final int id;
  final int size;
  final List<List<int>> orientations;
  final int numOrientations;
  final List<int> baseShape;
  
  const Pento({
    required this.id,
    required this.size,
    required this.orientations,
    required this.numOrientations,
    required this.baseShape,
  });
}

final List<Pento> pentominos = [
  // Pièce 1
  Pento(
    id: 1,
    size: 5,
    numOrientations: 1,
    baseShape: [2, 6, 7, 8, 12],
    orientations: [
      [6, 2, 7, 12, 8],
    ],
  ),

  // Pièce 2
  Pento(
    id: 2,
    size: 5,
    numOrientations: 8,
    baseShape: [1, 2, 6, 7, 12],
    orientations: [
      [1, 6, 2, 7, 12],
      [3, 2, 8, 7, 6],
      [12, 7, 11, 6, 1],
      [6, 7, 1, 2, 3],
      [2, 7, 1, 6, 11],
      [8, 7, 3, 2, 1],
      [11, 6, 12, 7, 2],
      [1, 2, 6, 7, 8],
    ],
  ),

  // Pièce 3
  Pento(
    id: 3,
    size: 5,
    numOrientations: 4,
    baseShape: [3, 6, 7, 8, 13],
    orientations: [
      [6, 7, 3, 8, 13],
      [2, 7, 13, 12, 11],
      [8, 7, 11, 6, 1],
      [12, 7, 1, 2, 3],
    ],
  ),

  // Pièce 4
  Pento(
    id: 4,
    size: 5,
    numOrientations: 8,
    baseShape: [2, 3, 6, 7, 12],
    orientations: [
      [6, 2, 7, 12, 3],
      [2, 8, 7, 6, 13],
      [8, 12, 7, 2, 11],
      [12, 6, 7, 8, 1],
      [8, 2, 7, 12, 1],
      [12, 8, 7, 6, 3],
      [6, 12, 7, 2, 13],
      [2, 6, 7, 8, 11],
    ],
  ),

  // Pièce 5
  Pento(
    id: 5,
    size: 5,
    numOrientations: 8,
    baseShape: [2, 7, 11, 12, 17],
    orientations: [
      [11, 2, 7, 12, 17],
      [2, 9, 8, 7, 6],
      [7, 16, 11, 6, 1],
      [8, 1, 2, 3, 4],
      [12, 1, 6, 11, 16],
      [7, 4, 3, 2, 1],
      [6, 17, 12, 7, 2],
      [3, 6, 7, 8, 9],
    ],
  ),

  // Pièce 6
  Pento(
    id: 6,
    size: 5,
    numOrientations: 4,
    baseShape: [3, 8, 11, 12, 13],
    orientations: [
      [11, 12, 3, 8, 13],
      [1, 6, 13, 12, 11],
      [3, 2, 11, 6, 1],
      [13, 8, 1, 2, 3],
    ],
  ),

  // Pièce 7
  Pento(
    id: 7,
    size: 5,
    numOrientations: 4,
    baseShape: [1, 3, 6, 7, 8],
    orientations: [
      [1, 6, 7, 3, 8],
      [2, 1, 6, 12, 11],
      [8, 3, 2, 6, 1],
      [11, 12, 7, 1, 2],
    ],
  ),

  // Pièce 8
  Pento(
    id: 8,
    size: 5,
    numOrientations: 8,
    baseShape: [4, 6, 7, 8, 9],
    orientations: [
      [6, 7, 8, 4, 9],
      [1, 6, 11, 17, 16],
      [4, 3, 2, 6, 1],
      [17, 12, 7, 1, 2],
      [9, 8, 7, 1, 6],
      [16, 11, 6, 2, 1],
      [1, 2, 3, 9, 4],
      [2, 7, 12, 16, 17],
    ],
  ),

  // Pièce 9
  Pento(
    id: 9,
    size: 5,
    numOrientations: 8,
    baseShape: [3, 4, 6, 7, 8],
    orientations: [
      [6, 7, 3, 8, 4],
      [1, 6, 12, 11, 17],
      [4, 3, 7, 2, 6],
      [17, 12, 6, 7, 1],
      [9, 8, 2, 7, 1],
      [16, 11, 7, 6, 2],
      [1, 2, 8, 3, 9],
      [2, 7, 11, 12, 16],
    ],
  ),

  // Pièce 10
  Pento(
    id: 10,
    size: 5,
    numOrientations: 4,
    baseShape: [3, 6, 7, 8, 11],
    orientations: [
      [6, 11, 7, 3, 8],
      [2, 1, 7, 13, 12],
      [8, 13, 7, 1, 6],
      [12, 11, 7, 3, 2],
    ],
  ),

  // Pièce 11
  Pento(
    id: 11,
    size: 5,
    numOrientations: 4,
    baseShape: [3, 7, 8, 11, 12],
    orientations: [
      [11, 7, 12, 3, 8],
      [1, 7, 6, 13, 12],
      [3, 7, 2, 11, 6],
      [13, 7, 8, 1, 2],
    ],
  ),

  // Pièce 12
  Pento(
    id: 12,
    size: 5,
    numOrientations: 2,
    baseShape: [1, 6, 11, 16, 21],
    orientations: [
      [1, 6, 11, 16, 21],
      [5, 4, 3, 2, 1],
    ],
  ),
];
