// GÉNÉRÉ AUTOMATIQUEMENT par scripts/update_version.sh
// NE PAS MODIFIER MANUELLEMENT
// Dernière génération : 15/01/2026 à 05:15

/// Informations de build de l'application
class BuildInfo {
  /// Version de l'application (format semver)
  static const String version = '1.0.1';

  /// Numéro de build (format YYYYMMDDHHMM)
  static const int buildNumber = 202601150515;

  /// Date et heure du build (ISO 8601)
  static const String buildDate = '2026-01-15T05:15:11';

  /// Date formatée pour affichage
  static String get buildDateFormatted {
    final dt = DateTime.parse(buildDate);
    return '${dt.day.toString().padLeft(2, '0')}/'
           '${dt.month.toString().padLeft(2, '0')}/'
           '${dt.year} à '
           '${dt.hour.toString().padLeft(2, '0')}:'
           '${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Version complète pour affichage
  static String get fullVersion => '$version ($buildNumber)';

  /// Chaîne complète avec date
  static String get versionWithDate => '$fullVersion - $buildDateFormatted';

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
