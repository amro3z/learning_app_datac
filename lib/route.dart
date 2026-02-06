import 'package:flutter/material.dart';
import 'package:training/screen/course_details.dart';
import 'package:training/screen/home.dart';
import 'package:training/screen/login.dart';
import 'package:training/screen/profile_page.dart';
import 'package:training/screen/register_screen.dart';

class AppRoute {

  AppRoute();
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case '/course_details':
        return MaterialPageRoute(builder: (_) => CourseDetails());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
