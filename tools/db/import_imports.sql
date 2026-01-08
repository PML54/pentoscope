-- tools/db/import_imports.sql
-- Importe les imports en joignant avec dartfiles pour récupérer les dart_id
-- À exécuter APRÈS import_dartfiles.sql

-- Importer le CSV temporaire
CREATE TEMP TABLE temp_imports (
  relative_path VARCHAR(500),
  import_path VARCHAR(500)
);

.mode csv
.import tools/csv/pentapol_imports.csv temp_imports

-- Insérer dans la vraie table imports en joignant avec dartfiles
INSERT INTO imports (dart_id, import_path)
SELECT
  df.dart_id,
  ti.import_path
FROM temp_imports ti
JOIN dartfiles df ON ti.relative_path = df.relative_path;

-- Vérification
SELECT COUNT(*) as "Total imports" FROM imports;
SELECT 'Imports par fichier:' as '';
SELECT df.relative_path, COUNT(*) as count
FROM imports i
JOIN dartfiles df ON i.dart_id = df.dart_id
GROUP BY df.relative_path
ORDER BY count DESC
LIMIT 10;