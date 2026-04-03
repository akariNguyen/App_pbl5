import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/core/language/language_cubit.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  String _label(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      case 'zh':
        return '中文';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  IconData _icon(String code) {
    switch (code) {
      case 'en':
        return Icons.language;
      case 'vi':
        return Icons.translate;
      case 'zh':
        return Icons.translate;
      case 'fr':
        return Icons.translate;
      default:
        return Icons.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const languages = ['en', 'vi', 'zh', 'fr'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, currentLocale) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: languages.map((code) {
                    final selected = currentLocale.languageCode == code;

                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(_icon(code)),
                          title: Text(_label(code)),
                          trailing: selected
                              ? Icon(Icons.check, color: scheme.primary)
                              : null,
                          onTap: () async {
                            await context.read<LanguageCubit>().setLanguage(code);
                          },
                        ),
                        if (code != languages.last)
                          Divider(height: 1, color: scheme.outlineVariant),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}