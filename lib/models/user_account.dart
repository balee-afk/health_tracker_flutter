class UserAccount {
  UserAccount({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  final int? id;
  final String name;
  final String email;
  final String password;

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
