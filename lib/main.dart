import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/courses_cubit.dart';
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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => learnCubit),
        BlocProvider(create: (_) => UserCubit()..restoreSession()),
      ],
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

      /// 👇 دول الاتنين لازم يكونوا مع بعض
      initialRoute: '/login',
      onGenerateRoute: appRoute.generateRoute,
    );
  }
}
