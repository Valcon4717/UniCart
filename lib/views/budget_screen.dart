import 'package:flutter/material.dart';

/// This is the BudgetScreen widget, which is currently under development.
/// The functionality and design of this screen are planned to be completed in the future.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Screen'),
      ),
      body: Center(
        child: Text(
          'Budget',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
