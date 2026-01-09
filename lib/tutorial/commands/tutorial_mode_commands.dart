// lib/tutorial/commands/tutorial_mode_commands.dart
// Commandes de gestion du mode tutoriel

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// Commande ENTER_TUTORIAL_MODE - Entre en mode tutoriel
class EnterTutorialModeCommand extends ScratchCommand {
  const EnterTutorialModeCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.enterTutorialMode();
  }

  @override
  String get name => 'ENTER_TUTORIAL_MODE';

  @override
  String get description => 'Entre en mode tutoriel';
}

/// Commande EXIT_TUTORIAL_MODE - Sort du mode tutoriel
class ExitTutorialModeCommand extends ScratchCommand {
  final bool restore;

  const ExitTutorialModeCommand({this.restore = true});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.exitTutorialMode(restore: restore);
  }

  @override
  String get name => 'EXIT_TUTORIAL_MODE';

  @override
  String get description => 'Sort du mode tutoriel (restore: $restore)';

  factory ExitTutorialModeCommand.fromMap(Map<String, dynamic> params) {
    return ExitTutorialModeCommand(restore: params['restore'] as bool? ?? true);
  }
}

/// Commande CANCEL_TUTORIAL - Annule le tutoriel
class CancelTutorialCommand extends ScratchCommand {
  const CancelTutorialCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.cancelTutorial();
  }

  @override
  String get name => 'CANCEL_TUTORIAL';

  @override
  String get description => 'Annule le tutoriel';
}

/// Commande RESET_GAME - Réinitialise le jeu
class ResetGameCommand extends ScratchCommand {
  const ResetGameCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    // TODO: Méthode resetGame à implémenter
    print('[TUTORIAL] RESET_GAME non implémenté');
  }

  @override
  String get name => 'RESET_GAME';

  @override
  String get description => 'Réinitialise le jeu';
}
