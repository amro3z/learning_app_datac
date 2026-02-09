part of '../cubit/enrollments_cubit.dart';

@immutable
sealed class EnrollmentsState {}

final class EnrollmentsInitial extends EnrollmentsState {}

final class EnrollmentsLoading extends EnrollmentsState {}

final class EnrollmentsLoaded extends EnrollmentsState {
  final List<EnrollmentModel> enrollments;
  final List<CoursesModel> courses;
  EnrollmentsLoaded({required this.enrollments , required this.courses});
}

class EnrollmentsSubmitting extends EnrollmentsState {}

final class EnrollmentsError extends EnrollmentsState {
  final String message;

  EnrollmentsError({required this.message});
}
