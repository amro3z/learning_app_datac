import 'package:flutter/material.dart';
import 'package:training/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRoute _appRoute = AppRoute();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Training App',
      theme: ThemeData.dark(),
      onGenerateRoute: _appRoute.generateRoute,
      initialRoute: '/home',
    );
  }
}
