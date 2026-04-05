import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/core/theme/theme_cubit.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  static const List<String> _themes = ['dark', 'light', 'pink', 'red', 'silver'];

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Sáng (Light)';
      case 'dark':
        return 'Tối (Klassic Dark)';
      case 'pink':
        return 'Hồng Mộng Mơ (Pink)';
      case 'red':
        return 'Đỏ Rực Rỡ (Red)';
      case 'silver':
        return 'Bạc Sang Trọng (Silver)';
      default:
        return mode;
    }
  }

  IconData _themeIcon(String mode) {
    switch (mode) {
      case 'light':
        return Icons.light_mode_outlined;
      case 'dark':
        return Icons.dark_mode_outlined;
      case 'pink':
        return Icons.favorite_border_rounded;
      case 'red':
        return Icons.local_fire_department_outlined;
      case 'silver':
        return Icons.diamond_outlined;
      default:
        return Icons.color_lens_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme / Giao diện'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: BlocBuilder<ThemeCubit, String>(
        builder: (context, currentMode) {
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
                  children: _themes.map((mode) {
                    final selected = currentMode == mode;

                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(_themeIcon(mode), color: selected ? scheme.primary : null),
                          title: Text(_themeLabel(mode), style: TextStyle(
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          )),
                          trailing: selected
                              ? Icon(Icons.check, color: scheme.primary)
                              : null,
                          onTap: () async {
                            await context.read<ThemeCubit>().setTheme(mode);
                          },
                        ),
                        if (mode != _themes.last)
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