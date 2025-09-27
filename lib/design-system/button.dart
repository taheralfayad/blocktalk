import 'package:flutter/material.dart';
import './text.dart';
import './colors.dart';


class BlockTalkButton extends StatelessWidget {
  final String text;
  final String type;
  final VoidCallback onPressed;
  final Color buttonColor;
  final bool? selected;

  const BlockTalkButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.buttonColor = AppColors.primaryButtonColor,
    this.selected
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
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: BorderSide(color: buttonColor, width: 2.0),
        ),
        child: BlockTalkText(text: text),
      );
    }
    else if (type == "transparent") {
      return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: selected! 
              ? buttonColor.withOpacity(0.1)
              : Colors.transparent,
          foregroundColor: selected! 
              ? Theme.of(context).colorScheme.primary
              : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: selected!
                ? BorderSide(color: buttonColor)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: BlockTalkText(
          text: text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    } else {
      return BlockTalkText(text: "Invalid Button Type");
    }
  }
}