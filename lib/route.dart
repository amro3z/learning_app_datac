import 'package:flutter/material.dart';
import 'package:training/screen/course_details.dart';
import 'package:training/screen/home.dart';
import 'package:training/screen/lesson_screen.dart';
import 'package:training/screen/login.dart';
import 'package:training/screen/profile_page.dart';
import 'package:training/screen/register_screen.dart';
import 'package:training/screen/splash_screen.dart';

class AppRoute {
  AppRoute();
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case '/course_details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CourseDetails(
            imageURL: args['imageURL'],
            title: args['title'],
            instructor: args['instructor'],
            description: args['description'],
            courseId: args['courseId'] as int,
          ),
        );
      case '/lesson_screen':
       final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => LessonScreen(
          courseID: args['courseID'] as int,
          lessonID: args['lessonID'] as int,
          lessonTitle: args['lessonTitle'] ,
          lessonDescription: args['lessonDescription'],
          videoURl: args['videoURl'],
          courseTitle: args['courseTitle'],
          lessonDurationInSeconds: args['lessonDurationInSeconds'] as int,
        ));
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
