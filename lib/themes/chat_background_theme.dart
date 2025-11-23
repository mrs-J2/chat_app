import 'package:flutter/material.dart';

class ChatBackgroundTheme extends ThemeExtension<ChatBackgroundTheme> {
  final String chatBackgroundPath;

  const ChatBackgroundTheme({
    required this.chatBackgroundPath,
  });

  @override
  ChatBackgroundTheme copyWith({String? chatBackgroundPath}) {
    return ChatBackgroundTheme(
      chatBackgroundPath: chatBackgroundPath ?? this.chatBackgroundPath,
    );
  }

  @override
  ChatBackgroundTheme lerp(ThemeExtension<ChatBackgroundTheme>? other, double t) {
    if (other is! ChatBackgroundTheme) {
      return this;
    }
    // Since this is a string, we don't need a smooth transition (lerp).
    return t < 0.5 ? this : other; 
  }

  static ChatBackgroundTheme of(BuildContext context) {
    return Theme.of(context).extension<ChatBackgroundTheme>() ?? 
           const ChatBackgroundTheme(chatBackgroundPath: 'fallback_path');
  }
}