import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubit/learn_cubit.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/route.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  final learnCubit = LearnCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice())
  )..getAllCourses(); 

  runApp(
    BlocProvider<LearnCubit>(
      create: (context) => learnCubit,
      child: MyApp(appRoute: AppRoute(learnCubit: learnCubit)),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required  this.appRoute}) ;
  final AppRoute appRoute;
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Training App',
      theme: ThemeData.dark(),
      onGenerateRoute: appRoute.generateRoute,
    );
  }
}
