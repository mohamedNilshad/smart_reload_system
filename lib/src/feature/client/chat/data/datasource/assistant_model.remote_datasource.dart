// Prefixed because firebase_ai also exports a class called ServerException.
import 'package:firebase_ai/firebase_ai.dart' as fai;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:smart_reload_system/src/core/error/exceptions.dart';

/// Gemini model for the assistant. Model names are retired regularly, so
/// check the "Models" page of the Firebase AI Logic docs and update this when
/// needed. A "flash-lite" model is the cheapest and fits the free tier best;
/// use a bigger one (for example gemini-3.8-flash) for better answers.
const kAssistantModel = 'gemini-3.5-flash-lite';

/// Talks to Gemini through Firebase AI Logic (free on the Spark plan; no API
/// key in the app and no backend to run).
class AssistantModelDataSource {
  fai.ChatSession? _chat;

  /// Starts a new conversation with the given instructions. Anything said
  /// before is forgotten.
  void start(String systemPrompt) {
    final model = fai.FirebaseAI.googleAI().generativeModel(model: kAssistantModel, systemInstruction: fai.Content.system(systemPrompt));
    _chat = model.startChat();
  }

  Future<String> send(String text) async {
    final chat = _chat;
    if (chat == null) {
      throw ServerException('The assistant is not ready yet. Please try again.');
    }

    try {
      final response = await chat.sendMessage(fai.Content.text(text)).timeout(const Duration(seconds: 45));

      final reply = response.text?.trim();
      if (reply == null || reply.isEmpty) {
        // Usually a blocked or empty answer.
        throw ServerException('I couldn\'t answer that. Could you ask it another way?');
      }
      return reply;
    } on ServerException {
      rethrow;
    } catch (e) {
      // Typical causes while developing: App Check not set up (403), the model
      // name was retired, or the free quota was reached (429).
      debugPrint('Assistant request failed: $e');
      throw ServerException(_friendlyMessage(e));
    }
  }

  String _friendlyMessage(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('429') ||
        s.contains('quota') ||
        s.contains('resource_exhausted') ||
        s.contains('rate limit') ||
        s.contains('too many requests')) {
      return 'The assistant is very busy right now. Please try again in a few minutes.';
    }
    if (s.contains('socket') ||
        s.contains('network') ||
        s.contains('timeout') ||
        s.contains('unavailable')) {
      return 'Couldn\'t reach the assistant. Check your internet connection and try again.';
    }
    if (s.contains('403') || s.contains('permission') || s.contains('app check')) {
      return 'The assistant isn\'t available right now.';
    }
    return 'Something went wrong. Please try again.';
  }
}
