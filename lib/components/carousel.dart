import 'package:flutter/material.dart';

class Carousel extends StatelessWidget {
  final List<Widget> items;
  final double height;
  final double viewportFraction;

  const Carousel({
    super.key,
    required this.items,
    this.height = 100.0,
    this.viewportFraction = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: PageView(
        controller: PageController(viewportFraction: viewportFraction),
        children: items,
      )
    );
  }
}