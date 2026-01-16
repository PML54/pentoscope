3q
# 📘 DOCIA - Documentation Intelligente et Actuelle

**Pentapol - Application Flutter de puzzles pentominos**

**📅 Créé le : 1er décembre 2025 à 00:45**  
**🔄 Dernière mise à jour : 1er décembre 2025 à 01:15**

---

## 🎯 Vue d'ensemble en 30 secondes

**Pentapol** est une app Flutter de puzzles pentominos avec :
- **4 modes de jeu** : Jeu classique, Isométries, Tutoriel, Duel multijoueur
- **Mini-puzzles** : Plateaux réduits (2×5 à 5×5) pour progression graduelle *(à venir)*
- **2339 solutions** canoniques pré-calculées (9356 avec transformations)
- **Architecture** : Riverpod + Supabase (Duel) + SQLite

---

## 📑 Navigation rapide

| Section | Contenu | Temps lecture |
|---------|---------|---------------|
| [🏗️ Architecture](#️-architecture-globale) | Vue d'ensemble système | 3 min |
| [🎮 Modes de jeu](#-modes-de-jeu) | 4 modes disponibles | 2 min |
| [📊 Flux de données](#-flux-de-données) | Qui dépend de qui | 5 min |
| [🗂️ Structure fichiers](#️-structure-des-fichiers) | Organisation code | 2 min |
| [⚡ Actions clés](#-actions-clés-par-mode) | Opérations principales | 3 min |
| [🔧 Développement](#-guide-développement) | Ajouter features | 5 min |

**Temps total : ~20 minutes**

---

## 🏗️ Architecture globale

### Schéma de responsabilités

```
┌─────────────────────────────────────────────────────────────────┐
│                         UTILISATEUR                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         UI SCREENS                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ HomeScreen   │  │ GameScreen   │  │ DuelScreen   │         │
│  │              │  │              │  │              │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                   │
└─────────┼─────────────────┼─────────────────┼───────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PROVIDERS (Riverpod)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Settings     │  │ GameProvider │  │ DuelProvider │         │
│  │ Provider     │  │              │  │              │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                   │
└─────────┼─────────────────┼─────────────────┼───────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SERVICES & DATA                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ SQLite       │  │ Solver       │  │ Supabase     │         │
│  │ (Settings)   │  │ (Solutions)  │  │ (Duel)       │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

### Dépendances entre modules

```
┌─────────────────────────────────────────────────────────────────┐
│                      DÉPENDANCES CLÉS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PentominoGameScreen                                            │
│  ├─ dépend de → PentominoGameProvider                          │
│  ├─ dépend de → TutorialProvider (si mode tutoriel)            │
│  └─ utilise → GameBoard, PieceSlider, ActionSlider             │
│                                                                  │
│  PentominoGameProvider                                          │
│  ├─ gère → PentominoGameState                                  │
│  ├─ utilise → PentominoSolver (vérification)                   │
│  ├─ utilise → IsometryTransforms (rotations/miroirs)           │
│  └─ utilise → SolutionMatcher (comptage solutions)             │
│                                                                  │
│  DuelGameScreen                                                 │
│  ├─ dépend de → DuelProvider                                   │
│  ├─ utilise → DuelValidator (validation placements)            │
│  └─ utilise → Supabase Realtime (synchronisation)              │
│                                                                  │
│  TutorialProvider                                               │
│  ├─ gère → TutorialState                                       │
│  ├─ utilise → ScratchInterpreter (exécution commandes)         │
│  ├─ utilise → YamlParser (lecture scripts)                     │
│  └─ modifie → PentominoGameProvider (via commandes)            │
│                                                                  │
│  SettingsProvider                                               │
│  ├─ gère → AppSettings                                         │
│  ├─ utilise → SettingsDatabase (SQLite)                        │
│  └─ persiste → UI, Game, Duel settings                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎮 Modes de jeu

### Vue d'ensemble

| Mode | Description | Écran | Provider | Durée typique |
|------|-------------|-------|----------|---------------|
| **🎯 Jeu classique** | Placer 12 pièces sur 6×10 | `PentominoGameScreen` | `PentominoGameProvider` | 15-30 min |
| **🔄 Isométries** | Transformer le plateau | `PentominoGameScreen` | `PentominoGameProvider` | 5-10 min |
| **🎓 Tutoriel** | Scripts guidés YAML | `PentominoGameScreen` + overlay | `TutorialProvider` | 2-5 min |
| **⚔️ Duel** | Multijoueur temps réel | `DuelGameScreen` | `DuelProvider` | 3 min |
| **🎲 Mini-puzzles** | Plateaux réduits (2×5 à 5×5) | `PentominoGameScreen` | `PentominoGameProvider` | 2-8 min |

### Détection automatique des modes

```
┌─────────────────────────────────────────────────────────────────┐
│              DÉTECTION AUTOMATIQUE DU MODE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  IF tutorialMode == true                                        │
│    → Mode TUTORIEL (overlay + contrôles)                        │
│                                                                  │
│  ELSE IF selectedPlacedPiece != null                            │
│    → Mode ISOMÉTRIES (transformations plateau)                  │
│                                                                  │
│  ELSE IF selectedPiece != null                                  │
│    → Mode JEU (placement pièces)                                │
│                                                                  │
│  ELSE                                                            │
│    → Mode NEUTRE (aucune action)                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Flux de données

### 1. Mode Jeu classique

```
USER ACTION                PROVIDER                    STATE UPDATE
───────────                ────────                    ────────────

Tap sur pièce         →    selectPiece(index)     →   selectedPiece = index
dans slider                                            selectedOrientation = 0

Double-tap            →    cycleOrientation()     →   selectedOrientation++
sur pièce

Drag vers             →    updatePreview(x,y)     →   previewX = x
plateau                                                previewY = y
                                                       isPreviewValid = canPlace()

Drop sur              →    tryPlacePiece(x,y)     →   IF valid:
plateau                                                  placedPieces.add()
                                                         selectedPiece = null
                                                       ELSE:
                                                         haptic error

Long-press            →    removePlacedPiece()    →   placedPieces.remove()
pièce placée                                           selectedPiece = null

Tap Undo              →    undo()                 →   state = history.last
                                                       history.removeLast()

Tap Reset             →    reset()                →   state = initial()
                                                       history.clear()
```

### 2. Mode Isométries

```
USER ACTION                PROVIDER                    STATE UPDATE
───────────                ────────                    ────────────

Tap pièce             →    selectPlacedPiece()    →   selectedPlacedPiece = index
placée

Tap rotation          →    rotateClockwise()      →   plateau = transform(plateau)
horaire                                                placedPieces = recalculate()

Tap rotation          →    rotateCounter          →   plateau = transform(plateau)
anti-horaire               Clockwise()                 placedPieces = recalculate()

Tap miroir            →    mirrorHorizontal()     →   plateau = transform(plateau)
horizontal                                             placedPieces = recalculate()

Tap miroir            →    mirrorVertical()       →   plateau = transform(plateau)
vertical                                               placedPieces = recalculate()
```

### 3. Mode Tutoriel

```
USER ACTION                PROVIDER                    STATE UPDATE
───────────                ────────                    ────────────

Charger script        →    loadScript(yaml)       →   tutorialState = loaded
YAML                                                   commands = parsed

Tap Play              →    start()                →   isRunning = true
                                                       executeNextCommand()

Commande              →    ScratchInterpreter     →   gameProvider.selectPiece()
SELECT_PIECE               .execute()                  tutorialHighlights updated

Commande              →    ScratchInterpreter     →   gameProvider.tryPlacePiece()
PLACE_PIECE                .execute()                  tutorialMessage updated

Commande              →    ScratchInterpreter     →   sleep(duration)
WAIT                       .execute()                  then continue

Tap Pause             →    pause()                →   isRunning = false
                                                       currentStep saved

Tap Stop              →    stop()                 →   isRunning = false
                                                       restore game state
                                                       exit tutorial mode
```

### 4. Mode Duel

```
USER ACTION                PROVIDER                    SUPABASE
───────────                ────────                    ────────

Créer partie          →    createRoom()           →   INSERT room
                                                       LISTEN changes

Rejoindre             →    joinRoom(code)         →   UPDATE room
partie                                                 LISTEN changes

Placer pièce          →    placePiece(id,x,y)     →   IF valid:
                           + validate()                  INSERT placement
                                                         BROADCAST update
                                                       ELSE:
                                                         show error

Recevoir              →    onRealtimeUpdate()     →   opponentPieces.add()
placement                                              UI refresh
adversaire

Compléter             →    checkVictory()         →   UPDATE room
toutes pièces                                          status = 'finished'
                                                       winner = player_id
```

---

## 🗂️ Structure des fichiers

### Organisation par responsabilité

```
lib/
│
├── 📱 SCREENS (UI)
│   ├── home_screen.dart                    Menu principal
│   ├── pentomino_game_screen.dart          Jeu + Isométries + Mini-puzzles
│   ├── settings_screen.dart                Paramètres
│   ├── solutions_browser_screen.dart       Navigateur solutions
│   │
│   ├── pentomino_game/                     Widgets modulaires
│   │   └── widgets/
│   │       ├── game_board.dart             Plateau de jeu
│   │       ├── piece_slider.dart           Slider pièces
│   │       ├── action_slider.dart          Slider isométries
│   │       └── shared/                     Widgets partagés
│   │
│   └── duel/                               Mode Duel
│       ├── duel_lobby_screen.dart
│       ├── duel_create_screen.dart
│       ├── duel_join_screen.dart
│       └── duel_game_screen.dart
│
├── 🎮 PROVIDERS (État)
│   ├── pentomino_game_provider.dart        État jeu principal
│   ├── settings_provider.dart              Paramètres app
│   ├── tutorial/tutorial_provider.dart     État tutoriel
│   └── duel/duel_provider.dart             État duel
│
├── 📦 MODELS (Données)
│   ├── pentominos.dart                     12 pièces + rotations
│   ├── plateau.dart                        Grille de jeu
│   ├── pentomino_game_state.dart           État complet jeu
│   ├── app_settings.dart                   Paramètres (UI/Game/Duel)
│   └── game_piece.dart                     Pièce interactive
│
├── ⚙️ SERVICES (Logique métier)
│   ├── pentomino_solver.dart               Résolution backtracking
│   ├── solution_matcher.dart               Comparaison solutions
│   ├── isometry_transforms.dart            Rotations/miroirs
│   ├── shape_recognizer.dart               Reconnaissance formes
│   └── mini_puzzle_generator.dart          Génération mini-puzzles
│
├── 🗄️ DATA (Persistance)
│   ├── database/settings_database.dart     SQLite (Drift)
│   └── data/solution_database.dart         Base solutions
│
├── 🎓 TUTORIAL (Système tutoriel)
│   ├── models/                             TutorialScript, Command
│   ├── parser/yaml_parser.dart             Parse YAML
│   ├── interpreter/                        Exécution commandes
│   ├── commands/                           29 commandes
│   └── widgets/                            Overlay, contrôles
│
└── 🛠️ UTILS (Utilitaires)
    ├── piece_utils.dart                    Géométrie pièces
    ├── plateau_compressor.dart             Compression BigInt
    └── time_format.dart                    Formatage temps
```

### Fichiers critiques (à connaître absolument)

| Fichier | Lignes | Rôle | Modifié fréquemment |
|---------|--------|------|---------------------|
| `pentomino_game_provider.dart` | 1578 | **Cerveau du jeu** - Toute la logique | ⚠️ Oui |
| `pentomino_game_screen.dart` | 322 | **Orchestrateur UI** - Coordonne widgets | 🟡 Parfois |
| `game_board.dart` | 388 | **Plateau interactif** - Drag & drop | 🟢 Rarement |
| `pentomino_solver.dart` | 735 | **Résolution** - Backtracking | 🟢 Rarement |
| `app_settings.dart` | 348 | **Configuration** - Tous paramètres | 🟡 Parfois |
| `duel_game_screen.dart` | 986 | **Duel** - Jeu multijoueur | 🟡 Parfois |

---

## ⚡ Actions clés par mode

### Mode Jeu

| Action | Méthode | Provider | Effet |
|--------|---------|----------|-------|
| Sélectionner pièce | `selectPiece(index)` | Game | Change `selectedPiece` |
| Changer orientation | `cycleOrientation()` | Game | Incrémente `selectedOrientation` |
| Placer pièce | `tryPlacePiece(x, y)` | Game | Ajoute à `placedPieces` si valide |
| Retirer pièce | `removePlacedPiece(index)` | Game | Retire de `placedPieces` |
| Annuler | `undo()` | Game | Restaure état précédent |
| Réinitialiser | `reset()` | Game | État initial |

### Mode Isométries

| Action | Méthode | Provider | Effet |
|--------|---------|----------|-------|
| Rotation ↻ | `rotateClockwise()` | Game | Transforme `plateau` + recalcule pièces |
| Rotation ↺ | `rotateCounterClockwise()` | Game | Transforme `plateau` + recalcule pièces |
| Miroir ↔ | `mirrorHorizontal()` | Game | Transforme `plateau` + recalcule pièces |
| Miroir ↕ | `mirrorVertical()` | Game | Transforme `plateau` + recalcule pièces |

### Mode Tutoriel

| Action | Méthode | Provider | Effet |
|--------|---------|----------|-------|
| Charger script | `loadScript(script)` | Tutorial | Parse YAML → commandes |
| Démarrer | `start()` | Tutorial | Exécute commandes séquentiellement |
| Pause | `pause()` | Tutorial | Arrête exécution temporairement |
| Stop | `stop()` | Tutorial | Arrête + restaure état jeu |
| Étape suivante | `nextStep()` | Tutorial | Exécute commande suivante |

### Mode Duel

| Action | Méthode | Provider | Effet |
|--------|---------|----------|-------|
| Créer room | `createRoom(name)` | Duel | INSERT Supabase + génère code |
| Rejoindre | `joinRoom(code, name)` | Duel | UPDATE Supabase + écoute |
| Placer pièce | `placePiece(id, x, y, orient)` | Duel | Valide + BROADCAST |
| Recevoir update | `onRealtimeUpdate(data)` | Duel | Met à jour `opponentPieces` |

---

## 🔧 Guide développement

### Ajouter une nouvelle feature

#### 1. Nouvelle action dans le jeu

```dart
// 1. Ajouter méthode dans PentominoGameProvider
class PentominoGameNotifier extends Notifier<PentominoGameState> {
  void maNouvelleFonction() {
    // Logique métier
    state = state.copyWith(/* changements */);
  }
}

// 2. Appeler depuis UI
Consumer(
  builder: (context, ref, child) {
    return ElevatedButton(
      onPressed: () {
        ref.read(pentominoGameProvider.notifier).maNouvelleFonction();
      },
      child: Text('Action'),
    );
  },
)
```

#### 2. Nouveau paramètre dans settings

```dart
// 1. Ajouter dans AppSettings
class GameSettings {
  final bool monNouveauParam;
  
  GameSettings copyWith({bool? monNouveauParam}) {
    return GameSettings(
      monNouveauParam: monNouveauParam ?? this.monNouveauParam,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'monNouveauParam': monNouveauParam,
  };
}

// 2. Ajouter méthode dans SettingsProvider
class SettingsNotifier extends Notifier<AppSettings> {
  Future<void> setMonNouveauParam(bool value) async {
    state = state.copyWith(
      game: state.game.copyWith(monNouveauParam: value),
    );
    await _saveToDatabase();
  }
}

// 3. Utiliser dans UI
final monParam = ref.watch(settingsProvider).game.monNouveauParam;
```

#### 3. Nouvelle commande tutoriel

```dart
// 1. Créer classe commande
class MaCommandeCommand extends ScratchCommand {
  final String param;
  
  MaCommandeCommand({required this.param});
  
  @override
  Future<void> execute(TutorialContext context) async {
    // Logique de la commande
    context.gameNotifier.maNouvelleFonction();
  }
}

// 2. Ajouter dans YamlParser
ScratchCommand _parseCommand(Map<String, dynamic> yaml) {
  switch (yaml['command']) {
    case 'MA_COMMANDE':
      return MaCommandeCommand(param: yaml['params']['param']);
    // ...
  }
}

// 3. Utiliser dans YAML
steps:
  - command: MA_COMMANDE
    params:
      param: "valeur"
```

### Débugger un problème

#### État du jeu incohérent

```dart
// Ajouter logs dans le provider
void tryPlacePiece(int gridX, int gridY) {
  print('[DEBUG] tryPlacePiece: x=$gridX, y=$gridY');
  print('[DEBUG] selectedPiece: $selectedPiece');
  print('[DEBUG] canPlace: ${canPlacePiece(selectedPiece!, gridX, gridY)}');
  
  // ... reste du code
}
```

#### UI ne se met pas à jour

```dart
// Vérifier que copyWith() est appelé
state = state.copyWith(
  selectedPiece: index,  // ✅ Crée nouveau state
);

// PAS COMME ÇA :
state.selectedPiece = index;  // ❌ Mutation directe
```

#### Fuite mémoire

```dart
// Toujours disposer les timers/streams
@override
void dispose() {
  _timer?.cancel();
  _subscription?.cancel();
  super.dispose();
}
```

---

## 📚 Concepts clés

### 1. Plateau (Grille)

```dart
class Plateau {
  List<List<int>> grid;  // -1=caché, 0=libre, 1-12=pièce
  
  // Dimensions variables (6×10, 3×5, etc.)
  final int width;
  final int height;
}
```

**Encodage BigInt** : Pour comparaison rapide avec solutions
- 60 cases × 6 bits = 360 bits
- Case 0 → bits 354-359
- Case 59 → bits 0-5

### 2. Pièces (Pentominos)

```dart
class Pento {
  final int id;                    // 1-12
  final int numOrientations;          // 1-8 (rotations/symétries)
  final List<List<int>> positions; // Toutes les orientations
  final int bit6;                  // Code unique 6 bits
}
```

**12 pièces** : F, I, L, N, P, T, U, V, W, X, Y, Z
- Pièce 1 (X) : 1 position (symétrie totale)
- Pièce 12 (I) : 2 positions (ligne)
- Autres : 4 ou 8 positions

### 3. Solutions

**2339 solutions canoniques** (une par classe de symétrie)
- Stockées dans `solutions_6x10_normalisees.bin` (45 octets chacune)
- **9356 solutions totales** avec 4 transformations :
  1. Identité
  2. Rotation 180°
  3. Miroir horizontal
  4. Miroir vertical

### 4. Modes de jeu

**Détection automatique** basée sur l'état :
- `isTutorialMode = true` → Mode Tutoriel
- `selectedPlacedPiece != null` → Mode Isométries
- `selectedPiece != null` → Mode Jeu
- Sinon → Mode neutre

---

## 🚀 Commandes utiles

### Développement

```bash
# Lancer l'app
flutter run

# Hot reload
r

# Hot restart
R

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Générer code (Drift, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Tests
flutter test
```

### Build

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release

# Web
flutter build web --release
```

### Debugging

```bash
# Logs détaillés
flutter run --verbose

# Profiler performance
flutter run --profile

# Inspecter widget tree
flutter run --debug
# Puis appuyer sur 'w' dans le terminal
```

---

## 🐛 Problèmes fréquents

### 1. "Provider not found"

**Cause** : Provider non déclaré dans `ProviderScope`

**Solution** :
```dart
runApp(
  ProviderScope(  // ✅ Nécessaire pour Riverpod
    child: MyApp(),
  ),
);
```

### 2. "State not updating"

**Cause** : Mutation directe au lieu de `copyWith()`

**Solution** :
```dart
// ❌ MAUVAIS
state.selectedPiece = index;

// ✅ BON
state = state.copyWith(selectedPiece: index);
```

### 3. "Solutions not loaded"

**Cause** : `solutionMatcher` pas initialisé

**Solution** :
```dart
// Dans main.dart
Future.microtask(() async {
  final solutions = await loadNormalizedSolutionsAsBigInt();
  solutionMatcher.initWithBigIntSolutions(solutions);
});
```

### 4. "Duel not syncing"

**Cause** : Supabase Realtime pas initialisé

**Solution** :
```dart
// Vérifier bootstrap.dart
await Supabase.initialize(
  url: SUPABASE_URL,
  anonKey: SUPABASE_ANON_KEY,
);
```

---

## 📈 Statistiques du projet

### Lignes de code (actuel)

| Module | Lignes | % Total |
|--------|--------|---------|
| Core (jeu) | ~5,200 | 55% |
| Tutoriel | ~2,700 | 29% |
| Duel | ~1,500 | 16% |
| **TOTAL** | **~9,400** | **100%** |

### Fichiers par catégorie

| Catégorie | Nombre | Exemples |
|-----------|--------|----------|
| Screens | 17 | `pentomino_game_screen.dart`, `duel_game_screen.dart` |
| Providers | 3 | `pentomino_game_provider.dart`, `tutorial_provider.dart` |
| Models | 7 | `pentominos.dart`, `app_settings.dart` |
| Services | 6 | `pentomino_solver.dart`, `solution_matcher.dart` |
| Widgets | 15+ | `game_board.dart`, `piece_slider.dart` |
| Tutorial | 23 | Commandes, parser, interpréteur |
| Duel | 17 | Écrans, services, widgets |

### Performance

| Opération | Temps |
|-----------|-------|
| Chargement solutions | 200-500 ms |
| Génération transformations | 100-300 ms |
| Comptage solutions compatibles | 10-50 ms |
| Transformation isométrique | 1-5 ms |
| Exécution commande tutoriel | 1-10 ms |
| Génération mini-puzzle | < 2 s |

---

## 🎯 Roadmap

### ✅ Fait (Novembre 2025)

- [x] Mode Jeu classique (6×10, 12 pièces)
- [x] Mode Isométries (rotations/miroirs)
- [x] Système de tutoriel (29 commandes)
- [x] Mode Duel multijoueur
- [x] Refactoring architecture (-76% lignes)
- [x] Commande TRANSLATE (déplacement animé)

### 🚧 En cours (Décembre 2025)

- [ ] Mode Mini-puzzles (2×5, 3×5, 4×5, 5×5)
- [ ] Statistiques mini-puzzles
- [ ] Tutoriels supplémentaires

### 📅 Prévu (2026)

- [ ] Mode challenge avec objectifs
- [ ] Classements Duel
- [ ] Éditeur visuel de tutoriels
- [ ] Support autres formats (non 6×10)
- [ ] Tournois en mode Duel

---

## 📞 Support

### Documentation complète

- **CURSORDOC.md** : Documentation technique exhaustive (1380 lignes)
- **TUTORIAL_ARCHITECTURE.md** : Architecture système tutoriel
- **CODE_STANDARDS.md** : Standards de code

### Ressources externes

- **Flutter** : https://flutter.dev/docs
- **Riverpod** : https://riverpod.dev/docs
- **Supabase** : https://supabase.com/docs
- **Pentominos** : https://en.wikipedia.org/wiki/Pentomino

---

## 🏆 Crédits

**Développement** : Projet Pentapol  
**Architecture** : Riverpod + Flutter + Supabase  
**Documentation** : Générée avec Claude Sonnet 4.5

**Dernière mise à jour** : 1er décembre 2025 à 01:15

**Changements récents** :
- 1er décembre 2025 : Suppression système Race, nouveau HomeScreen moderne

---

**📌 Note** : Cette documentation est un résumé opérationnel. Pour les détails techniques complets, consulter **CURSORDOC.md**.



