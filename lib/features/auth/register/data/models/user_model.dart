class UserModel {
  final String name;
  final String email;
  final String password;
  final String cpf;
  final String cnpj;
  final String type;
  final String title;
  final String phone;
  final bool termsAccepted;
  final String? photoPath;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    required this.cnpj,
    required this.type,
    required this.title,
    required this.phone,
    required this.termsAccepted,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'cnpj': cnpj,
      'type': type,
      'title': title,
      'phone': phone,
      'terms_accepted': termsAccepted,
    };
  }
}