import 'package:flutter/material.dart';

import './text.dart';

class BlockTalkDropdownButton extends StatefulWidget {
  final List<String> items;
  final Function(String)? onChanged;

  const BlockTalkDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
 _BlockTalkDropdownButtonState createState() => _BlockTalkDropdownButtonState();
}

class _BlockTalkDropdownButtonState extends State<BlockTalkDropdownButton> {
  String? selectedValue = '10mi';
  String _currentChoice = '10mi';

  void setCurrentChoice(String? value) {
    if (value == null || value.isEmpty) return;

    setState(() {
      _currentChoice = value;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      alignment: Alignment.center,
      isExpanded: true,
      value: _currentChoice,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16.0,
      ),
      dropdownColor: Colors.white,
      items: widget.items
          .map<DropdownMenuItem<String>>(
              (String item) => DropdownMenuItem<String>(
                    value: item,
                    child: BlockTalkText(text: item),
                  ))
          .toList(),
      onChanged: (String? value) =>
        setCurrentChoice(value)
    );
  }
}