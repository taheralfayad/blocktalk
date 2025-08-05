import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class BlockTalkTypeAhead extends StatefulWidget {
  final List<String> suggestions;
  final TextEditingController controller;
  final List<Function(String)> selectedCallbacks;
  final bool optionInSuggestions;
  final Function(bool) optionInSuggestionsCallback;
  final String? initialValue;

  const BlockTalkTypeAhead({
    super.key,
    required this.suggestions,
    required this.controller,
    this.selectedCallbacks = const [],
    required this.optionInSuggestions,
    required this.optionInSuggestionsCallback,
    this.initialValue,
  });

  @override
  State<BlockTalkTypeAhead> createState() => _BlockTalkTypeAheadState();
}

class _BlockTalkTypeAheadState extends State<BlockTalkTypeAhead> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      print("------");
      print(widget.suggestions);
      print(widget.controller.text);
      print("------");
      if (widget.controller.text.isEmpty || !widget.suggestions.contains(widget.controller.text)) {
        widget.optionInSuggestionsCallback(false);
      } else {
        widget.optionInSuggestionsCallback(true);
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
            suffixIcon: !widget.optionInSuggestions
                ? const Icon(Icons.warning, color: Colors.red)
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
      onSelected: (String suggestion) {
        setState(() {
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