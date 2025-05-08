import 'package:flutter/material.dart';

/// This is the SplitScreen widget, which is currently under development.
/// The functionality and design of this screen are planned to be completed in the future.
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