import 'package:flutter/material.dart';

import '../design-system/colors.dart';
import '../design-system/text.dart';

import '../components/navbar.dart';
import '../components/contributers_circle.dart';
import '../components/banner.dart';
import '../components/comment.dart';
import '../components/add_comment.dart';


class EntryPage extends StatefulWidget {
  final String? blockId;
  const EntryPage({super.key, this.blockId});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  String loremIpsum = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam blandit tortor mauris, in sagittis lectus condimentum quis. Nulla non elit nec sapien aliquet porttitor. Mauris ut ullamcorper massa. Vestibulum sodales purus ut purus porttitor, vitae sagittis leo cursus. Sed at posuere quam, non ornare ipsum. Vestibulum sollicitudin, urna malesuada porttitor dictum, sapien sem finibus metus, ut rhoncus metus dui non turpis. Quisque lacinia tortor sit amet odio scelerisque, ut scelerisque metus malesuada. Nam in metus et nisi sodales sodales. Vestibulum mollis lobortis neque, ac vulputate dui mollis a. Sed condimentum eu lectus vel aliquet. Nunc sollicitudin placerat odio, id mattis nisi pharetra quis. Mauris finibus malesuada ex.
    Vestibulum sed dolor felis. Praesent nec tellus blandit, semper sem egestas, scelerisque tortor. Suspendisse porta tortor blandit dui efficitur, vel feugiat sapien posuere. Phasellus dictum felis nec libero ultrices, vitae scelerisque justo placerat. Etiam sed sapien convallis nunc viverra egestas. In molestie molestie mattis. Cras molestie nunc eget erat hendrerit, id ornare odio porttitor. Maecenas feugiat, diam non pulvinar rutrum, magna dolor congue arcu, a pharetra ligula orci vitae neque. Nunc non dapibus purus, eget fringilla elit. Aenean a faucibus nisl, id placerat dui. Etiam laoreet auctor massa, et bibendum risus tristique et. Etiam elementum dignissim mi et volutpat. Phasellus sit amet ipsum lobortis, vulputate libero vel, aliquet nulla.
    Cras in leo ultricies, dapibus ligula vel, semper nisl. Praesent eu iaculis lorem. Nullam non est eget velit vehicula maximus. Nam ac nunc leo. Nullam molestie neque nec enim fermentum, non bibendum ligula ultrices. Praesent fringilla accumsan ornare. Aenean orci eros, cursus pulvinar nunc sit amet, consectetur finibus velit. Suspendisse faucibus, leo ac pellentesque aliquet, mauris lacus porttitor turpis, id accumsan dui nisl eget nulla. Morbi ullamcorper fringilla neque, a dapibus elit aliquet vel. Nulla lacus lorem, rhoncus non tempus et, volutpat at ante. Pellentesque nisl metus, accumsan ac suscipit sed, fermentum et velit. Mauris non dolor ex. Curabitur scelerisque fringilla risus in ultricies.
  """;

  void initState() {
    print("EntryPage initialized with blockId: ${widget.blockId}");
    super.initState();
    // You can initialize any data or state here if needed
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
                left: false,
                right: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ContributorsCircle(),
                          BlockTalkText(
                            text: "15 Contributors",
                            fontSize: 14.0,
                          )
                        ]
                      ),
                      SizedBox(height: 12),
                      BlockTalkText(
                        text: "Construction on Alafaya and Colonial",
                        fontSize: 24.0,
                      ),
                      SizedBox(height: 8),
                      BlockTalkText(
                        text: loremIpsum,
                        fontSize: 16.0,
                      ),
                      SizedBox(height: 8),
                      BlockTalkBanner(
                        text: "Conversation"
                      ),
                      SizedBox(height: 8),
                      AddComment(),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            if (index % 2 == 0) {
                              if (index == 2) {
                                return Comment(
                                  text: "This is a comment to try out replies",
                                  author: "@taher",
                                  classification: "Conversation",
                                  replies: [
                                    Comment(
                                      text: "This is a reply to the comment above",
                                      author: "@dgwn",
                                      classification: "Conversation",
                                      replies: [],
                                    ),
                                    Comment(
                                      text: "This is another reply to the comment above",
                                      author: "@taher",
                                      classification: "Conversation",
                                    )
                                  ],
                                );
                              }
                              return Comment(
                                text: "This is a sample comment text for index $index. It can be a bit longer to simulate real comments.",
                                author: "@dgwn",
                                classification: "Source",
                              );   
                            } else {
                              return Comment(
                                text: "This is another sample comment text for index $index. It can also be a bit longer to simulate real comments.",
                                author: "@taher",
                                classification: "Conversation"
                              );
                            }
                          }
                      )
                    ],
                  ),
                ),
              ),
            ),
            Navbar(selectedIndex: 0),
          ],
        ),
      ),
    );
  }
}
