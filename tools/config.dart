// tools/config.dart
// Configuration centralisée pour tous les scripts
// Modifier ce fichier pour adapter les scripts à une autre application

// ============ Application ============
const String APP_NAME = 'pentapol';
const String PACKAGE_NAME = 'pentapol';
const String APP_DESCRIPTION = 'Pentapol - Analyse du code Flutter/Dart';

// ============ Chemins ============
const String LIB_PATH = 'lib';
const String TOOLS_PATH = 'tools';
const String DB_PATH = 'tools/db';
const String CSV_PATH = 'tools/csv';
const String DOCS_PATH = 'tools/docs';

// ============ Base de données ============
const String DB_NAME = 'pentapol.db';
const String DB_FULL_PATH = 'tools/db/pentapol.db';
const String SCHEMA_FILE = 'tools/db/schema.sql';

// ============ CSVs ============
const String CSV_DARTFILES = 'tools/csv/pentapol_dart_files.csv';
const String CSV_IMPORTS = 'tools/csv/pentapol_imports.csv';
const String CSV_ORPHANFILES = 'tools/csv/pentapol_orphan_files.csv';
const String CSV_ENDFILES = 'tools/csv/pentapol_end_files.csv';
const String CSV_FUNCTIONS = 'tools/csv/pentapol_functions.csv';

// ============ Modules (à adapter selon votre app) ============
const List<String> MAIN_MODULES = [
  'classical',
  'pentoscope',
  'isopento',
  'duel',
  'tutorial',
];

const String COMMON_MODULE = 'common';

// ============ Fichiers à ignorer (patterns) ============
const List<String> IGNORE_FILES = [
  'main.dart',
  'bootstrap.dart',
];

// ============ Fonctions à ignorer (patterns) ============
// Les fonctions commençant par _ sont automatiquement ignorées
const List<String> IGNORE_FUNCTIONS = [
  'build',  // Trop courant, optionnel
];

// ============ ANSI Colors (ne pas modifier) ============
const String COLOR_RED = '\x1B[31m';
const String COLOR_GREEN = '\x1B[32m';
const String COLOR_YELLOW = '\x1B[33m';
const String COLOR_BOLD = '\x1B[1m';
const String COLOR_RESET = '\x1B[0m';

// ============ Helper pour construire les chemins ============
String getDbPath() => DB_FULL_PATH;
String getCsvPath(String csvName) => '$CSV_PATH/$csvName';
String getDocsPath() => DOCS_PATH;

/// Affiche la configuration courante
void printConfig() {
  print('${COLOR_BOLD}=== Configuration ===${COLOR_RESET}');
  print('App: $APP_NAME ($PACKAGE_NAME)');
  print('Lib: $LIB_PATH');
  print('DB: $DB_FULL_PATH');
  print('Modules: ${MAIN_MODULES.join(", ")}');
  print('');
}