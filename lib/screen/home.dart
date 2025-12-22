import 'package:flutter/material.dart';
import 'package:training/widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CourseCard(
            author: 'John Doe',
            title: 'Flutter Development',
            rating: 3,
            progress: 0.1,
            imagePath: 'assets/images/pro1.jpg',
          ),
        ),
      ),
    );
  }
}
