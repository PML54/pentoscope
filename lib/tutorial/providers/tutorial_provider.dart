// lib/tutorial/providers/tutorial_provider.dart
// Provider Riverpod pour la gestion des tutoriels

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/tutorial/models/tutorial_state.dart';
import 'package:pentapol/tutorial/models/tutorial_script.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';
import 'package:pentapol/tutorial/interpreter/scratch_interpreter.dart';
import 'package:pentapol/classical/pentomino_game_provider.dart';

/// Provider pour l'état du tutoriel
final tutorialProvider = NotifierProvider<TutorialNotifier, TutorialState>(() {
  return TutorialNotifier();
});

/// Notifier pour gérer l'état des tutoriels
class TutorialNotifier extends Notifier<TutorialState> {
  @override
  TutorialState build() => TutorialState.initial();

  // ============================================================
  // CHARGEMENT DE SCRIPTS
  // ============================================================

  /// Charge un script de tutoriel
  void loadScript(TutorialScript script) {
    if (state.isRunning) {
      throw StateError('Un tutoriel est déjà en cours');
    }

    print('[TUTORIAL] Chargement du script: ${script.name}');

    state = state.copyWith(
      currentScript: script,
      isLoaded: true,
      currentStep: 0,
      scriptName: script.name, // ← Ajouter le nom du script
    );
  }

  /// Décharge le script actuel
  void unloadScript() {
    if (state.isRunning) {
      stop();
    }

    state = state.copyWith(
      clearCurrentScript: true,
      clearInterpreter: true,
      clearContext: true,
      isLoaded: false,
      currentStep: 0,
      clearScriptName: true, // ← Clear le nom du script
    );

    print('[TUTORIAL] Script déchargé');
  }

  // ============================================================
  // EXÉCUTION
  // ============================================================

  /// Démarre l'exécution du script chargé
  Future<void> start() async {
    if (!state.isLoaded || state.currentScript == null) {
      throw StateError('Aucun script chargé');
    }

    if (state.isRunning) {
      throw StateError('Le tutoriel est déjà en cours');
    }

    print('[TUTORIAL] Démarrage du tutoriel: ${state.currentScript!.name}');

    // 💾 SAUVEGARDER l'état du jeu AVANT d'entrer en mode tutorial
    final gameState = ref.read(pentominoGameProvider);
    print('[TUTORIAL] 💾 Sauvegarde de l\'état du jeu (${gameState.placedPieces.length} pièces placées)');

    // Créer le contexte
    final gameNotifier = ref.read(pentominoGameProvider.notifier);
    final context = TutorialContext(
      gameNotifier: gameNotifier,
      ref: ref,
      variables: Map.from(state.currentScript!.variables),
    );

    // Créer l'interpréteur
    final interpreter = ScratchInterpreter(
      script: state.currentScript!,
      context: context,
      onStepChanged: _onStepChanged,
      onCompleted: _onCompleted,
      onError: _onError,
    );

    state = state.copyWith(
      interpreter: interpreter,
      context: context,
      isRunning: true,
      currentStep: 0,
      savedGameState: gameState, // 💾 Sauvegarde
    );

    // Lancer l'exécution en asynchrone
    print('[TUTORIAL] 🟢 Appel de interpreter.run()...');
    interpreter.run();
    print('[TUTORIAL] 🟢 Appel terminé (asynchrone)');
  }

  /// Callback quand une étape change
  void _onStepChanged(int step) {
    state = state.copyWith(currentStep: step);

    // Mettre à jour le message si le contexte en a un
    if (state.context?.currentMessage != null) {
      state = state.copyWith(currentMessage: state.context!.currentMessage);
    }
  }

  /// Callback quand le script est terminé
  void _onCompleted() {
    print('[TUTORIAL] 🏁 Tutoriel terminé: ${state.currentScript?.name}');
    print('[TUTORIAL] 🔍 État AVANT nettoyage:');
    print('[TUTORIAL]   - isRunning: ${state.isRunning}');
    print('[TUTORIAL]   - isLoaded: ${state.isLoaded}');
    print('[TUTORIAL]   - isCompleted: ${state.isCompleted}');
    print('[TUTORIAL]   - currentStep: ${state.currentStep}');
    print('[TUTORIAL]   - totalSteps: ${state.totalSteps}');

    // ♻️ RESTAURER l'état du jeu sauvegardé
    _restoreGameState();

    // ⚠️ NE PAS nettoyer complètement - garder le script chargé pour afficher le message de fin
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      clearInterpreter: true,
      clearContext: true,
      clearCurrentMessage: true,
      clearSavedGameState: true,
      // ← NE PAS clear currentScript ni isLoaded
      // ← NE PAS reset currentStep pour que isCompleted soit true
    );

    print('[TUTORIAL] 🔍 État APRÈS nettoyage:');
    print('[TUTORIAL]   - isRunning: ${state.isRunning}');
    print('[TUTORIAL]   - isLoaded: ${state.isLoaded}');
    print('[TUTORIAL]   - isCompleted: ${state.isCompleted}');
    print('[TUTORIAL]   - scriptName: ${state.scriptName}');
    print('[TUTORIAL] ✅ Les contrôles devraient rester visibles !');
  }

  /// Callback en cas d'erreur
  void _onError(Object error, StackTrace stackTrace) {
    print('[TUTORIAL] Erreur dans le tutoriel: $error');
    print(stackTrace);

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      currentMessage: 'Erreur: $error',
    );
  }

  // ============================================================
  // CONTRÔLES
  // ============================================================

  /// Met en pause
  void pause() {
    if (!state.isRunning) return;

    state.interpreter?.pause();
    state = state.copyWith(isPaused: true);
    print('[TUTORIAL] Pause');
  }

  /// Reprend l'exécution
  void resume() {
    if (!state.isRunning) return;

    state.interpreter?.resume();
    state = state.copyWith(isPaused: false);
    print('[TUTORIAL] Reprise');
  }

  /// Arrête l'exécution
  void stop() {
    if (!state.isRunning) return;

    state.interpreter?.stop();

    // ♻️ RESTAURER l'état du jeu sauvegardé
    _restoreGameState();

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      currentStep: 0,
      clearSavedGameState: true,
    );

    print('[TUTORIAL] Arrêt');
  }

  /// 🆕 QUITTE le tutoriel (fonctionne même si terminé)
  void quit() {
    print('[TUTORIAL] 🚪 Quit demandé (isRunning: ${state.isRunning}, isLoaded: ${state.isLoaded})');

    // ✅ Fonctionner même si le tutorial est terminé (isRunning = false)
    if (!state.isLoaded) {
      print('[TUTORIAL] ⚠️ Aucun tutorial chargé, rien à quitter');
      return;
    }

    // Arrêter l'interpréteur si encore en cours
    if (state.isRunning) {
      state.interpreter?.stop();
    }

    // ♻️ RESTAURER l'état du jeu sauvegardé (si pas déjà fait)
    _restoreGameState();

    // Nettoyer complètement
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      clearCurrentScript: true,
      clearInterpreter: true,
      clearContext: true,
      clearCurrentMessage: true,
      clearSavedGameState: true,
      isLoaded: false,
      currentStep: 0,
      clearScriptName: true,
    );

    print('[TUTORIAL] 🚪 Quit terminé - Retour au jeu normal');
  }

  /// ♻️ Restaure l'état du jeu sauvegardé
  void _restoreGameState() {
    if (state.savedGameState != null) {
      print('[TUTORIAL] ♻️ Restauration de l\'état du jeu (${state.savedGameState!.placedPieces.length} pièces)');
      ref.read(pentominoGameProvider.notifier).restoreState(state.savedGameState!);
    } else {
      print('[TUTORIAL] ⚠️ Aucun état à restaurer');
    }
  }

  /// Redémarre depuis le début
  Future<void> restart() async {
    stop();
    await Future.delayed(const Duration(milliseconds: 100));
    await start();
  }

  // ============================================================
  // PAS À PAS
  // ============================================================

  /// Exécute l'étape suivante (mode pas à pas)
  Future<void> stepNext() async {
    if (state.interpreter == null) return;

    await state.interpreter!.stepNext();
    state = state.copyWith(currentStep: state.interpreter!.currentStep);
  }

  /// Revient à l'étape précédente
  void stepBack() {
    if (state.interpreter == null) return;

    state.interpreter!.stepBack();
    state = state.copyWith(currentStep: state.interpreter!.currentStep);
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Met à jour le message affiché
  void updateMessage(String? message) {
    state = state.copyWith(
      currentMessage: message,
      clearCurrentMessage: message == null,
    );
  }
}