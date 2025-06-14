import 'package:flutter/material.dart';

import '../design-system/button.dart';
import '../design-system/colors.dart';
import '../design-system/text.dart';

class AddComment extends StatefulWidget {
  final String avatarUrl;
  final String placeholderText;
  final bool withClassification;

  const AddComment({super.key,
   this.avatarUrl = 'assets/avatar.jpg',
   this.withClassification = true,
   this.placeholderText = 'Add an opinion or provide a source...'
  });

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final TextEditingController _commentController = TextEditingController();
  String _selectedClassification = 'Opinion';

  List<String> items = [
    'Opinion',
    'Source',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200.0),
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
              Flexible(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  autofocus: false,
                  autocorrect: false,
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: widget.placeholderText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.withClassification)
                DropdownButton<String>(
                  value: _selectedClassification,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClassification = newValue!;
                      print('Classification changed to: $_selectedClassification');
                    });
                  },
                  dropdownColor: AppColors.blockColor,
                  items: items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlockTalkButton(
                  text: 'Submit',
                  type: "outline",
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      // Handle comment submission logic here
                      print('Comment submitted: ${_commentController.text}');
                      print('Classification: $_selectedClassification');
                      _commentController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
