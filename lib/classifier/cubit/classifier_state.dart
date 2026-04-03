part of 'classifier_cubit.dart';

class ClassifierState extends Equatable {
  final File? imageFile;
  final ClassifyResponse? response;
  final String? orchidInfo;
  final List<String> exampleImages;
  final bool isLoading;
  final String? errorMessage;

  const ClassifierState({
    this.imageFile,
    this.response,
    this.orchidInfo,
    this.exampleImages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClassifierState copyWith({
    File? imageFile,
    ClassifyResponse? response,
    String? orchidInfo,
    List<String>? exampleImages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClassifierState(
      imageFile: imageFile ?? this.imageFile,
      response: response,
      orchidInfo: orchidInfo,
      exampleImages: exampleImages ?? this.exampleImages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    imageFile?.path,
    response,
    orchidInfo,
    exampleImages,
    isLoading,
    errorMessage,
  ];
}