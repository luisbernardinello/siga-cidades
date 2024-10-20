import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  static const routeName = '/feedback';

  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Feedback page provisória',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
