# tutorial/interpreter/scratch_interpreter.dart

**Module:** tutorial

## Fonctions

### run

Interpréteur de scripts Scratch-Pentapol
Script à exécuter
Contexte d'exécution
Étape courante
En cours d'exécution
Callbacks
Lance l'exécution du script du début à la fin


```dart
Future<void> run() async {
```

### StateError

```dart
throw StateError('Le script est déjà en cours d\'exécution');
```

### pause

Met en pause


```dart
void pause() {
```

### resume

Reprend


```dart
void resume() {
```

### stop

Arrête l'exécution


```dart
void stop() {
```

### stepNext

Exécute la prochaine étape (mode pas à pas)


```dart
Future<void> stepNext() async {
```

### stepBack

Revient à l'étape précédente


```dart
void stepBack() {
```

### reset

Réinitialise au début


```dart
void reset() {
```

