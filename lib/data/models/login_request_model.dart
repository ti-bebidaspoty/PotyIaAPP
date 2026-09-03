class LoginRequestModel {
  final String cpf;
  final String dataNascimento;

  const LoginRequestModel({
    required this.cpf,
    required this.dataNascimento,
  });


  Map<String, dynamic> toJson() {
    return {
      'CPF': cpf,
      'Senha': dataNascimento,
    };
  }
}