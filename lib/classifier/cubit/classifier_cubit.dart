import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orchid_classifier/classifier/data/models/classifier_repository.dart';

import '../data/models/classify_response.dart';

part 'classifier_state.dart';

class ClassifierCubit extends Cubit<ClassifierState> {
  ClassifierCubit({required this.repository}) : super(const ClassifierState());

  final ClassifierRepository repository;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (xFile == null) return;

      final file = File(xFile.path);

      if (!await file.exists()) {
        emit(
          state.copyWith(
            errorMessage: 'Không thể truy cập ảnh vừa chọn. Vui lòng thử lại.',
            clearError: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          imageFile: file,
          response: null,
          orchidInfo: null,
          errorMessage: null,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage:
              'Không thể chọn ảnh: ${e.toString().replaceFirst('Exception: ', '')}',
          clearError: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Lỗi không xác định khi chọn ảnh. Vui lòng thử lại.',
          clearError: false,
        ),
      );
    }
  }

  Future<void> cropCurrentImage() async {
    final currentImage = state.imageFile;

    if (currentImage == null) {
      emit(
        state.copyWith(errorMessage: 'Chưa có ảnh để cắt.', clearError: false),
      );
      return;
    }

    if (!await currentImage.exists()) {
      emit(
        state.copyWith(
          imageFile: null,
          response: null,
          orchidInfo: null,
          errorMessage:
              'Ảnh hiện tại không còn tồn tại. Vui lòng chọn lại ảnh.',
          isLoading: false,
          clearError: false,
        ),
      );
      return;
    }

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: currentImage.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 95,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh',
            toolbarColor: const Color(0xFF111827),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF111827),
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFFFFC107),
            
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),

          IOSUiSettings(
            title: 'Cắt ảnh',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioPickerButtonHidden: false,
          ),
        ],
      );

      if (cropped == null) return;

      final croppedFile = File(cropped.path);

      emit(
        state.copyWith(
          imageFile: croppedFile,
          response: null,
          orchidInfo: null,
          errorMessage: null,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage:
              'Không thể cắt ảnh: ${e.toString().replaceFirst('Exception: ', '')}',
          clearError: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Lỗi không xác định khi cắt ảnh.',
          clearError: false,
        ),
      );
    }
  }

  Future<void> classify() async {
    final imageFile = state.imageFile;
    if (imageFile == null) return;

    if (!await imageFile.exists()) {
      emit(
        state.copyWith(
          imageFile: null,
          response: null,
          orchidInfo: null,
          errorMessage: 'File ảnh không còn tồn tại. Vui lòng chọn lại ảnh.',
          isLoading: false,
          clearError: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        response: null,
        orchidInfo: null,
        errorMessage: null,
      ),
    );

    try {
      final response = await repository.classifyImage(imageFile);

      final topClassId = response.results.isNotEmpty
          ? response.results.first.classId
          : -1;

      final info = topClassId >= 0
          ? await repository.loadOrchidInfoByClassId(topClassId)
          : null;

      emit(
        state.copyWith(
          isLoading: false,
          response: response,
          orchidInfo: info,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          clearError: false,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
