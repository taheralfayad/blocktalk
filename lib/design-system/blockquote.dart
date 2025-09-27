import 'package:flutter/material.dart';

import './text.dart';
import './colors.dart';

class Blockquote extends StatelessWidget {
  final String headerText;
  final String? quoteText;

  const Blockquote({
    super.key,
    required this.headerText,
    required this.quoteText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.blockColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6.0),
        border: Border(
          left: BorderSide(color: AppColors.blockColor, width: 4.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlockTalkText(text: headerText, fontWeight: FontWeight.bold),
          SizedBox(height: 6),
          BlockTalkText(text: "\"$quoteText\""),
        ],
      ),
    );
  }
}
