import 'package:flutter/material.dart';

class InstructorHome extends StatefulWidget {
  const InstructorHome({super.key});

  @override
  State<InstructorHome> createState() => _InstructorHomeState();
}

class _InstructorHomeState extends State<InstructorHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Instructor Home Screen!'),
      ),
    );
  }
}