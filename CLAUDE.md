# CLAUDE.md — Pentapol

## Identité du projet

- **Nom** : Pentapol
- **Package Flutter** : `pentapol`
- **Langage** : Dart / Flutter
- **Plateforme cible** : iOS (iPhone, App Store)
- **Backend** : Cloudflare Workers + Durable Objects (mode multijoueur)
- **State management** : Riverpod
- **Imports** : absolus uniquement (pas de chemins relatifs)

## Architecture

```
lib/
  common/          # modèles et services partagés entre modules
  classical/       # logique du jeu classique
  pentoscope/      # module pentoscope (actif)
  duel/            # mode multijoueur duel (actif)
  tutorial/        # système de tutoriel YAML (actif)
```

## Modules actifs

| Module      | État         | Notes |
|-------------|--------------|-------|
| classical   | actif        | jeu classique de pentominos |
| pentoscope  | actif        | drag & drop, snapping magnétique, scoring isométrique |
| duel        | actif        | multijoueur WebSocket, Cloudflare Durable Objects |
| tutorial    | actif        | scripting YAML, 47 commandes, ghost pieces |

## Convention de header OBLIGATOIRE

Tout fichier modifié doit avoir ce header en première ligne :

```dart
// lib/[MODULE]/[CHEMIN]/file.dart
// Modified: YYMMDDHHMMM
// [TITRE]
// CHANGEMENTS: (1) [Quoi] ligne X, (2) [Quoi] ligne Y, (3) [Quoi] ligne Z
```

Exemple :
```dart
// lib/pentoscope/screens/pentoscope_game_screen.dart
// Modified: 2603170930
// Fix drag anchor for placed pieces
// CHANGEMENTS: (1) Correction selectedMasterAbs ligne 142, (2) Refactor onDragUpdate ligne 198
```

## Règles impératives

1. **Ne jamais commiter sans demander explicitement** à l'utilisateur
2. **Toujours écrire les headers** sur chaque fichier modifié
3. **Expliquer avant d'agir** : décrire ce qui va être modifié avant de toucher au code
4. **Imports absolus uniquement** — jamais de `../` dans les imports Dart
5. **0 erreurs de compilation** avant tout commit

## Stack technique

- Flutter SDK (dernière version stable)
- Riverpod (state management)
- Cloudflare Workers + Durable Objects (backend duel)
- WebSocket (communication temps réel multijoueur)
- BigInt (encodage des solutions de puzzles)
- SQLite (analyse de dépendances, scripts)
- YAML (scripting tutorial)

## Développeur

- Paul Marie Larivière — ingénieur systèmes UNIX, ex-IT manager
- Expérience : Fortran, C/C++, Unix, Dart/Flutter
- Autres apps publiées : PuzHub, SudokuRix, Luchy
- Style : approche systémique, architecture propre, comprendre avant d'appliquer
