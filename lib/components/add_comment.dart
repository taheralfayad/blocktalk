import 'package:flutter/material.dart';

import '../design-system/button.dart';
import '../design-system/colors.dart';
import '../design-system/dropdown_button.dart';
import '../design-system/text.dart';

class AddComment extends StatefulWidget {
  final String avatarUrl;
  final String placeholderText;
  final bool withClassification;
  final Function(String, String)? onSubmit;
  final TextEditingController commentController;
  final Function(String)? onClassificationChanged;
  final bool disabled;
  final FocusNode? focusNode;
  final String? selectedClassification;
  final List<String>? commentClassifications;
  final String? highlightedText;

  const AddComment({
    super.key,
    this.avatarUrl = 'assets/avatar.jpg',
    this.withClassification = true,
    this.placeholderText = 'Add an opinion or provide a source...',
    this.onSubmit,
    required this.commentController,
    this.onClassificationChanged,
    required this.disabled,
    this.focusNode,
    this.selectedClassification,
    this.commentClassifications,
    this.highlightedText
  });

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {

  TextField _returnTextField() {
    return TextField(
      onTapOutside: (event) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      autofocus: false,
      autocorrect: false,
      controller: widget.commentController,
      minLines: 1,
      maxLength: 200,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: widget.placeholderText,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
      focusNode: widget.focusNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 300.0),
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blockColor.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundImage: AssetImage(widget.avatarUrl),
                      ),
                    ),
                    Flexible(child: _returnTextField()),
                  ],
                ),
                SizedBox(height: 8.0),
              if (widget.selectedClassification == "Improvement" &&
                  widget.highlightedText != null &&
                  widget.highlightedText!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.blockColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.blockColor,
                        width: 4.0,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BlockTalkText(
                        text: "You are suggesting improvements for:",
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      BlockTalkText(
                        text: "\"${widget.highlightedText}\"",
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.withClassification)
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: BlockTalkDropdownButton(
                          currentChoice: widget.selectedClassification,
                          items: widget.commentClassifications!,
                          onChanged: (String? value) {
                            if (value != null && value.isNotEmpty) {
                              widget.onClassificationChanged?.call(value);
                            }
                          },
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: BlockTalkButton(
                        text: 'Submit',
                        type: "outline",
                        onPressed: () {
                          if (widget.commentController.text.isNotEmpty) {
                            if (widget.onSubmit != null) {
                              widget.onSubmit!(
                                widget.commentController.text,
                                widget.selectedClassification!,
                              );
                            }
                            widget.commentController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.disabled)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.96), // semi-transparent grey
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apartment, size: 56, color: Colors.white),
                      BlockTalkText(
                        text: "Log in to be able to contribute!",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
