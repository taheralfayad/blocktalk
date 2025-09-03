import 'package:flutter/material.dart';


import '../design-system/colors.dart';

class BlockTalkPill extends StatelessWidget {
  final String text;
  final String classification;

  const BlockTalkPill({
    super.key,
    required this.text,
    required this.classification
  });

  Color _getBackgroundColor() {
    switch (classification) {
      case 'Zoning':
        return AppColors.navigationBarColor;
      case 'Progress':
        return AppColors.progressTagColor;
      default:
        return AppColors.navigationBarColor;
    }
  }

  String _getPillText() {
    switch (classification) {
      case 'Zoning':
        return '🏘️' + text;
      case 'Progress':
        return '🏗️' + text;
      default:
        return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getPillText(),
        style: TextStyle(
          color: AppColors.buttonTextColor,
        ),
    ),
    );
  }
}