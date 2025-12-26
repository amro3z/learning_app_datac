import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubit/learn_cubit.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/route.dart';
import 'package:training/services/network_service.dart';
import 'package:training/widgets/network_guard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NetworkService.startListening();

  final learnCubit = LearnCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice()),
  );

  runApp(
    BlocProvider<LearnCubit>(
      create: (_) => learnCubit,
      child: MyApp(appRoute: AppRoute(learnCubit: learnCubit)),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRoute appRoute;

  const MyApp({super.key, required this.appRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      onGenerateRoute: appRoute.generateRoute,
      builder: (context, child) {
        return NetworkGuard(
          child: child!,
          onRetry: () {
            context.read<LearnCubit>().getAllCourses();
          },
        );
      },
    );
  }
}
