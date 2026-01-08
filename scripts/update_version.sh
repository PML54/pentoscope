#!/bin/bash
# scripts/update_version.sh
# Met à jour build_info.dart avec la date/heure actuelle
# Usage: ./scripts/update_version.sh [VERSION]
# Exemple: ./scripts/update_version.sh 1.2.0

# Configuration
BUILD_INFO_FILE="lib/config/build_info.dart"
DEFAULT_VERSION="1.0.0"

# Paramètres
VERSION="${1:-$DEFAULT_VERSION}"
BUILD_NUMBER=$(date +%Y%m%d%H%M)  # Format: YYYYMMDDHHMM (ex: 202511301530)
BUILD_DATE=$(date +"%Y-%m-%dT%H:%M:%S")
BUILD_DATE_FR=$(date +"%d/%m/%Y à %H:%M")

# Créer le dossier si nécessaire
mkdir -p "$(dirname "$BUILD_INFO_FILE")"

# Générer le fichier
cat > "$BUILD_INFO_FILE" << EOF
// GÉNÉRÉ AUTOMATIQUEMENT par scripts/update_version.sh
// NE PAS MODIFIER MANUELLEMENT
// Dernière génération : $BUILD_DATE_FR

/// Informations de build de l'application
class BuildInfo {
  /// Version de l'application (format semver)
  static const String version = '$VERSION';

  /// Numéro de build (format YYYYMMDDHHMM)
  static const int buildNumber = $BUILD_NUMBER;

  /// Date et heure du build (ISO 8601)
  static const String buildDate = '$BUILD_DATE';

  /// Date formatée pour affichage
  static String get buildDateFormatted {
    final dt = DateTime.parse(buildDate);
    return '\${dt.day.toString().padLeft(2, '0')}/'
           '\${dt.month.toString().padLeft(2, '0')}/'
           '\${dt.year} à '
           '\${dt.hour.toString().padLeft(2, '0')}:'
           '\${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Version complète pour affichage
  static String get fullVersion => '\$version (\$buildNumber)';

  /// Chaîne complète avec date
  static String get versionWithDate => '\$fullVersion - \$buildDateFormatted';

  /// Nom de l'application
  static const String appName = 'Pentapol';

  /// Description courte
  static const String description = 'Puzzles Pentominos';

  /// Auteur
  static const String author = 'PML';

  /// Année de copyright
  static const String copyrightYear = '2025';

  /// Ne pas instancier
  BuildInfo._();
}
EOF

echo "✅ $BUILD_INFO_FILE mis à jour"
echo "   Version: $VERSION"
echo "   Build:   $BUILD_NUMBER"
echo "   Date:    $BUILD_DATE_FR"