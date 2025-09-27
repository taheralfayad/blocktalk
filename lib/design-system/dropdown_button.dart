import 'package:flutter/material.dart';
import './text.dart';

class BlockTalkDropdownButton extends StatefulWidget {
  final List<String> items;
  final Function(String)? onChanged;
  final String? title;
  final String? currentChoice;

  const BlockTalkDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    required this.currentChoice,
    this.title,
  });

  @override
  _BlockTalkDropdownButtonState createState() =>
      _BlockTalkDropdownButtonState();
}

class _BlockTalkDropdownButtonState extends State<BlockTalkDropdownButton> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.currentChoice;
  }

  void setCurrentChoice(String? value) {
    if (value == null || value.isEmpty) return;
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.currentChoice,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.title,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      dropdownColor: Colors.white,
      items: widget.items
          .map<DropdownMenuItem<String>>(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: BlockTalkText(text: item)
            ),
          )
          .toList(),
      onChanged: setCurrentChoice,
    );
  }
}
