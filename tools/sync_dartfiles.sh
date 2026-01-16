#!/bin/bash

# tools/sync_dartfiles.sh - VERSION CORRIGÉE
# Modified: 2025-01-15T11:45:00
# Orchestre:
# 1) Génération du CSV dartfiles (scan_dart_files.dart)
# 2) Récréation des tables (schema.sql)
# 3) Import du CSV dartfiles
# 4) Extraction des imports (extract_imports.dart)
# 5) Import du CSV imports
# 6) Vérification des fichiers orphelins
# 7) Vérification des fichiers sans dépendances
# 8) Extraction des fonctions publiques
# 9) Import des fonctions publiques
# 10) NOUVEAU: Exécution de check_duplicate_functions.dart avec insertion DB
# 11) Vérification des imports relatifs
# 12) Import des imports relatifs
# 13) Génération de la documentation

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Chemins (compatible macOS)
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
TOOLS_DIR="$PROJECT_ROOT/tools"
DB_DIR="$TOOLS_DIR/db"
CSV_DIR="$TOOLS_DIR/csv"
CSV_DARTFILES="$CSV_DIR/pentapol_dart_files.csv"
CSV_IMPORTS="$CSV_DIR/pentapol_imports.csv"
SCHEMA_FILE="$DB_DIR/schema.sql"
DB_FILE="$DB_DIR/pentapol.db"

printf "${BOLD}=== Sync DartFiles & Imports ===${NC}\n\n"

# Vérifier que les répertoires existent
if [ ! -d "$DB_DIR" ]; then
  mkdir -p "$DB_DIR"
fi
if [ ! -d "$CSV_DIR" ]; then
  mkdir -p "$CSV_DIR"
fi

# Étape 1: Générer le CSV dartfiles
printf "${YELLOW}1. Génération du CSV dartfiles...${NC}\n"
cd "$PROJECT_ROOT"
dart tools/scan_dart_files.dart

if [ ! -f "$CSV_DARTFILES" ]; then
  printf "${RED}✗ Erreur: CSV dartfiles non généré${NC}\n"
  exit 1
fi
printf "${GREEN}✓ CSV généré: $CSV_DARTFILES${NC}\n\n"

# Étape 2: Créer/réinitialiser la DB
printf "${YELLOW}2. Récréation des tables...${NC}\n"
if [ ! -f "$DB_FILE" ]; then
  printf "${YELLOW}  Création de la DB: $DB_FILE${NC}\n"
  touch "$DB_FILE"
fi

# Exécuter le schéma SQL
sqlite3 "$DB_FILE" < "$SCHEMA_FILE"
printf "${GREEN}✓ Tables recréées${NC}\n\n"

# Étape 3: Importer le CSV dartfiles
printf "${YELLOW}3. Import du CSV dartfiles...${NC}\n"

sqlite3 "$DB_FILE" <<EOF
CREATE TEMP TABLE temp_dartfiles (
  filename VARCHAR(255),
  first_dir VARCHAR(50),
  relative_path VARCHAR(500),
  size_bytes BIGINT,
  mod_date VARCHAR(6),
  mod_time VARCHAR(6)
);

.mode csv
.import $CSV_DARTFILES temp_dartfiles

DELETE FROM temp_dartfiles WHERE filename = 'filename';

INSERT INTO dartfiles (filename, first_dir, relative_path, size_bytes, mod_date, mod_time)
SELECT filename, first_dir, relative_path, size_bytes, mod_date, mod_time
FROM temp_dartfiles;
EOF

COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dartfiles;")
printf "${GREEN}✓ Import dartfiles: $COUNT fichiers${NC}\n\n"

# Étape 4: Extraire les imports
printf "${YELLOW}4. Extraction des imports...${NC}\n"
dart tools/extract_imports.dart

if [ ! -f "$CSV_IMPORTS" ]; then
  printf "${RED}✗ Erreur: CSV imports non généré${NC}\n"
  exit 1
fi
printf "${GREEN}✓ CSV imports généré${NC}\n\n"

# Étape 5: Importer le CSV imports
printf "${YELLOW}5. Import du CSV imports...${NC}\n"

sqlite3 "$DB_FILE" <<'EOSQL'
CREATE TEMP TABLE temp_imports (
  relative_path VARCHAR(500),
  import_path VARCHAR(500)
);

.mode csv
.import tools/csv/pentapol_imports.csv temp_imports

DELETE FROM temp_imports WHERE relative_path = 'relative_path';

INSERT INTO imports (dart_id, import_path)
SELECT
  df.dart_id,
  ti.import_path
FROM temp_imports ti
JOIN dartfiles df ON ti.relative_path = df.relative_path;
EOSQL

IMPORT_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM imports;")
printf "${GREEN}✓ Import imports: $IMPORT_COUNT imports${NC}\n\n"

# Étape 6: Vérifier les fichiers orphelins
printf "${YELLOW}6. Vérification des fichiers orphelins...${NC}\n"
dart tools/check_orphan_files.dart

# Importer le CSV orphanfiles
printf "${YELLOW}7. Import du CSV orphanfiles...${NC}\n"

sqlite3 "$DB_FILE" <<'EOSQL'
CREATE TEMP TABLE temp_orphanfiles (
  dart_id INTEGER,
  relative_path VARCHAR(500),
  first_dir VARCHAR(50),
  filename VARCHAR(255)
);

.mode csv
.import tools/csv/pentapol_orphan_files.csv temp_orphanfiles

DELETE FROM temp_orphanfiles WHERE dart_id = 'dart_id';

INSERT INTO orphanfiles (dart_id, relative_path, first_dir, filename)
SELECT dart_id, relative_path, first_dir, filename
FROM temp_orphanfiles;
EOSQL

ORPHAN_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM orphanfiles;")
printf "${GREEN}✓ Import orphanfiles: $ORPHAN_COUNT fichier(s)${NC}\n\n"

# Étape 8: Vérifier les fichiers sans dépendances internes
printf "${YELLOW}8. Vérification des fichiers sans dépendances internes...${NC}\n"
dart tools/check_end_files.dart

# Importer le CSV endfiles
printf "${YELLOW}9. Import du CSV endfiles...${NC}\n"

sqlite3 "$DB_FILE" <<'EOSQL'
CREATE TEMP TABLE temp_endfiles (
  dart_id INTEGER,
  relative_path VARCHAR(500),
  first_dir VARCHAR(50),
  filename VARCHAR(255)
);

.mode csv
.import tools/csv/pentapol_end_files.csv temp_endfiles

DELETE FROM temp_endfiles WHERE dart_id = 'dart_id';

INSERT INTO endfiles (dart_id, relative_path, first_dir, filename)
SELECT dart_id, relative_path, first_dir, filename
FROM temp_endfiles;
EOSQL

END_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM endfiles;")
printf "${GREEN}✓ Import endfiles: $END_COUNT fichier(s)${NC}\n\n"

# Étape 10: Extraire les fonctions publiques
printf "${YELLOW}10. Extraction des fonctions publiques...${NC}\n"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB_FILE="$PROJECT_ROOT/tools/db/pentapol.db"

dart run "$PROJECT_ROOT/tools/check_public_functions.dart" \
  --db "$DB_FILE" \
  --root "$PROJECT_ROOT" \
  --include-generated false \
  --include-ctors false \
  --include-call true

# Importer le CSV functions
printf "${YELLOW}11. Import des fonctions publiques...${NC}\n"

sqlite3 "$DB_FILE" <<'EOSQL'
CREATE TEMP TABLE temp_functions (
  relative_path VARCHAR(500),
  return_type VARCHAR(100),
  function_name VARCHAR(255)
);

.mode csv
.import tools/csv/pentapol_functions.csv temp_functions

DELETE FROM temp_functions WHERE relative_path = 'relative_path';

-- Dédupliquer: garder une seule ligne par (relative_path, return_type, function_name)
-- ✅ IMPORTANT: Ignorer les entrées avec return_type vide/nul (faux positifs)
CREATE TEMP TABLE temp_functions_dedup AS
SELECT DISTINCT
  relative_path,
  return_type,
  function_name
FROM temp_functions
WHERE return_type IS NOT NULL
  AND return_type != ''
  AND TRIM(return_type) != '';

DROP TABLE temp_functions;

INSERT INTO functions (dart_id, return_type, function_name)
SELECT
  df.dart_id,
  td.return_type,
  td.function_name
FROM temp_functions_dedup td
JOIN dartfiles df ON td.relative_path = df.relative_path
WHERE td.return_type IS NOT NULL
  AND td.return_type != ''
ON CONFLICT(dart_id, return_type, function_name) DO NOTHING;
EOSQL

FUNC_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM functions;")
printf "${GREEN}✓ Import functions: $FUNC_COUNT fonction(s)${NC}\n\n"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ÉTAPE CRITIQUE 12: DÉTECTION DES DOUBLONS VIA CHECK_DUPLICATE_FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

printf "${YELLOW}12. Détection des fonctions dupliquées (check_duplicate_functions.dart)...${NC}\n"

# IMPORTANT: Nettoyer d'abord la table duplicate_functions
sqlite3 "$DB_FILE" "DELETE FROM duplicate_functions;"

# Exécuter le script Dart qui populera duplicate_functions via SQLite
dart "$PROJECT_ROOT/tools/check_duplicate_functions.dart"

# Vérifier que l'insertion a fonctionné
DUP_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM duplicate_functions;")
if [ "$DUP_COUNT" -gt 0 ]; then
  printf "${GREEN}✓ Doublons détectés: $DUP_COUNT occurrence(s)${NC}\n\n"
else
  printf "${YELLOW}⚠ Aucun doublon détecté (normal après filtrage)${NC}\n\n"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ÉTAPE 13: MISE À JOUR TRANSVERSE_DUPLICATES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

printf "${YELLOW}13. Mise à jour transverse_duplicates...${NC}\n"

sqlite3 "$DB_FILE" <<'EOSQL'
DELETE FROM transverse_duplicates;

INSERT INTO transverse_duplicates(function_name, nb_dirs, occurrences, dirs, last_updated)
SELECT
  function_name,
  COUNT(DISTINCT first_dir) AS nb_dirs,
  MAX(occurrence_count)     AS occurrences,
  GROUP_CONCAT(DISTINCT first_dir) AS dirs,
  datetime('now')           AS last_updated
FROM duplicate_functions
WHERE function_name NOT IN (
  'build','initState','dispose','didChangeDependencies','didUpdateWidget',
  'reassemble','toString','hashCode','createState','setState'
)
GROUP BY function_name
HAVING nb_dirs >= 2;
EOSQL

TRANSVERSE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM transverse_duplicates;")
printf "${GREEN}✓ transverse_duplicates: $TRANSVERSE_COUNT fonction(s) transverse(s)${NC}\n\n"

# Étape 14: Vérifier les imports relatifs
printf "${YELLOW}14. Vérification des imports relatifs...${NC}\n"
dart tools/check_relative_imports.dart

# Importer le CSV importbad
printf "${YELLOW}15. Import du CSV importbad...${NC}\n"

sqlite3 "$DB_FILE" <<'EOSQL'
CREATE TEMP TABLE temp_importbad (
  relative_path VARCHAR(500),
  line_number INTEGER,
  import_path VARCHAR(500)
);

.mode csv
.import tools/csv/pentapol_relative_imports.csv temp_importbad

DELETE FROM temp_importbad WHERE relative_path = 'relative_path';

INSERT INTO importbad (dart_id, relative_path, line_number, import_path)
SELECT
  df.dart_id,
  ti.relative_path,
  ti.line_number,
  ti.import_path
FROM temp_importbad ti
JOIN dartfiles df ON ti.relative_path = df.relative_path;
EOSQL

IMPORTBAD_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM importbad;")
printf "${GREEN}✓ Import importbad: $IMPORTBAD_COUNT import(s) relatif(s)${NC}\n\n"

# Étape 16: Générer la documentation
printf "${YELLOW}16. Génération de la documentation...${NC}\n"
dart tools/generate_dart_documentation.dart
printf "\n"

# Enregistrer le scan dans scans
SCAN_DATE=$(date +%y%m%d)
SCAN_TIME=$(date +%H%M%S)
TOTAL_SIZE=$(sqlite3 "$DB_FILE" "SELECT SUM(size_bytes) FROM dartfiles;")

sqlite3 "$DB_FILE" "INSERT INTO scans (scan_date, scan_time, total_files, total_size_bytes) VALUES ('$SCAN_DATE', '$SCAN_TIME', $COUNT, $TOTAL_SIZE);"

printf "${GREEN}✓ Enregistrement du scan${NC}\n\n"

# Résumé final
printf "${BOLD}=== Succès ===${NC}\n"
printf "DB: ${BOLD}$DB_FILE${NC}\n"
printf "Fichiers: ${BOLD}$COUNT${NC}\n"
printf "Imports: ${BOLD}$IMPORT_COUNT${NC}\n"
printf "Fichiers orphelins: ${BOLD}$ORPHAN_COUNT${NC}\n"
printf "Fichiers sans dépendances: ${BOLD}$END_COUNT${NC}\n"
printf "Fonctions publiques: ${BOLD}$FUNC_COUNT${NC}\n"
printf "Doublons détectés: ${BOLD}$DUP_COUNT${NC}\n"
printf "Doublons transverse: ${BOLD}$TRANSVERSE_COUNT${NC}\n"
printf "Imports relatifs: ${BOLD}$IMPORTBAD_COUNT${NC}\n"
printf "Documentation: ${BOLD}tools/docs/${NC}\n"
printf "Taille: ${BOLD}$(sqlite3 $DB_FILE "SELECT printf('%.2f MB', SUM(size_bytes) / 1024.0 / 1024.0) FROM dartfiles;")${NC}\n"