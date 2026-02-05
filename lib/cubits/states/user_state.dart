class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isUploading; 
  final String? message; 

  UserLoaded({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isUploading = false,
    this.message,
  });

  UserLoaded copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    bool? isUploading,
    String? message,
  }) {
    return UserLoaded(
      name: name ?? this.name,
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
