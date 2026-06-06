import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class DemoModeAnimatedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final Duration typingSpeed;
  final Duration pauseDuration;

  const DemoModeAnimatedText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.color = Colors.redAccent,
    this.fontWeight = FontWeight.bold,
    this.typingSpeed = const Duration(milliseconds: 120),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: true,
      pause: pauseDuration,
      animatedTexts: [
        TyperAnimatedText(
          text,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
          speed: typingSpeed,
        ),
        

      ],
    );
  }
}
