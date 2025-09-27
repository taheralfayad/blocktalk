import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design-system/colors.dart';

class BlockTalkText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final bool isSelectable;
  final FocusNode? suggestImprovementFocusNode;
  final Function(String)? setClassificationValue;
  final Function(String)? selectableCallback;

  const BlockTalkText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = AppColors.primaryTextColor,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.isSelectable = false,
    // These values will only be used in entry.dart
    // What these do is that they allow us the ability 
    // to highlight text in an entry, suggest an improvement
    // and comment their suggestion
    this.suggestImprovementFocusNode,
    this.setClassificationValue,
    this.selectableCallback
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );

    if (isSelectable) {
      return SelectableText(
        text,
        style: style,
        textAlign: textAlign,
        contextMenuBuilder: (context, editableTextState) {
          final selection = editableTextState.textEditingValue.selection;
          String selectedText = "";

          if (selection.isValid && !selection.isCollapsed) {
            selectedText = editableTextState.textEditingValue.text.substring(
              selection.start,
              selection.end,
            );
          }

          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: [
              ContextMenuButtonItem(
                onPressed: () {
                  setClassificationValue?.call("Improvement");
                  FocusScope.of(context).requestFocus(suggestImprovementFocusNode);
                  selectableCallback!(selectedText);
                },
                label: 'Suggest improvement',
              ),
              ...editableTextState.contextMenuButtonItems,
            ],
          );
        },
      );
    }

    return Text(text, style: style, textAlign: textAlign);
  }
}
