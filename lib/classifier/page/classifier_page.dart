import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orchid_classifier/classifier/cubit/classifier_cubit.dart';
import 'package:orchid_classifier/classifier/widgets/classify_button.dart';
import 'package:orchid_classifier/classifier/widgets/error_card.dart';
import 'package:orchid_classifier/classifier/widgets/image_preview.dart';
import 'package:orchid_classifier/classifier/widgets/orchid_info_card.dart';
import 'package:orchid_classifier/classifier/widgets/pick_buttons.dart';
import 'package:orchid_classifier/classifier/widgets/result_card.dart';

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
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
                    onEdit: state.imageFile != null && !state.isLoading
                        ? () => context.read<ClassifierCubit>().cropCurrentImage()
                        : null,
                    onDetect: state.imageFile != null && !state.isLoading
                        ? () => context.read<ClassifierCubit>().detectCurrentImage()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  PickButtons(
                    onCamera: () {
                      context.read<ClassifierCubit>().pickImage(ImageSource.camera);
                    },
                    onGallery: () {
                      context.read<ClassifierCubit>().pickImage(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 12),

                  ClassifyButton(
                    enabled: state.imageFile != null && !state.isLoading,
                    loading: state.isLoading,
                    onPressed: () {
                      context.read<ClassifierCubit>().classify();
                    },
                  ),
                  const SizedBox(height: 20),

                  if (state.errorMessage != null)
                    ErrorCard(message: state.errorMessage!),

                  if (state.response != null) ...[
                    ResultCard(response: state.response!),
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