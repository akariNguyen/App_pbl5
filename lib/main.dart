import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/classifier/cubit/classifier_cubit.dart';
import 'package:orchid_classifier/classifier/data/models/classifier_repository.dart';
import 'package:orchid_classifier/classifier/page/classifier_page.dart';
import 'package:orchid_classifier/core/theme/app_theme.dart';
import 'package:orchid_classifier/core/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  runApp(MyApp(themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;

  const MyApp({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider(
          create: (_) => ClassifierCubit(
            repository: ClassifierRepository(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Orchid Classifier',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const ClassifierPage(),
          );
        },
      ),
    );
  }
}