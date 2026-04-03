part of 'classifier_cubit.dart';

class ClassifierState extends Equatable {
  final File? imageFile;
  final ClassifyResponse? response;
  final String? orchidInfo;
  final bool isLoading;
  final String? errorMessage;

  const ClassifierState({
    this.imageFile,
    this.response,
    this.orchidInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  ClassifierState copyWith({
    File? imageFile,
    ClassifyResponse? response,
    String? orchidInfo,
    bool? isLoading,
    String? errorMessage,
    bool clearError = true,
  }) {
    return ClassifierState(
      imageFile: imageFile ?? this.imageFile,
      response: response,
      orchidInfo: orchidInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? (errorMessage ?? this.errorMessage)
          : errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    imageFile?.path,
    response,
    orchidInfo,
    isLoading,
    errorMessage,
  ];
}
