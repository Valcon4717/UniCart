import 'package:flutter/material.dart';

class SplitScreen extends StatelessWidget {
  const SplitScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Pay'),
      ),
      body: Center(
        child: Text(
          'Split Pay',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}