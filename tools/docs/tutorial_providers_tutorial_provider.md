# tutorial/providers/tutorial_provider.dart

**Module:** tutorial

## Fonctions

### TutorialNotifier

Provider pour l'état du tutoriel


```dart
return TutorialNotifier();
```

### build

Notifier pour gérer l'état des tutoriels


```dart
TutorialState build() => TutorialState.initial();
```

### loadScript

Charge un script de tutoriel


```dart
void loadScript(TutorialScript script) {
```

### StateError

```dart
throw StateError('Un tutoriel est déjà en cours');
```

### unloadScript

Décharge le script actuel


```dart
void unloadScript() {
```

### start

Démarre l'exécution du script chargé


```dart
Future<void> start() async {
```

### StateError

```dart
throw StateError('Aucun script chargé');
```

### StateError

```dart
throw StateError('Le tutoriel est déjà en cours');
```

### pause

Callback quand une étape change
Callback quand le script est terminé
Callback en cas d'erreur
Met en pause


```dart
void pause() {
```

### resume

Reprend l'exécution


```dart
void resume() {
```

### stop

Arrête l'exécution


```dart
void stop() {
```

### quit

🆕 QUITTE le tutoriel (fonctionne même si terminé)


```dart
void quit() {
```

### restart

♻️ Restaure l'état du jeu sauvegardé
Redémarre depuis le début


```dart
Future<void> restart() async {
```

### start

```dart
await start();
```

### stepNext

Exécute l'étape suivante (mode pas à pas)


```dart
Future<void> stepNext() async {
```

### stepBack

Revient à l'étape précédente


```dart
void stepBack() {
```

### updateMessage

Met à jour le message affiché


```dart
void updateMessage(String? message) {
```

