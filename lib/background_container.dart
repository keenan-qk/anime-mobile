import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/background.jpg',
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
