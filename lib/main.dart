import 'dart:ui'; // مهم علشان PlatformDispatcher

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:training/cubits/cubit/categories_cubit.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
import 'package:training/cubits/cubit/enrollments_cubit.dart';
import 'package:training/cubits/cubit/favorites_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/cubits/cubit/popular_cubit.dart';
import 'package:training/cubits/cubit/recommended_cubit.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/data/api/web_service.dart';
import 'package:training/data/local/sqldb.dart';
import 'package:training/data/repo/learning_repo.dart';
import 'package:training/firebase_options.dart';
import 'package:training/route.dart';
import 'package:training/services/err.dart';
import 'package:training/services/local_notifications.dart';
import 'package:training/services/network_service.dart';
import 'package:training/services/tokens/auths_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ================= MAIN =================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // placeholder علشان نقدر نغير runApp بعدين
  runApp(const SizedBox());

  // 🔥 Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorText = details.exceptionAsString();
    runApp(ErrorScreen(error: errorText));
  };

  // 🔥 async / platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    runApp(ErrorScreen(error: error.toString()));
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await AuthService().init();
    await LocalNotifications.init(navigatorKey);
    NetworkService.startListening();

    final webService = LearningWebservice();
    final repo = LearningRepo(learningWebService: webService, sqldb: Sqldb());

    final userCubit = UserCubit();
    final enrollmentsCubit = EnrollmentsCubit(
      learningRepo: repo,
      webservice: webService,
    );
    final favoritesCubit = FavoritesCubit(repo: repo, webservice: webService);

    runApp(
      RepositoryProvider.value(
        value: repo,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LanguageCubit()),
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
          child: const MyApp(),
        ),
      ),
    );

    // 🔥 notification permission بعد ما UI يشتغل
    Future.delayed(Duration.zero, () async {
      await LocalNotifications.flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    });
  } catch (e) {
    runApp(ErrorScreen(error: e.toString()));
  }
}

// ================= APP =================
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
      child: BlocBuilder<LanguageCubit, LanguageCubitState>(
        builder: (context, state) {
          String languageCode = 'en';

          if (state is LanguageCubitLoaded) {
            languageCode = state.languageCode;
          }

          final isArabic = languageCode == 'ar';

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            locale: Locale(languageCode),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
            themeMode: ThemeMode.dark,
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            initialRoute: '/splash',
            onGenerateRoute: AppRoute().generateRoute,
          );
        },
      ),
    );
  }
}
