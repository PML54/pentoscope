# Pentapol SQL - Documentation Complète (v2.0)

## Vue d'ensemble

**Pentapol SQL** est un système complet d'analyse d'impact du code basé sur une base de données SQLite. Il capture l'état du code (fichiers, tailles, dates), les relations entre fichiers (imports), l'exposition des fonctions publiques avec leurs **types de retour**, et identifie les fichiers orphelins/feuilles et les fonctions dupliquées.

**Objectif** : Tracker, analyser et nettoyer le codebase Flutter/Dart de manière efficace et scalable.

**Avantage clé** : **100% portable** - adaptable à n'importe quel projet Dart/Flutter.

---

## Configuration centralisée

### `tools/config.dart`

Tous les scripts utilisent un **fichier de configuration unique**. Cela rend le système 100% portable sur n'importe quel projet.

**Paramètres principaux :**

```dart
// Identité de l'application
const String APP_NAME = 'pentapol';
const String PACKAGE_NAME = 'pentapol';

// Chemins relatifs
const String LIB_PATH = 'lib';
const String DB_PATH = 'tools/db';
const String CSV_PATH = 'tools/csv';
const String DOCS_PATH = 'tools/docs';

// Base de données
const String DB_FULL_PATH = 'tools/db/pentapol.db';

// Modules du projet
const List<String> MAIN_MODULES = [
  'classical', 'pentoscope', 'isopento', 'duel', 'tutorial'
];
```

### Adapter pour une autre application

Pour utiliser ce système sur un **autre projet**, modifiez simplement `config.dart` :

```dart
const String APP_NAME = 'myapp';
const String PACKAGE_NAME = 'myapp';
const List<String> MAIN_MODULES = ['feature_a', 'feature_b'];
```

**C'est tout !** Les scripts s'exécutent automatiquement avec votre nouvelle configuration.

---

## Architecture des tables

### 1. `dartfiles` - Fichiers .dart
```sql
dart_id (PK)        -- ID unique
filename            -- Ex: game.dart
first_dir           -- Ex: classical
relative_path       -- Ex: classical/models/game.dart
size_bytes          -- Taille du fichier
mod_date            -- YYMMDD
mod_time            -- HHMMSS
```

### 2. `imports` - Relations entre fichiers
```sql
import_id (PK)
dart_id (FK)        -- Fichier source
import_path         -- Ex: package:pentapol/common/game.dart
```

### 3. `orphanfiles` - Fichiers non importés
```sql
dart_id (PK, FK)
relative_path
first_dir
filename
```

### 4. `endfiles` - Fichiers sans dépendances (feuilles)
```sql
dart_id (PK, FK)
relative_path
first_dir
filename
```

### 5. `functions` - Fonctions publiques (NOUVEAU: avec return_type)
```sql
function_id (PK)
dart_id (FK)
return_type         -- ✅ NOUVEAU: 'void', 'int', 'String', 'Future<bool>', etc.
function_name
UNIQUE(dart_id, return_type, function_name)
```

### 6. `duplicate_functions` - Doublons détectés
```sql
duplicate_id (PK)
function_name
dart_id (FK)
relative_path
first_dir
occurrence_count
```

### 7. `importbad` - Imports relatifs (non absolus)
```sql
importbad_id (PK)
dart_id (FK)
relative_path
line_number
import_path
```

### 8. `violations` - Violations d'architecture
```sql
violation_id (PK)
relative_path
violation_type      -- 'isolation', 'relative_import', etc.
module_from
module_to
import_path
line_number
severity            -- 'error', 'warning'
```

---

## 🚀 Lancer l'analyse complète

### Installation (première fois)

```bash
# 1. Créer la structure
mkdir -p tools/db tools/csv tools/docs

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
cp check_public_functions.dart tools/      # ✅ NOUVEAU: avec return_type
cp check_duplicate_functions.dart tools/   # ✅ NOUVEAU: détecte doublons
cp generate_dart_documentation.dart tools/
```

### Exécution

Une commande unique pour tout :

```bash
./tools/sync_dartfiles.sh
```

C'est tout ! Ça lance les **15 étapes automatiquement**.

### Résultat

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
✓ 842 fonctions publiques trouvées (avec return_type)

11. Import des fonctions publiques...
✓ Import functions: 841 fonction(s)

12. Vérification des imports relatifs...
✓ 0 import(s) relatif(s) trouvé(s)

13. Import des imports relatifs...
✓ Import importbad: 0 import(s)

14. Détection des fonctions dupliquées...
✓ Doublons détectés et importés

15. Génération de la documentation...
✓ Répertoire docs/ vidé
✓ 100 fichiers documentés
✓ INDEX.md généré

=== Succès ===
DB: tools/db/pentapol.db
Fichiers: 100
Imports: 342
Fichiers orphelins: 3
Fichiers sans dépendances: 15
Fonctions publiques: 841
Fonctions dupliquées: 2
Imports relatifs: 0
Documentation: tools/docs/
Taille: 0.75 MB
```

---

## Requêtes SQL utiles

### Fonctions avec leur type de retour

```sql
SELECT 
  df.relative_path,
  f.return_type,
  f.function_name
FROM functions f
JOIN dartfiles df ON f.dart_id = df.dart_id
WHERE f.return_type IS NOT NULL
ORDER BY df.relative_path, f.function_name;
```

### Doublons (même signature: return_type + name)

```sql
SELECT 
  f.return_type,
  f.function_name,
  COUNT(DISTINCT f.dart_id) as nb_fichiers
FROM functions f
WHERE f.return_type IS NOT NULL
GROUP BY f.return_type, f.function_name
HAVING COUNT(DISTINCT f.dart_id) > 1
ORDER BY nb_fichiers DESC;
```

### Statistiques par type de retour

```sql
SELECT 
  f.return_type,
  COUNT(*) as count
FROM functions f
WHERE f.return_type IS NOT NULL
GROUP BY f.return_type
ORDER BY count DESC;
```

### Chercher une fonction exacte

```sql
SELECT 
  df.relative_path,
  f.return_type || ' ' || f.function_name as signature
FROM functions f
JOIN dartfiles df ON f.dart_id = df.dart_id
WHERE f.function_name = 'applyIsometryRotationTW'
  AND f.return_type = 'void';
```

### Fichiers orphelins

```sql
SELECT relative_path, first_dir
FROM orphanfiles
ORDER BY first_dir, relative_path;
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

---

## Fichiers générés

Après chaque exécution :

```
tools/
├── db/
│   └── pentapol.db                      ← Base de données SQLite
├── csv/
│   ├── pentapol_dart_files.csv          ← Fichiers .dart
│   ├── pentapol_imports.csv             ← Imports
│   ├── pentapol_orphan_files.csv        ← Orphelins
│   ├── pentapol_end_files.csv           ← Sans dépendances
│   └── pentapol_functions.csv           ← Fonctions (avec return_type)
└── docs/
    ├── INDEX.md                         ← Vue d'ensemble
    ├── classical_game.dart.md
    └── ...                              ← Un .md par fichier .dart
```

---

## Scripts disponibles

| Script | Résultat |
|--------|----------|
| **scan_dart_files.dart** | CSV des fichiers .dart |
| **extract_imports.dart** | CSV des imports |
| **check_orphan_files.dart** | CSV des fichiers non importés |
| **check_end_files.dart** | CSV des fichiers sans dépendances |
| **check_public_functions.dart** | CSV des fonctions avec **return_type** ✅ |
| **check_duplicate_functions.dart** | Détecte et insère les doublons ✅ |
| **generate_dart_documentation.dart** | Markdown dans `tools/docs/` |
| **sync_dartfiles.sh** | 🔴 Lance TOUT automatiquement |

---

## Cas d'usage

✓ **Nettoyage** : Identifier et supprimer les fichiers orphelins  
✓ **Impact** : Mesurer l'impact d'une modification  
✓ **Documentation** : Exposer l'API publique avec types  
✓ **Doublons** : Détecter les fonctions dupliquées  
✓ **Architecture** : Vérifier l'isolation des modules  
✓ **Dépendances** : Identifier les cycles et couplages  
✓ **Qualité** : Trouver les fichiers critiques

---

## Nouveautés v2.0

✅ **Colonne `return_type`** dans `functions`
- Récupère: `void`, `int`, `String`, `Future<bool>`, etc.
- Signature unique: (dart_id, return_type, function_name)

✅ **Table `duplicate_functions`**
- Détecte automatiquement les doublons
- Filtre sur return_type non nul

✅ **Script `check_duplicate_functions.dart`**
- Intégré à étape 14 du workflow
- Déduplique et insère dans la DB

✅ **Déduplication intelligente**
- Ignore les return_type vides
- Élimine les faux positifs

✅ **Workflow: 15 étapes** (au lieu de 12)
- Étape 14: Détection des doublons (NOUVEAU)

---

## Portabilité

Pour utiliser ce système sur **n'importe quel projet Dart** :

1. Copier le répertoire `tools/`
2. Modifier `tools/config.dart` :
    - `APP_NAME = 'myapp'`
    - `PACKAGE_NAME = 'myapp'`
    - `MAIN_MODULES = ['feature_a', 'feature_b']`
3. Lancer `./tools/sync_dartfiles.sh`

**Aucun autre changement nécessaire !**

---

## Installation de mise à jour (v1 → v2)

Si vous aviez la v1:

```bash
# 1. Mettre à jour schema.sql
cp schema.sql tools/db/

# 2. Ajouter check_duplicate_functions.dart
cp check_duplicate_functions.dart tools/

# 3. Mettre à jour sync_dartfiles.sh
cp sync_dartfiles.sh tools/

# 4. Nettoyer
rm tools/db/pentapol.db
rm tools/csv/*.csv

# 5. Relancer
./tools/sync_dartfiles.sh
```

---

## Dépannage

### ❌ Erreur UNIQUE constraint
**Solution** : Les fonctions sont dédupliquées automatiquement. Vérifier que return_type n'est pas vide.

### ❌ Base de données non trouvée
**Solution** : Exécutez `./tools/sync_dartfiles.sh` d'abord pour créer la DB.

### ❌ Pas de functions importées
**Solution** : Vérifier que les imports utilisent `package:pentapol/...` (ou votre package).

---

## Prochaines étapes

1. **Historique** : Versionner les DBs pour comparer les scans
2. **Dashboard** : Créer des vues SQL visuelles
3. **Classes** : Extraire aussi les classes et enums publics
4. **Paramètres** : Extraire les signatures complètes (avec paramètres)
5. **Refactoring** : Unifier les providers avec un GameLogicService

---

## Bénéfices du système

✅ **Analyse complète** : Fichiers, imports, doublons, orphelins  
✅ **Signatures précises** : return_type élimine les ambiguïtés  
✅ **Portabilité** : Un seul `config.dart` à adapter  
✅ **Automatisation** : 15 étapes en une commande  
✅ **Documentation** : Markdown auto-généré  
✅ **Qualité** : Détection des violations d'architecture  
✅ **Maintenabilité** : Code analysable et tracké

---

**Dernière mise à jour:** 2025-12-12  
**Version:** 2.0  
**Status:** ✅ Production-ready