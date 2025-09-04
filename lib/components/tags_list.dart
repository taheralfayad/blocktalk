import 'package:flutter/material.dart';

import '../design-system/colors.dart';

class TagsList extends StatelessWidget {
  final List<Map<String,String>> tags;
  final Function(bool, String, String)? onSelected;
  final bool Function(String)? selectedTagsContainsTag;

  const TagsList({
    super.key,
    required this.tags,
    required this.onSelected,
    required this.selectedTagsContainsTag,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) {
        return FilterChip(
          backgroundColor: Colors.white,
          label: Text(tag["name"]!),
          selected: selectedTagsContainsTag?.call(tag["name"]!) ?? false,
          selectedColor: AppColors.primaryButtonColor.withOpacity(0.3),
          onSelected: (selected) => onSelected!(selected, tag["name"]!, tag["classification"]!)
        );
      }).toList(),
    );
  }
}
