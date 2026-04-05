import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orchid_classifier/classifier/data/models/classifier_repository.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';

import '../data/models/classify_response.dart';

part 'classifier_state.dart';

class ClassifierCubit extends Cubit<ClassifierState> {
  ClassifierCubit({required this.repository, required this.historyRepository})
    : super(const ClassifierState());

  final ClassifierRepository repository;
  final HistoryRepository historyRepository;
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
          exampleImages: const [],
          errorMessage: null,
          isLoading: false,
          clearError: true,
          clearCropId: true,
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
          exampleImages: const [],
          errorMessage: null,
          isLoading: false,
          clearError: true,
          clearCropId: true,
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

  Future<void> detectCurrentImage() async {
    final currentImage = state.imageFile;

    if (currentImage == null) {
      emit(
        state.copyWith(
          errorMessage: 'Chưa có ảnh để detect.',
          clearError: false,
        ),
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

    emit(
      state.copyWith(
        isLoading: true,
        response: null,
        orchidInfo: null,
        exampleImages: const [],
        errorMessage: null,
        clearError: true,
      ),
    );

    try {
      final resultMap = await repository.detectAndCropImage(currentImage);

      emit(
        state.copyWith(
          imageFile: resultMap['file'] as File,
          cropId: resultMap['crop_id'] as String?,
          response: null,
          orchidInfo: null,
          exampleImages: const [],
          errorMessage: null,
          isLoading: false,
          clearError: true,
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
        exampleImages: const [],
        errorMessage: null,
        clearError: true,
      ),
    );

    try {
      final response = await repository.classifyImage(
          imageFile: state.cropId == null ? imageFile : null,
          cropId: state.cropId);

      final topClassId = response.results.isNotEmpty
          ? response.results.first.classId
          : -1;

      final info = topClassId >= 0
          ? await repository.loadOrchidInfoByClassId(topClassId)
          : null;

      final exampleImages = topClassId >= 0
          ? await repository.loadExampleImagesByClassId(topClassId, limit: 5)
          : <String>[];
      if (response.results.isNotEmpty && imageFile.existsSync()) {
        final top = response.results.first;

        await historyRepository.saveHistoryItem(
          sourceImageFile: imageFile,
          className: top.className,
          classId: top.classId,
          confidence: top.confidence,

          // thêm mấy field này để HistoryDetailPage có dữ liệu
          vietnameseName: top.className,
          scientificName: top.className,
          family: 'Orchidaceae',
          overview: info,
          identification: info,
          careGuide: info,
        );
      }
      emit(
        state.copyWith(
          isLoading: false,
          response: response,
          orchidInfo: info,
          exampleImages: exampleImages,
          errorMessage: null,
          clearError: true,
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
    emit(state.copyWith(clearError: true));
  }

  Future<void> detectAndClassifyCurrentImage() async {
    final currentImage = state.imageFile;

    if (currentImage == null) {
      emit(
        state.copyWith(
          errorMessage: 'Chưa có ảnh để detect và phân loại.',
          clearError: false,
        ),
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
          clearCropId: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        response: null,
        orchidInfo: null,
        exampleImages: const [],
        errorMessage: null,
        clearError: true,
      ),
    );

    try {
      final resultMap = await repository.detectAndClassify(currentImage);
      final croppedFile = resultMap['file'] as File;
      final cropId = resultMap['crop_id'] as String?;
      final response = resultMap['response'] as ClassifyResponse;

      final topClassId = response.results.isNotEmpty
          ? response.results.first.classId
          : -1;

      final info = topClassId >= 0
          ? await repository.loadOrchidInfoByClassId(topClassId)
          : null;

      final exampleImages = topClassId >= 0
          ? await repository.loadExampleImagesByClassId(topClassId, limit: 5)
          : <String>[];

      if (response.results.isNotEmpty && croppedFile.existsSync()) {
        final top = response.results.first;

        await historyRepository.saveHistoryItem(
          sourceImageFile: croppedFile,
          className: top.className,
          classId: top.classId,
          confidence: top.confidence,

          vietnameseName: top.className,
          scientificName: top.className,
          family: 'Orchidaceae',
          overview: info,
          identification: info,
          careGuide: info,
        );
      }

      emit(
        state.copyWith(
          isLoading: false,
          imageFile: croppedFile,
          cropId: cropId,
          response: response,
          orchidInfo: info,
          exampleImages: exampleImages,
          errorMessage: null,
          clearError: true,
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
}
