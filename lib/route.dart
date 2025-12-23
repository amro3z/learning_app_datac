import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubit/learn_cubit.dart';
import 'package:training/screen/home.dart';
import 'package:training/screen/login.dart';
import 'package:training/screen/register_screen.dart';

class AppRoute {
  final LearnCubit learnCubit;

  AppRoute({required this.learnCubit});
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/home':
      return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: learnCubit, 
            child: const HomeScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: HomeScreen() ,
          ),
        );
    }
  }
}
