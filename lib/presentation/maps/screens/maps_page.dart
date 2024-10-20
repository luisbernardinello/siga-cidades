import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  static const routeName = '/maps';

  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Maps page provisória',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
