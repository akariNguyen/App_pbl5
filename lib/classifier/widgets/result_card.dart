import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orchid_classifier/classifier/data/models/class_result.dart';
import 'package:orchid_classifier/classifier/data/models/classify_response.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class ResultCard extends StatelessWidget {
  final ClassifyResponse response;
  final File? imageFile;

  const ResultCard({
    super.key,
    required this.response,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _TopResult(response: response)),
              if (imageFile != null)
                IconButton(
                  icon: Icon(Icons.ios_share, color: scheme.primary),
                  onPressed: () async {
                    final text = 'Tôi vừa nhận diện giống lan ${response.topClass} '
                        'với độ chính xác ${(response.topConfidence * 100).toStringAsFixed(1)}% '
                        'bằng ứng dụng Orchid Classifier. Các bác xem thử có chuẩn không nhé!';
                    await Share.shareXFiles(
                      [XFile(imageFile!.path)],
                      text: text,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'Top ${response.results.length} kết quả',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ...response.results.map((r) => _ConfidenceBar(result: r)),
          const SizedBox(height: 14),
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Inference: ${response.inferenceMs.toStringAsFixed(1)} ms',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopResult extends StatelessWidget {
  final ClassifyResponse response;

  const _TopResult({required this.response});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = (response.topConfidence * 100).toStringAsFixed(1);
    final isHighConf = response.topConfidence >= 0.7;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isHighConf
                ? scheme.primaryContainer
                : scheme.tertiaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHighConf ? Icons.check_circle : Icons.help_outline,
            color: isHighConf
                ? scheme.onPrimaryContainer
                : scheme.onTertiaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                response.topClass,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Độ tin cậy: $pct%',
                style: TextStyle(
                  fontSize: 14,
                  color: isHighConf ? scheme.primary : scheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final ClassResult result;

  const _ConfidenceBar({required this.result});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTop = result.rank == 1;
    final pct = (result.confidence * 100).toStringAsFixed(1);
    final barColor = isTop ? scheme.primary : scheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTop
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${result.rank}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isTop ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.className,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
                    color: isTop ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.confidence,
              minHeight: 7,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultCardShimmer extends StatelessWidget {
  const ResultCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.surfaceContainerHighest;
    final highlightColor = scheme.surfaceContainerHigh;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 12),
            Container(width: 120, height: 16, color: Colors.white),
            const SizedBox(height: 10),
            for (int i = 0; i < 3; i++) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 40, height: 14, color: Colors.white),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}