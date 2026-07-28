class LoginRequestModel {
  final String usuario;
  final String senha;

  const LoginRequestModel({
    required this.usuario,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'Usuario': usuario,
      'Senha': senha,
    };
  }
}