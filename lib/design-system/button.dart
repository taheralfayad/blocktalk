import 'package:flutter/material.dart';
import './text.dart';
import './colors.dart';


class BlockTalkButton extends StatelessWidget {
  final String text;
  final String type;
  final VoidCallback onPressed;
  final Color buttonColor;

  const BlockTalkButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    if (type == "solid") {
      return ElevatedButton(
        onPressed: () {onPressed();},
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: BlockTalkText(text: text, color: AppColors.buttonTextColor),
      );
    }
    else if (type == "outline") {
      return OutlinedButton(
        onPressed: () {onPressed();},
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rectangular corners
          ),
          side: BorderSide(color: buttonColor, width: 2.0),
        ),
        child: BlockTalkText(text: text),
      );
    } else {
      throw Exception("Invalid button type");
    }
  }
}