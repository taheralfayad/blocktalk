import 'package:flutter/material.dart';
import './text.dart';

class BlockTalkDropdownButton extends StatefulWidget {
  final List<String> items;
  final Function(String)? onChanged;
  final String? initialValue;
  final String? title;

  const BlockTalkDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    required this.initialValue,
    this.title,
  });

  @override
  _BlockTalkDropdownButtonState createState() =>
      _BlockTalkDropdownButtonState();
}

class _BlockTalkDropdownButtonState extends State<BlockTalkDropdownButton> {
  String? selectedValue;
  String? _currentChoice;

  @override
  void initState() {
    super.initState();
    _currentChoice = widget.initialValue ?? widget.items.first;
    selectedValue = _currentChoice;
  }

  void setCurrentChoice(String? value) {
    if (value == null || value.isEmpty) return;
    setState(() {
      _currentChoice = value;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _currentChoice,
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
