import 'package:flutter/material.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';

class BlockTalkBanner extends StatelessWidget {
  final String text;

  const BlockTalkBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.navigationBarColor,
            width: 1.0,
          ),
        )
      ),
      child: BlockTalkText(
        text: text,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryTextColor,
      )
    );
  }
}