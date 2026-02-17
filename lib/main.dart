import 'package:firebase_core/firebase_core.dart';
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
import 'package:training/cubits/states/user_state.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/firebase_options.dart';
import 'package:training/route.dart';
import 'package:training/services/tokens/auths_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  final webService = LearningWebservice();
  final repo = LearningRepo(learningWebService: webService);

  final userCubit = UserCubit();
  await userCubit.restoreSession();

  final enrollmentsCubit = EnrollmentsCubit(
    learningRepo: repo,
    webservice: webService,
  );

  final favoritesCubit = FavoritesCubit(repo: repo, webservice: webService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => userCubit..restoreSession()),

        BlocProvider(create: (_) => enrollmentsCubit),
        BlocProvider(create: (_) => favoritesCubit),

        BlocProvider(
          create: (_) => CoursesCubit(learningRepo: repo)..getAllCourses(),
        ),

        BlocProvider(
          create: (_) =>
              CategoriesCubit(learningRepo: repo)..getAllCategories(),
        ),

        BlocProvider(
          create: (_) =>
              RecommendedCubit(learningRepo: repo)..getRecommendedList(),
        ),

        BlocProvider(
          create: (_) => PopularCubit(learningRepo: repo)..getPopularList(),
        ),

        BlocProvider(
          create: (_) =>
              LessonsCubit(repo: repo, enrollmentsCubit: enrollmentsCubit)
                ..getLessons(),
        ),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserInitial) {
          context.read<EnrollmentsCubit>().clear();
          context.read<FavoritesCubit>().clear();
        }

        if (state is UserLoaded) {
          final userId = context.read<UserCubit>().userId;
          if (userId != null) {
            context.read<EnrollmentsCubit>().getAllEnrollments(userId: userId);

            context.read<FavoritesCubit>().getFavoritesList(userId: userId);
          }
        }
      },
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: '/login',
        onGenerateRoute: AppRoute().generateRoute,
      ),
    );
  }
}
