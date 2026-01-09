// lib/tutorial/commands/message_commands.dart
// Commandes de gestion des messages

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';


/// Commande SHOW_MESSAGE - Affiche un message avec timeout optionnel
class ShowMessageCommand extends ScratchCommand {
  final String text;
  final int? autoHideAfter; // en millisecondes, null = pas de timeout

  const ShowMessageCommand({
    required this.text,
    this.autoHideAfter,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    context.setMessage(text);

    // Si autoHideAfter est défini, effacer le message après ce délai
    if (autoHideAfter != null && autoHideAfter! > 0) {
      await Future.delayed(Duration(milliseconds: autoHideAfter!));
      context.clearMessage();
    }
  }

  @override
  String get name => 'SHOW_MESSAGE';

  @override
  String get description => 'Affiche: "$text"${autoHideAfter != null ? " (auto-hide après ${autoHideAfter}ms)" : ""}';

  factory ShowMessageCommand.fromMap(Map<String, dynamic> params) {
    return ShowMessageCommand(
      text: params['text'] as String? ?? '',
      autoHideAfter: params['autoHideAfter'] as int?,
    );
  }
}

/// Commande CLEAR_MESSAGE - Efface le message
class ClearMessageCommand extends ScratchCommand {
  const ClearMessageCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.clearMessage();
  }

  @override
  String get name => 'CLEAR_MESSAGE';

  @override
  String get description => 'Efface le message';
}
