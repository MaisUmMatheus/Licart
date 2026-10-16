class AppUser {
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }
}
