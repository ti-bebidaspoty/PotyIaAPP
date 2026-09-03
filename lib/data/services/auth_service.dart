import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:poty_ia_app/data/models/login_request_model.dart';
import 'package:poty_ia_app/data/models/login_response_model.dart';
import 'package:poty_ia_app/data/services/api_service.dart';
import 'package:poty_ia_app/data/services/prefs.dart';

class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? ApiService.dio;

  Future<LoginResponseModel> login({

    required String cpf,

    required String dataNascimento,

  }) async {


    final request = LoginRequestModel(

      cpf: cpf.replaceAll(
          RegExp(r'[^0-9]'),
          ''
      ),

      dataNascimento:
      dataNascimento.replaceAll(
          RegExp(r'[^0-9]'),
          ''
      ),

    );


    final payload = request.toJson();



    if(kDebugMode){

      debugPrint(
          '========== LOGIN =========='
      );

      debugPrint(
          'URL: ${ApiService.baseUrl}/Autenticacao'
      );


      debugPrint(
          'CPF informado: '
              '${request.cpf.length == 11}'
      );


      debugPrint(
          'Senha informada: '
              '${request.dataNascimento.isNotEmpty}'
      );


      debugPrint(
          'JSON: ${jsonEncode({

            'Usuario':request.cpf,

            'Senha':'********'

          })}'
      );


    }



    try {


      final response =
      await _dio.post<dynamic>(

        '/Autenticacao',

        data:payload,

        options:Options(

          extra:{

            'requiresAuth':false

          },

        ),

      );



      final responseData =
      _convertResponseToMap(
        response.data,
      );



      final loginResponse =
      LoginResponseModel.fromJson(
        responseData,
      );



      if(loginResponse.accessToken.isEmpty){

        throw const FormatException(
            'A API não retornou AccessToken.'
        );

      }



      await Prefs.saveString(
        'accessToken',
        loginResponse.accessToken,
      );



      await Prefs.saveString(
        'refreshToken',
        loginResponse.refreshToken,
      );



      await Prefs.saveString(
        'usuarioId',
        loginResponse.usuario.usuarioId,
      );



      await Prefs.saveString(
        'usuarioNome',
        loginResponse.usuario.nome,
      );



      if(loginResponse.refreshTokenExpiraEm!=null){

        await Prefs.saveString(

          'refreshTokenExpiraEm',

          loginResponse
              .refreshTokenExpiraEm!
              .toIso8601String(),

        );

      }



      return loginResponse;



    }

    catch(error){

      rethrow;

    }


  }

  Map<String, dynamic> _convertResponseToMap(
      dynamic data,
      ) {
    if (data == null) {
      throw const FormatException(
        'A API retornou uma resposta vazia.',
      );
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String) {
      if (data.trim().isEmpty) {
        throw const FormatException(
          'A API retornou um texto vazio.',
        );
      }

      final decoded = jsonDecode(data);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw FormatException(
        'A API retornou um JSON que não é um objeto: $decoded',
      );
    }

    throw FormatException(
      'Tipo de resposta não esperado: ${data.runtimeType}. '
          'Conteúdo recebido: $data',
    );
  }

  String _safeResponseForLog(dynamic data) {
    if (data is Map) {
      final safeMap = Map<String, dynamic>.from(data);

      if (safeMap.containsKey('AccessToken')) {
        final token = safeMap['AccessToken']?.toString() ?? '';

        safeMap['AccessToken'] = token.isEmpty
            ? ''
            : '${token.substring(0, token.length > 15 ? 15 : token.length)}...';
      }

      return jsonEncode(safeMap);
    }

    return data.toString();
  }

  Future<void> logout() async {
    await Prefs.deleteAll();
  }

  Future<bool> isAuthenticated() async {
    final accessToken =
    await Prefs.getString('accessToken');

    return accessToken != null && accessToken.isNotEmpty;
  }
}