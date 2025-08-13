import "package:flutter/material.dart";

import './colors.dart';

class VoteButton extends StatelessWidget {
  final String label;
  final int votes;
  final bool hasAlreadyVoted;
  final Icon icon;
  final Function(String interactionType) onPressed;

  const VoteButton({
    super.key,
    required this.label,
    required this.votes,
    required this.hasAlreadyVoted,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: hasAlreadyVoted ? Colors.white : AppColors.primaryButtonColor,
        backgroundColor: hasAlreadyVoted ? AppColors.primaryButtonColor : Colors.white,
      ),
      label: Text("$label ($votes)"),
      icon: icon,
      onPressed: () {
        onPressed(label);
      },
    );
  }
}
