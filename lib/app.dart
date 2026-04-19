import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orchid_classifier/classifier/cubit/classifier_cubit.dart';
import 'package:orchid_classifier/classifier/models/classifier_repository.dart';
import 'package:orchid_classifier/classifier/page/classifier_page.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';

import 'core/theme/app_theme.dart';


class OrchidApp extends StatelessWidget {
  const OrchidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ClassifierRepository(),
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (_) => ClassifierCubit(
              repository: context.read<ClassifierRepository>(),
              historyRepository: context.read<HistoryRepository>(),
            ),
            child: MaterialApp(
              title: 'Orchid Classifier',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: const ClassifierPage(),
            ),
          );
        },
      ),
    );
  }
}