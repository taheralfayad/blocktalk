import 'package:flutter/material.dart';

class LocationDisplay extends StatelessWidget {
  final String locationName;
  final double iconSize;
  final TextStyle? textStyle;

  const LocationDisplay({
    super.key,
    required this.locationName,
    this.iconSize = 80.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          color: const Color.fromARGB(255, 0, 0, 0),
          size: iconSize,
        ),
        SizedBox(height: 8),
        Text(
          locationName,
          style: textStyle ??
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
