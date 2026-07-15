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
  final String role;
  UserLoaded({
    required this.Fname,
    required this.Lname,
    required this.email,
    required this.role, 
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
    String? role,
  }) {
    return UserLoaded(
      Fname: Fname ?? this.Fname,
      Lname: Lname ?? this.Lname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isUploading: isUploading ?? this.isUploading,
      message: message,
      role: role ?? this.role,
    );
  }
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
