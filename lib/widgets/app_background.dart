import 'package:flutter/material.dart';

// Dışarıdan aldığı imagePath'i arka plan olarak ayarlayan widget.
class AppBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const AppBackground({
    super.key,
    required this.child,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.15)),
        child,
      ],
    );
  }
}
