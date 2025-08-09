import 'package:flutter/material.dart';


import '../design-system/colors.dart';

class BlockTalkPill extends StatelessWidget {
  final String text;

  const BlockTalkPill({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navigationBarColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.buttonTextColor,
        ),
    ),
    );
  }
}