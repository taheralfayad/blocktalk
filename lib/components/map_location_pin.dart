import 'package:flutter/material.dart';

class LocationPin extends StatelessWidget {
  final Function onTap;

  const LocationPin({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          width: 36.0,
          height: 36.0,
          child: Center(
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
          ),
        ), 
    );
  }
}