import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassInfoTab extends StatelessWidget {
  final String classId;
  final String? content;

  const ClassInfoTab({
    super.key,
    required this.classId,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (content == null || content!.trim().isEmpty) {
      return Center(
        child: Text(
          'Chưa có thông tin cho $classId',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: MarkdownBody(
          data: content!,
          selectable: true,
          onTapLink: (text, href, title) async {
            if (href == null) return;
            final uri = Uri.parse(href);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        ),
      ),
    );
  }
}