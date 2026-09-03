import 'package:poty_ia_app/data/models/usuario_model.dart';


class LoginResponseModel {

  final String accessToken;
  final String refreshToken;
  final DateTime? refreshTokenExpiraEm;
  final UsuarioModel usuario;


  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiraEm,
    required this.usuario,
  });


  factory LoginResponseModel.fromJson(
      Map<String,dynamic> json
      ){

    final usuarioJson = json['Usuario'];


    if(usuarioJson is! Map){
      throw const FormatException(
        'A resposta não possui usuário válido.',
      );
    }


    return LoginResponseModel(

      accessToken:
      json['AccessToken']?.toString() ?? '',


      refreshToken:
      json['RefreshToken']?.toString() ?? '',


      refreshTokenExpiraEm:
      json['RefreshTokenExpiraEm'] != null
          ?
      DateTime.tryParse(
        json['RefreshTokenExpiraEm']
            .toString(),
      )
          :
      null,


      usuario:
      UsuarioModel.fromJson(
        Map<String,dynamic>.from(
          usuarioJson,
        ),
      ),

    );

  }


  Map<String,dynamic> toJson(){

    return {

      'AccessToken':
      accessToken,

      'RefreshToken':
      refreshToken,

      'RefreshTokenExpiraEm':
      refreshTokenExpiraEm
          ?.toIso8601String(),

      'Usuario':
      usuario.toJson(),

    };

  }

}