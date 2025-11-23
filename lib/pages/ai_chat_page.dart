// lib/pages/ai_chat_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  LlmProvider _createFirebaseProvider(BuildContext context) {
    return FirebaseProvider(
      model: FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final provider = _createFirebaseProvider(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text("Grok AI"),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Grok AI"),
                content: const Text("Powered by Google Gemini. Ask anything!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),

    body: Stack(
      children: [
        // BACKGROUND IMAGE (theme-aware)
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                Theme.of(context).brightness == Brightness.light
                    ? "lib/assets/icon/light.jpg"
                    : "lib/assets/icon/dark.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // CHAT VIEW
        LlmChatView(
          provider: provider,
          welcomeMessage:
              "Hey! I'm your AI assistant powered by Google Gemini.\nAsk me anything!",
          suggestions: const [
            'Give me a Flutter code snippet',
            'Tell me a joke about a developer',
            'What are the advantages of using Firebase?',
          ],
          style: LlmChatViewStyle(
            backgroundColor: const Color.fromARGB(0, 181, 68, 68), // Make it transparent
            llmMessageStyle: LlmMessageStyle(
              // Customize LLM message appearance if needed
            ),
            userMessageStyle: UserMessageStyle(
              textStyle: const TextStyle(color: Color.fromARGB(255, 2, 0, 0)),
            ),
          ),
        ),
      ],
    ),
  );
}
}