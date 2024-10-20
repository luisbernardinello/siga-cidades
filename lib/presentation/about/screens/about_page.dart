import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'About page provisória',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
