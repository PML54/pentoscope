#!/bin/bash

# update_build_info.sh
# Met à jour lib/config/build_info.dart avec la date/heure actuelle

BUILD_INFO_FILE="lib/config/build_info.dart"
VERSION="1.0.0"
BUILD_NUMBER=$(date +%Y%m%d%H%M)  # Format: YYYYMMDDHHMM
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%S")

cat > $BUILD_INFO_FILE << EOF
// GÉNÉRÉ AUTOMATIQUEMENT - NE PAS MODIFIER MANUELLEMENT
// Dernière mise à jour : $BUILD_DATE

/// Informations de build de l'application
class BuildInfo {
  static const String version = '$VERSION';
  static const int buildNumber = $BUILD_NUMBER;
  static const String buildDate = '$BUILD_DATE';

  static String get buildDateFormatted {
    final dt = DateTime.parse(buildDate);
    return '\${dt.day.toString().padLeft(2, '0')}/'
           '\${dt.month.toString().padLeft(2, '0')}/'
           '\${dt.year} à '
           '\${dt.hour.toString().padLeft(2, '0')}:'
           '\${dt.minute.toString().padLeft(2, '0')}';
  }

  static String get fullVersion => '\$version (\$buildNumber)';
  static String get versionWithDate => '\$fullVersion - \$buildDateFormatted';

  static const String appName = 'Pentapol';
  static const String description = 'Puzzles Pentominos';
  static const String author = 'PML';
  static const String copyrightYear = '2025';

  BuildInfo._();
}
EOF

echo "✅ build_info.dart mis à jour : $BUILD_DATE"