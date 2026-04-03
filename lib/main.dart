import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/classifier/cubit/classifier_cubit.dart';
import 'package:orchid_classifier/classifier/data/models/classifier_repository.dart';
import 'package:orchid_classifier/core/language/language_cubit.dart';
import 'package:orchid_classifier/core/theme/app_theme.dart';
import 'package:orchid_classifier/core/theme/theme_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orchid_classifier/home/main_navigation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  final languageCubit = LanguageCubit();
  await languageCubit.loadLanguage();

  runApp(MyApp(themeCubit: themeCubit, languageCubit: languageCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;
  final LanguageCubit languageCubit;

  const MyApp({
    super.key,
    required this.themeCubit,
    required this.languageCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider<LanguageCubit>.value(value: languageCubit),
        BlocProvider(
          create: (_) => ClassifierCubit(repository: ClassifierRepository()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Orchid Classifier',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('vi'),
                  Locale('zh'),
                  Locale('fr'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const MainNavigationPage(),
              );
            },
          );
        },
      ),
    );
  }
}