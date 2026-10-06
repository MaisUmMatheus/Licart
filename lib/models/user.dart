class AppUser {
  final String email;
  final String name;
  final bool isAdmin;

  const AppUser({
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      email: map['email'] as String,
      name: map['name'] as String,
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }
}
