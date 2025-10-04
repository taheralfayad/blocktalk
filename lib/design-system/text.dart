import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design-system/colors.dart';

class BlockTalkText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const BlockTalkText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = AppColors.primaryTextColor,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );

    return Text(text, style: style, textAlign: textAlign);
  }
}
