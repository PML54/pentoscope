// lib/tutorial/models/tutorial_context.dart
// Contexte d'exécution d'un tutoriel


import 'package:pentapol/classical/pentomino_game_provider.dart';

/// Contexte d'exécution d'un tutoriel
class TutorialContext {
  /// Notifier du jeu (accès aux méthodes de manipulation)
  final PentominoGameNotifier gameNotifier;

  /// Ref Riverpod (pour accéder à d'autres providers si besoin)
  final dynamic ref;

  /// Variables du script (pour stocker des valeurs temporaires)
  final Map<String, dynamic> variables;

  /// Message actuel affiché
  String? currentMessage;

  /// État de pause
  bool isPaused = false;

  /// État d'annulation
  bool isCancelled = false;

  TutorialContext({
    required this.gameNotifier,
    required this.ref,
    Map<String, dynamic>? variables,
  }) : variables = variables ?? {};

  // ============================================================
  // GESTION DES MESSAGES
  // ============================================================

  /// Affiche un message
  void setMessage(String text) {
    currentMessage = text;
    print('[TUTORIAL] Message: $text');
  }

  /// Efface le message
  void clearMessage() {
    currentMessage = null;
    print('[TUTORIAL] Message effacé');
  }

  // ============================================================
  // GESTION DES VARIABLES
  // ============================================================

  /// Définit une variable
  void setVariable(String name, dynamic value) {
    variables[name] = value;
    print('[TUTORIAL] Variable $name = $value');
  }

  /// Récupère une variable
  dynamic getVariable(String name) {
    return variables[name];
  }

  /// Incrémente une variable numérique
  void incrementVariable(String name) {
    variables[name] = (variables[name] as num? ?? 0) + 1;
  }

  // ============================================================
  // CONTRÔLE D'EXÉCUTION
  // ============================================================

  /// Met en pause l'exécution
  void pause() {
    isPaused = true;
    print('[TUTORIAL] Pause');
  }

  /// Reprend l'exécution
  void resume() {
    isPaused = false;
    print('[TUTORIAL] Reprise');
  }

  /// Annule l'exécution
  void cancel() {
    isCancelled = true;
    print('[TUTORIAL] Annulé');
  }

  /// Attend que le tutoriel ne soit plus en pause
  Future<void> waitIfPaused() async {
    while (isPaused && !isCancelled) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
