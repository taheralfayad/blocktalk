import 'package:flutter/material.dart';

import '../design-system/vote_button.dart';
import '../design-system/colors.dart';

class UpvoteDownvote extends StatelessWidget {
  final String currentUserInteraction;
  final int upvotes;
  final int downvotes;
  final Function(String interactionType) voteEntry;
  final bool minified;

  const UpvoteDownvote({
    super.key,
    this.upvotes = 0,
    this.downvotes = 0,
    this.currentUserInteraction = "",
    this.minified = false,
    required this.voteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VoteButton(
          label: "Upvote",
          votes: upvotes,
          hasAlreadyVoted: currentUserInteraction == 'upvote',
          onPressed: (interactionType) {
            voteEntry(interactionType.toLowerCase());
          },
          icon: Icon(
            Icons.arrow_upward_rounded,
            color: currentUserInteraction == 'upvote'
                ? Colors.white
                : AppColors.primaryButtonColor,
          ),
          minified: minified
        ),
        VoteButton(
          label: "Downvote",
          votes: downvotes,
          hasAlreadyVoted: currentUserInteraction == 'downvote',
          onPressed: (interactionType) {
            voteEntry(interactionType.toLowerCase());
          },
          icon: Icon(
            Icons.arrow_downward_rounded,
            color: currentUserInteraction == 'downvote'
                ? Colors.white
                : AppColors.primaryButtonColor,
          ),
          minified: minified
        ),
      ],
    );
  }
}
