import 'package:poty_ia_app/data/models/usuario_model.dart';

class LoginResponseModel {
  final String accessToken;
  final UsuarioModel usuario;

  const LoginResponseModel({
    required this.accessToken,
    required this.usuario,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final usuarioJson = json['Usuario'];

    if (usuarioJson is! Map) {
      throw const FormatException(
        'A resposta da API não contém um usuário válido.',
      );
    }

    return LoginResponseModel(
      accessToken: json['AccessToken']?.toString() ?? '',
      usuario: UsuarioModel.fromJson(
        Map<String, dynamic>.from(usuarioJson),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccessToken': accessToken,
      'Usuario': usuario.toJson(),
    };
  }
}