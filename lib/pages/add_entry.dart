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
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                            text: "What did you find and where did you find it?",
                            fontSize: 16.0,
                          ),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Location',
                                    border: OutlineInputBorder(),
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
                              // Handle adding location
                              print("Location added: ${_locationController.text}");
                            },
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
                            onTapOutside: (event) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                          ),
                          SizedBox(height: 16),
                          BlockTalkButton(
                            text: "Submit Entry",
                            type: "solid",
                            buttonColor: AppColors.primaryButtonColor,
                            onPressed: () {
                              // Handle submission
                              print("Entry submitted with location: ${_locationController.text} and description: ${_descriptionController.text}");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Navbar(selectedIndex: 2),
              ]
            )
          )
        );
    }
}