// lib/services/isometry_transforms.dart
// Modified: 2512092100

/// Applique une rotation autour d'un point P0
///
/// [coords] : Liste de coordonnées [[x1,y1], [x2,y2], ...]
/// [centerX], [centerY] : Coordonnées du centre de rotation P0
/// [quarterTurns] : Nombre de quarts de tour (multiple de π/2)
///   - 1 = 90° anti-horaire
///   - -1 = 90° horaire (270° anti-horaire)
///   - 2 = 180°
///   - 0 = identité
///
/// Retourne la liste transformée L2
List<List<int>> rotateAroundPoint(
    List<List<int>> coords,
    int centerX,
    int centerY,
    int quarterTurns,
    ) {
  // Normaliser l'angle (0, 1, 2, 3)
  final turns = quarterTurns % 4;

  return coords.map((coord) {
    final x = coord[0];
    final y = coord[1];

    // Translater vers l'origine
    final dx = x - centerX;
    final dy = y - centerY;

    // Appliquer la rotation
    int rotatedX, rotatedY;
    switch (turns) {
      case 0:
      // Identité
        rotatedX = dx;
        rotatedY = dy;
        break;
      case 1:
      // 90° anti-horaire : (x,y) → (-y, x)
        rotatedX = -dy;
        rotatedY = dx;
        break;
      case 2:
      // 180° : (x,y) → (-x, -y)
        rotatedX = -dx;
        rotatedY = -dy;
        break;
      case 3:
      // 270° anti-horaire : (x,y) → (y, -x)
        rotatedX = dy;
        rotatedY = -dx;
        break;
      default:
        rotatedX = dx;
        rotatedY = dy;
    }

    // Translater pour remettre P0 à sa place
    return [rotatedX + centerX, rotatedY + centerY];
  }).toList();
}

/// Applique une symétrie horizontale par rapport à la droite y = y0
///
/// [coords] : Liste de coordonnées [[x1,y1], [x2,y2], ...]
/// [axisY] : Ordonnée de la droite horizontale de symétrie
///
/// Retourne la liste transformée L2
List<List<int>> flipHorizontal(
    List<List<int>> coords,
    int axisY,
    ) {
  return coords.map((coord) {
    final x = coord[0];
    final y = coord[1];

    // Symétrie par rapport à y = axisY : (x, y) → (x, 2*axisY - y)
    return [x, 2 * axisY - y];
  }).toList();
}

/// Applique une symétrie verticale par rapport à la droite x = x0
///
/// [coords] : Liste de coordonnées [[x1,y1], [x2,y2], ...]
/// [axisX] : Abscisse de la droite verticale de symétrie
///
/// Retourne la liste transformée L2
List<List<int>> flipVertical(
    List<List<int>> coords,
    int axisX,
    ) {
  return coords.map((coord) {
    final x = coord[0];
    final y = coord[1];

    // Symétrie par rapport à x = axisX : (x, y) → (2*axisX - x, y)
    return [2 * axisX - x, y];
  }).toList();
}