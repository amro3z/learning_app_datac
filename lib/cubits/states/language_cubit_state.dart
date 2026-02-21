class LanguageCubitState {}

final class LanguageCubitInitial extends LanguageCubitState {}

final class LanguageCubitLoading extends LanguageCubitState {}

final class LanguageCubitLoaded extends LanguageCubitState {
  final String languageCode;

  LanguageCubitLoaded({required this.languageCode});
}

final class LanguageCubitError extends LanguageCubitState {
  final String message;

  LanguageCubitError({required this.message});
}
