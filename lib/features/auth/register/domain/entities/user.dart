class User {
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final String academicProfile;
  final String? photoPath;

  User({
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    required this.academicProfile,
    this.photoPath,
  });
}