import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/popular_cubit.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/route.dart';
import 'package:training/services/tokens/auths_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  final learnCubit = CoursesCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice()),
  );
  final categoriesCubit = CategoriesCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice()),
  );
  final enrollmentsCubit = EnrollmentsCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice()),
    webservice: LearningWebservice(),
  );
  final recommendedCubit = RecommendedCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice()),
  );
  final popularCubit = PopularCubit(
    learningRepo: LearningRepo(learningWebService: LearningWebservice()),
  );
  final favoriteCubit = FavoritesCubit(
    repo: LearningRepo(learningWebService: LearningWebservice()),
    webservice: LearningWebservice(),
  );
  final lessonCubit = LessonsCubit(
    repo: LearningRepo(learningWebService: LearningWebservice()),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => learnCubit..getAllCourses()),
        BlocProvider(create: (_) => UserCubit()..restoreSession()),
        BlocProvider(create: (_) => categoriesCubit..getAllCategories()),
        BlocProvider(create: (_) => enrollmentsCubit..getAllEnrollments()),
        BlocProvider(create: (_) => recommendedCubit..getRecommendedList()),
        BlocProvider(create: (_) => popularCubit..getPopularList()),
        BlocProvider(create: (_) => favoriteCubit..getFavoritesList()),
        BlocProvider(create: (_) => lessonCubit..getLessons()),
      ],
      child: MyApp(appRoute: AppRoute()),
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
      initialRoute: '/login',
      onGenerateRoute: appRoute.generateRoute,
    );
  }
}
