import 'package:flutter/material.dart';

import '../design-system/button.dart';
import '../design-system/colors.dart';
import '../design-system/text.dart';
import '../components/navbar.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  
  List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Single Family',
    'Multi Family',
    'Commercial',
    'Industrial',
    'Construction Started',
    'Construction Completed',
    'Lot For Sale',
    'Lot Sold',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

void _showTagSelector() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: BlockTalkText(
              text: "Select Tags",
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _availableTags.map((tag) {
                      return FilterChip(
                        backgroundColor: Colors.white,
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        selectedColor: AppColors.primaryButtonColor.withOpacity(0.3),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                          setStateDialog(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                top: true,
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlockTalkText(
                        text: "Add Entry",
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8),
                      BlockTalkText(
                        text: "Share what you found and help others stay informed",
                        fontSize: 16.0,
                      ),
                      SizedBox(height: 24),
                      
                      BlockTalkText(
                        text: "Title",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Enter a descriptive title',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Location Field
                      BlockTalkText(
                        text: "Location",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: 'Enter Location',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                      SizedBox(height: 8),
                      BlockTalkButton(
                        text: "Get Current Location",
                        type: "outline",
                        buttonColor: AppColors.primaryButtonColor,
                        onPressed: () {
                          print("Getting current location...");
                        },
                      ),
                      SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BlockTalkText(
                            text: "Tags",
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          TextButton.icon(
                            onPressed: _showTagSelector,
                            icon: Icon(Icons.add, size: 18),
                            label: Text("Add Tags"),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (_selectedTags.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _selectedTags.map((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryButtonColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryButtonColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: TextStyle(
                                        color: AppColors.primaryButtonColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _removeTag(tag),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.primaryButtonColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.label_outline, 
                                     color: Colors.grey.shade400, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  "No tags selected",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Tap 'Add Tags' to categorize your entry",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      
                      // Description Field
                      BlockTalkText(
                        text: "Description",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        onTapOutside: (event) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        decoration: InputDecoration(
                          labelText: 'What did you find? Provide details...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: BlockTalkButton(
                          text: "Submit Entry",
                          type: "solid",
                          buttonColor: AppColors.primaryButtonColor,
                          onPressed: () {
                            print("Entry submitted:");
                            print("Title: ${_titleController.text}");
                            print("Location: ${_locationController.text}");
                            print("Description: ${_descriptionController.text}");
                            print("Tags: $_selectedTags");
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Navbar(selectedIndex: 2),
          ],
        ),
      ),
    );
  }
}