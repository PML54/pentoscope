-- tools/db/schema.sql
-- Schéma de base pour Pentapol - analyse d'impact du code
-- TOUTES les tables sont recréées à chaque analyse (DROP IF EXISTS)
-- Pas d'historique, données fraîches à chaque scan

-- Détruire toutes les tables (dans le bon ordre)
DROP TABLE IF EXISTS violations;
DROP TABLE IF EXISTS duplicate_functions;
DROP TABLE IF EXISTS importbad;
DROP TABLE IF EXISTS functions;
DROP TABLE IF EXISTS orphanfiles;
DROP TABLE IF EXISTS endfiles;
DROP TABLE IF EXISTS imports;
DROP TABLE IF EXISTS dartfiles;
DROP TABLE IF EXISTS scans;

-- Table: scans
-- Enregistre l'exécution courante du script
CREATE TABLE scans (
  scan_id INTEGER PRIMARY KEY AUTOINCREMENT,
  scan_date VARCHAR(6) NOT NULL,        -- YYMMDD
  scan_time VARCHAR(6) NOT NULL,        -- HHMMSS
  total_files INTEGER,
  total_size_bytes BIGINT,
  notes TEXT
);

-- Table: dartfiles
-- Import du CSV pentapol_dart_files.csv
-- Contient les données du scan courant uniquement
CREATE TABLE dartfiles (
  dart_id INTEGER PRIMARY KEY AUTOINCREMENT,
  filename VARCHAR(255) NOT NULL,
  first_dir VARCHAR(50) NOT NULL,
  relative_path VARCHAR(500) NOT NULL,
  size_bytes BIGINT NOT NULL,
  mod_date VARCHAR(6) NOT NULL,
  mod_time VARCHAR(6) NOT NULL,
  UNIQUE(relative_path)
);

-- Index pour les recherches
CREATE INDEX idx_dartfiles_first_dir ON dartfiles(first_dir);
CREATE INDEX idx_dartfiles_relative_path ON dartfiles(relative_path);
CREATE INDEX idx_dartfiles_mod_date ON dartfiles(mod_date);

-- Table: imports
-- Chaque import d'un fichier dart = un record
-- Si un dart a 5 imports -> 5 records
CREATE TABLE imports (
  import_id INTEGER PRIMARY KEY AUTOINCREMENT,
  dart_id INTEGER NOT NULL,
  import_path VARCHAR(500) NOT NULL,      -- ex: package:pentapol/common/game.dart
  FOREIGN KEY (dart_id) REFERENCES dartfiles(dart_id)
);

CREATE INDEX idx_imports_dart_id ON imports(dart_id);
CREATE INDEX idx_imports_path ON imports(import_path);

-- Table: orphanfiles
-- Fichiers .dart qui ne sont importés par aucun autre fichier
CREATE TABLE orphanfiles (
  dart_id INTEGER NOT NULL,
  relative_path VARCHAR(500) NOT NULL,
  first_dir VARCHAR(50) NOT NULL,
  filename VARCHAR(255) NOT NULL,
  FOREIGN KEY (dart_id) REFERENCES dartfiles(dart_id),
  UNIQUE(dart_id)
);

CREATE INDEX idx_orphanfiles_dart_id ON orphanfiles(dart_id);
CREATE INDEX idx_orphanfiles_first_dir ON orphanfiles(first_dir);

-- Table: endfiles
-- Fichiers .dart qui n'importent AUCUN dart du package pentapol
-- Ce sont les "feuilles" de l'arbre de dépendances
CREATE TABLE endfiles (
  dart_id INTEGER NOT NULL,
  relative_path VARCHAR(500) NOT NULL,
  first_dir VARCHAR(50) NOT NULL,
  filename VARCHAR(255) NOT NULL,
  FOREIGN KEY (dart_id) REFERENCES dartfiles(dart_id),
  UNIQUE(dart_id)
);

CREATE INDEX idx_endfiles_dart_id ON endfiles(dart_id);
CREATE INDEX idx_endfiles_first_dir ON endfiles(first_dir);

-- Table: functions
-- Fonctions publiques de chaque fichier .dart
CREATE TABLE functions (
  function_id INTEGER PRIMARY KEY AUTOINCREMENT,
  dart_id INTEGER NOT NULL,
  return_type VARCHAR(100),            -- Ex: 'void', 'int', 'String', 'Future<bool>', etc.
  function_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (dart_id) REFERENCES dartfiles(dart_id),
  UNIQUE(dart_id, return_type, function_name)
);

CREATE INDEX idx_functions_dart_id ON functions(dart_id);
CREATE INDEX idx_functions_name ON functions(function_name);
CREATE INDEX idx_functions_return_type ON functions(return_type);

-- Table: duplicate_functions
-- Fonctions qui apparaissent dans plusieurs fichiers .dart
CREATE TABLE duplicate_functions (
  duplicate_id INTEGER PRIMARY KEY AUTOINCREMENT,
  function_name VARCHAR(255) NOT NULL,
  dart_id INTEGER NOT NULL,
  relative_path VARCHAR(500) NOT NULL,
  first_dir VARCHAR(50) NOT NULL,
  occurrence_count INTEGER NOT NULL,
  FOREIGN KEY (dart_id) REFERENCES dartfiles(dart_id)
);
ALTER TABLE duplicate_functions ADD COLUMN filename TEXT;

CREATE INDEX idx_duplicate_functions_name ON duplicate_functions(function_name);
CREATE INDEX idx_duplicate_functions_dart_id ON duplicate_functions(dart_id);

-- Table: importbad
-- Imports relatifs (non absolus) détectés
CREATE TABLE importbad (
  importbad_id INTEGER PRIMARY KEY AUTOINCREMENT,
  dart_id INTEGER NOT NULL,
  relative_path VARCHAR(500) NOT NULL,
  line_number INTEGER NOT NULL,
  import_path VARCHAR(500) NOT NULL,
  FOREIGN KEY (dart_id) REFERENCES dartfiles(dart_id)
);

CREATE INDEX idx_importbad_dart_id ON importbad(dart_id);
CREATE INDEX idx_importbad_path ON importbad(relative_path);

-- Table: violations
-- Violations détectées (isolation, imports relatifs, etc.)
CREATE TABLE violations (
  violation_id INTEGER PRIMARY KEY AUTOINCREMENT,
  relative_path VARCHAR(500),             -- Référence à dartfiles
  violation_type VARCHAR(50) NOT NULL,    -- 'isolation', 'relative_import', etc.
  module_from VARCHAR(50),                -- module qui importe
  module_to VARCHAR(50),                  -- module importé (si applicable)
  import_path VARCHAR(500),
  line_number INTEGER,
  severity VARCHAR(10),                   -- 'error', 'warning'
  FOREIGN KEY (relative_path) REFERENCES dartfiles(relative_path)
);

CREATE INDEX idx_violations_relative_path ON violations(relative_path);
CREATE INDEX idx_violations_type ON violations(violation_type);
CREATE TABLE IF NOT EXISTS transverse_duplicates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  function_name TEXT NOT NULL,
  nb_dirs INTEGER NOT NULL,
  occurrences INTEGER NOT NULL,
  dirs TEXT NOT NULL,
  last_updated TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_transverse_duplicates_name
ON transverse_duplicates(function_name);
