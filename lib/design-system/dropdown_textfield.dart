import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class BlockTalkTypeAhead extends StatefulWidget {
  final List<String> suggestions;
  final TextEditingController controller;
  final List<Function(String)> selectedCallbacks;
  final bool optionDoesNotEqualControllerText;
  final Function(bool) optionDoesNotEqualControllerTextCallback;

  const BlockTalkTypeAhead({
    super.key,
    required this.suggestions,
    required this.controller,
    this.selectedCallbacks = const [],
    required this.optionDoesNotEqualControllerText,
    required this.optionDoesNotEqualControllerTextCallback,
  });

  @override
  State<BlockTalkTypeAhead> createState() => _BlockTalkTypeAheadState();
}

class _BlockTalkTypeAheadState extends State<BlockTalkTypeAhead> {
  String _selectedOption = '';

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (widget.controller.text != _selectedOption || widget.controller.text.isEmpty) {
        widget.optionDoesNotEqualControllerTextCallback(true);
      } 
      else {
        widget.optionDoesNotEqualControllerTextCallback(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: widget.controller,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: widget.controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            labelText: 'Enter Location',
            suffixIcon: widget.optionDoesNotEqualControllerText
                ? const Icon(Icons.warning, color: Colors.red)
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
      onSelected: (String suggestion) {
        setState(() {
          _selectedOption = suggestion;
          widget.controller.text = suggestion;
        });

        for (var callback in widget.selectedCallbacks) {
          callback(suggestion);
        }
      },
      suggestionsCallback: (pattern) {
        return widget.suggestions;
      },
      emptyBuilder: (context) {
        return Material(
          color: Colors.white,
          child: ListTile(
            title: Text('No suggestions found'),
          ),
        );
      },
      itemBuilder: (context, suggestion) {
        return Material(
          color: Colors.white,
          child: ListTile(
            title: Text(suggestion),
          ),
        );
      },
    );
  }
}