import 'package:flutter/material.dart';

import '../design-system/colors.dart';

class TagsList extends StatelessWidget {
  final List<String> tags;
  final Function(bool, String, String)? onSelected;
  final bool Function(String)? selectedTagsContainsTag;
  final String classification;

  const TagsList({
    super.key,
    required this.tags,
    required this.onSelected,
    required this.selectedTagsContainsTag,
    required this.classification
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) {
        return FilterChip(
          backgroundColor: Colors.white,
          label: Text(tag),
          selected: selectedTagsContainsTag?.call(tag) ?? false,
          selectedColor: AppColors.primaryButtonColor.withOpacity(0.3),
          onSelected: (selected) => onSelected!(selected, tag, classification)
        );
      }).toList(),
    );
  }
}
