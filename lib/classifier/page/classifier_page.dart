import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orchid_classifier/classifier/cubit/classifier_cubit.dart';
import 'package:orchid_classifier/classifier/widgets/classify_button.dart';
import 'package:orchid_classifier/classifier/widgets/error_card.dart';
import 'package:orchid_classifier/classifier/widgets/example_images_card.dart';
import 'package:orchid_classifier/classifier/widgets/image_preview.dart';
import 'package:orchid_classifier/classifier/widgets/orchid_info_card.dart';
import 'package:orchid_classifier/classifier/widgets/pick_buttons.dart';
import 'package:orchid_classifier/classifier/widgets/result_card.dart';
import 'package:orchid_classifier/setting/settings_page.dart';

class ClassifierPage extends StatelessWidget {
  const ClassifierPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        title: const Text(
          'Orchid Classifier',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ClassifierCubit, ClassifierState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImagePreview(
                    imageFile: state.imageFile,
                    isAnalyzing: state.isLoading,
                    onEdit: state.imageFile != null && !state.isLoading
                        ? () => context.read<ClassifierCubit>().cropCurrentImage()
                        : null,
                  ),
                  const SizedBox(height: 16),
                  PickButtons(
                    onCamera: () {
                      context.read<ClassifierCubit>().pickImage(
                        ImageSource.camera,
                      );
                    },
                    onGallery: () {
                      context.read<ClassifierCubit>().pickImage(
                        ImageSource.gallery,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (state.imageFile != null) ...[
                    // Nút 1: Detect & Classify (Làm tất cả mọi thứ)
                    FilledButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context
                              .read<ClassifierCubit>()
                              .detectAndClassifyCurrentImage(),
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label:
                          Text(state.isLoading ? 'Đang xử lý...' : 'Nhận dạng Thần Tốc (Detect & Classify)'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Nút 2: Detect (Cắt ảnh)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () => context
                                    .read<ClassifierCubit>()
                                    .detectCurrentImage(),
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Khoanh vùng hoa'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: scheme.primary, width: 2),
                              foregroundColor: scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Nút 3: Classify (Phân loại từ ảnh gốc hoặc crop)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () => context
                                    .read<ClassifierCubit>()
                                    .classify(),
                            icon: const Icon(Icons.search),
                            label: Text(state.cropId != null
                                ? 'Phân loại (Crop)'
                                : 'Phân loại (Gốc)'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (state.errorMessage != null)
                    ErrorCard(message: state.errorMessage!),
                  if (state.isLoading && state.imageFile != null) ...[
                    const ResultCardShimmer(),
                  ] else if (state.response != null) ...[
                    ResultCard(
                      response: state.response!,
                      imageFile: state.imageFile,
                    ),
                    if (state.exampleImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ExampleImagesCard(
                        title: state.response!.topClass,
                        imagePaths: state.exampleImages,
                      ),
                    ],
                    if (state.orchidInfo != null) ...[
                      const SizedBox(height: 12),
                      OrchidInfoCard(
                        title: state.response!.topClass,
                        content: state.orchidInfo!,
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}