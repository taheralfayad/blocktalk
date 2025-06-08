import 'package:flutter/material.dart';


class ContributorsCircle extends StatelessWidget {
  const ContributorsCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      // Make sure the width fits all your circles plus the overlap
      width: 90, // 3 circles with 20px overlap each
      child: Stack(
        children: [
          Positioned(left: 0, child: IndividualCircle()),
          Positioned(left: 20, child: IndividualCircle()), // overlaps by 20px
          Positioned(left: 40, child: IndividualCircle()),
        ],
      ),
    );
  }
}

class IndividualCircle extends StatelessWidget {
  const IndividualCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20.0,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 30.0,
      ),
    );
  }
}