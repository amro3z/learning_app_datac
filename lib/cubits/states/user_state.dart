class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoginSuccess extends UserState {}

class UserLoaded extends UserState {
  final String Fname;
  final String Lname;
  final String email;
  final String? avatarUrl;
  final bool isUploading;
  final String? message;

  UserLoaded({
    required this.Fname,
    required this.Lname,
    required this.email,
    this.avatarUrl,
    this.isUploading = false,
    this.message,
  });

  UserLoaded copyWith({
    String? Fname,
    String? Lname,
    String? email,
    String? avatarUrl,
    bool? isUploading,
    String? message,
  }) {
    return UserLoaded(
      Fname: Fname ?? this.Fname,
      Lname: Lname ?? this.Lname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isUploading: isUploading ?? this.isUploading,
      message: message,
    );
  }
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
