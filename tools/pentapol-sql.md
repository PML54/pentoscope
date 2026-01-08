# Pentapol SQL - Documentation complète

## Vue d'ensemble

**Pentapol SQL** est un système complet d'analyse d'impact du code basé sur une base de données SQLite. Il capture l'état du code (fichiers, tailles, dates), les relations entre fichiers (imports), l'exposition des fonctions publiques et identifie les fichiers orphelins/feuilles.

**Objectif** : Tracker, analyser et nettoyer le codebase de manière efficace et scalable.

**Avantage clé** : **100% portable** - adaptable à n'importe quel projet Dart/Flutter en modifiant un seul fichier (`config.dart`).

---

## Configuration centralisée

### `tools/config.dart`

Tous les scripts s'exécutent avec **une configuration unique**. Cela rend le système portable sur n'importe quel projet.

**Paramètres principaux :**

```dart
// Identité de l'application
const String APP_NAME = 'pentapol';
const String PACKAGE_NAME = 'pentapol';
const String APP_DESCRIPTION = 'Pentapol - Analyse du code Flutter/Dart';

// Chemins (relatifs à la racine du projet)
const String LIB_PATH = 'lib';
const String TOOLS_PATH = 'tools';
const String DB_PATH = 'tools/db';
const String CSV_PATH = 'tools/csv';
const String DOCS_PATH = 'tools/docs';

// Base de données
const String DB_NAME = 'pentapol.db';
const String DB_FULL_PATH = 'tools/db/pentapol.db';

// Modules du projet
const List<String> MAIN_MODULES = [
  'classical', 'pentoscope', 'isopento', 'duel', 'tutorial'
];

// Fichiers à ignorer
const List<String> IGNORE_FILES = ['main.dart', 'bootstrap.dart'];
```

### Adapter pour un autre projet

Pour utiliser ce système sur un **autre projet**, modifiez simplement `config.dart` :

**Exemple : adapter pour "myapp"**

```dart
// 1. Identité
const String APP_NAME = 'myapp';
const String PACKAGE_NAME = 'myapp';
const String APP_DESCRIPTION = 'MyApp - Analyse du code';

// 2. Modules (selon votre structure)
const List<String> MAIN_MODULES = ['feature_a', 'feature_b', 'feature_c'];

// 3. Fichiers à ignorer
const List<String> IGNORE_FILES = ['main.dart', 'bootstrap.dart', 'env.dart'];
```

**C'est tout !** Les 6 scripts s'exécutent automatiquement avec votre nouvelle configuration.

---

## Architecture

### Structure répertoires

```
pentapol/
├── lib/                           # Code source
├── tools/
│   ├── config.dart               # 🔴 Configuration centralisée
│   ├── db/
│   │   ├── schema.sql
│   │   └── pentapol.db           # DB générée automatiquement
│   ├── csv/
│   │   ├── pentapol_dart_files.csv
│   │   ├── pentapol_imports.csv
│   │   ├── pentapol_orphan_files.csv
│   │   ├── pentapol_end_files.csv
│   │   └── pentapol_functions.csv
│   ├── docs/
│   │   ├── INDEX.md
│   │   ├── common_game.md
│   │   └── ...
│   ├── sync_dartfiles.sh         # 🔴 Script principal
│   ├── scan_dart_files.dart
│   ├── extract_imports.dart
│   ├── check_orphan_files.dart
│   ├── check_end_files.dart
│   ├── check_public_functions.dart
│   └── generate_dart_documentation.dart
```

---

## Installation (première fois)

```bash
# 1. Créer la structure
mkdir -p tools/db tools/csv

# 2. Copier les fichiers
cp config.dart tools/
cp schema.sql tools/db/
cp sync_dartfiles.sh tools/
chmod +x tools/sync_dartfiles.sh

# 3. Copier tous les scripts
cp scan_dart_files.dart tools/
cp extract_imports.dart tools/
cp check_orphan_files.dart tools/
cp check_end_files.dart tools/
cp check_public_functions.dart tools/
cp generate_dart_documentation.dart tools/
```

---

## Exécution

### Analyse complète (12 étapes)

Une commande unique :

```bash
./tools/sync_dartfiles.sh
```

**Résultat :**
```
=== Sync DartFiles & Imports ===

1. Génération du CSV dartfiles...
✓ CSV généré: tools/csv/pentapol_dart_files.csv

2. Recréation des tables...
✓ Tables recréées

3. Import du CSV dartfiles...
✓ Import dartfiles: 100 fichiers

4. Extraction des imports...
✓ CSV imports généré

5. Import du CSV imports...
✓ Import imports: 342 imports

6. Vérification des fichiers orphelins...
✓ 3 fichier(s) orphelin(s) trouvé(s)

7. Import du CSV orphanfiles...
✓ Import orphanfiles: 3 fichier(s)

8. Vérification des fichiers sans dépendances...
✓ 15 fichier(s) sans dépendances trouvé(s)

9. Import du CSV endfiles...
✓ Import endfiles: 15 fichier(s)

10. Extraction des fonctions publiques...
✓ 847 fonctions publiques trouvées

11. Import des fonctions publiques...
✓ Import functions: 847 fonction(s)

12. Génération de la documentation...
✓ Répertoire docs/ vidé
✓ 100 fichiers documentés
✓ INDEX.md généré

=== Succès ===
DB: tools/db/pentapol.db
Fichiers: 100
Imports: 342
Fichiers orphelins: 3
Fichiers sans dépendances: 15
Fonctions publiques: 847
Documentation: tools/docs/
```

### Exécution manuelle (optionnel)

Pour lancer chaque étape individuellement :

```bash
# Scan des fichiers
dart tools/scan_dart_files.dart

# Extraction des imports
dart tools/extract_imports.dart

# Identifier les orphelins
dart tools/check_orphan_files.dart

# Identifier les feuilles
dart tools/check_end_files.dart

# Extraire les fonctions publiques
dart tools/check_public_functions.dart

# Générer la documentation
dart tools/generate_dart_documentation.dart
```

---

## Base de données

### Tables créées

#### `dartfiles`
Tous les fichiers .dart du projet.

```sql
dart_id (PK)        -- ID unique
filename            -- Ex: game.dart
first_dir           -- Ex: classical
relative_path       -- Ex: classical/models/game.dart
size_bytes          -- Taille
mod_date            -- YYMMDD
mod_time            -- HHMMSS
```

#### `imports`
Relations entre fichiers.

```sql
import_id (PK)      -- ID unique
dart_id (FK)        -- Fichier source
import_path         -- Ex: package:pentapol/common/game.dart
```

#### `orphanfiles`
Fichiers **non importés** par personne.

```sql
dart_id (PK, FK)    -- Référence à dartfiles
relative_path
first_dir
filename
```

#### `endfiles`
Fichiers **sans dépendances internes** (feuilles).

```sql
dart_id (PK, FK)
relative_path
first_dir
filename
```

#### `functions`
Fonctions publiques de chaque fichier.

```sql
function_id (PK)
dart_id (FK)        -- Fichier
function_name       -- Nom de la fonction
```

---

## Requêtes SQL utiles

Ouvre `tools/db/pentapol.db` dans SQL Studio :

### Fichiers orphelins (non importés)
```sql
SELECT relative_path, first_dir
FROM orphanfiles
ORDER BY first_dir, relative_path;
```

### Fichiers sans dépendances (feuilles)
```sql
SELECT relative_path, first_dir
FROM endfiles
ORDER BY first_dir, relative_path;
```

### Fonctions d'un fichier
```sql
SELECT f.function_name
FROM functions f
JOIN dartfiles df ON f.dart_id = df.dart_id
WHERE df.relative_path = 'classical/game.dart';
```

### Fichiers avec le plus de fonctions
```sql
SELECT df.relative_path, COUNT(*) as count
FROM functions f
JOIN dartfiles df ON f.dart_id = df.dart_id
GROUP BY f.dart_id
ORDER BY count DESC LIMIT 10;
```

### Dépendances entre modules
```sql
SELECT 
  df.first_dir as from_module,
  SUBSTR(i.import_path, 21, INSTR(SUBSTR(i.import_path, 21), '/') - 1) as to_module,
  COUNT(*) as count
FROM imports i
JOIN dartfiles df ON i.dart_id = df.dart_id
WHERE i.import_path LIKE 'package:%/%'
GROUP BY df.first_dir, to_module
ORDER BY count DESC;
```

### Qui importe un fichier spécifique
```sql
SELECT DISTINCT df.relative_path
FROM imports i
JOIN dartfiles df ON i.dart_id = df.dart_id
WHERE i.import_path LIKE '%/common/game.dart%';
```

---

## Fichiers générés

Après chaque `./tools/sync_dartfiles.sh` :

### CSVs
- `pentapol_dart_files.csv` - Tous les fichiers
- `pentapol_imports.csv` - Tous les imports
- `pentapol_orphan_files.csv` - Fichiers orphelins
- `pentapol_end_files.csv` - Fichiers sans dépendances
- `pentapol_functions.csv` - Fonctions publiques

### Base de données
- `pentapol.db` - SQLite avec 5 tables

### Documentation
- `tools/docs/INDEX.md` - Vue d'ensemble
- `tools/docs/*.md` - Un fichier par dart

---

## Cas d'usage

✓ **Nettoyage** : Identifier et supprimer les fichiers orphelins  
✓ **Impact** : Mesurer l'impact d'une modification  
✓ **Documentation** : Exposer l'API publique de chaque module  
✓ **Architecture** : Vérifier l'isolation des modules  
✓ **Dépendances** : Identifier les cycles et couplages  
✓ **Qualité** : Trouver les fichiers critiques

---

## Dépannage

### ❌ Erreur "file not found"
Assurez-vous de lancer depuis la racine du projet.

### ❌ Base de données non trouvée
Exécutez `./tools/sync_dartfiles.sh` d'abord pour créer la DB.

### ❌ Imports manquants
Vérifiez que les imports utilisent `package:pentapol/...` (ou votre package).

### ❌ Adapter le système ne fonctionne pas
Modifiez uniquement `config.dart` et relancez les scripts.

---

## Prochaines étapes

1. **Historique** : Versionner les DBs pour comparer les scans
2. **Violations** : Remplir la table `violations`
3. **Dashboard** : Créer des vues SQL visuelles
4. **Classes** : Extraire aussi les classes et enums publics

---

## Portabilité

Pour utiliser ce système sur **n'importe quel projet Dart/Flutter** :

1. Copier le répertoire `tools/`
2. Modifier `tools/config.dart` (APP_NAME, PACKAGE_NAME, MODULES)
3. Lancer `./tools/sync_dartfiles.sh`

**Aucun autre changement nécessaire !**

---

**Bon travail !** 🎉