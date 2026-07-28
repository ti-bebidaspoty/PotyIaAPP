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
    required String usuario,
    required String senha,
  }) async {
    final request = LoginRequestModel(
      usuario: usuario.trim(),
      senha: senha,
    );

    final payload = request.toJson();

    if (kDebugMode) {
      debugPrint('================ LOGIN ================');
      debugPrint(
        'URL: ${ApiService.baseUrl}/Login',
      );
      debugPrint('MÉTODO: POST');
      debugPrint('USUÁRIO: ${payload['Usuario']}');
      debugPrint('SENHA INFORMADA: ${senha.isNotEmpty}');
      debugPrint('TAMANHO DA SENHA: ${senha.length}');
      debugPrint(
        'JSON ENVIADO: ${jsonEncode({
          'Usuario': payload['Usuario'],
          'Senha': '***',
        })}',
      );
      debugPrint('=======================================');
    }

    try {
      final response = await _dio.post<dynamic>(
        '/Autenticacao',
        data: payload,
        options: Options(
          extra: {
            'requiresAuth': false,
          },
        ),
      );

      if (kDebugMode) {
        debugPrint('======== RESPOSTA DO LOGIN ========');
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint(
          'TIPO DO RETORNO: ${response.data.runtimeType}',
        );
        debugPrint(
          'CABEÇALHOS: ${response.headers.map}',
        );
        debugPrint(
          'RESPOSTA: ${_safeResponseForLog(response.data)}',
        );
        debugPrint('===================================');
      }

      final responseData = _convertResponseToMap(
        response.data,
      );

      final loginResponse =
      LoginResponseModel.fromJson(responseData);

      if (loginResponse.accessToken.isEmpty) {
        throw const FormatException(
          'A API respondeu, mas o campo AccessToken está vazio.',
        );
      }

      if (kDebugMode) {
        debugPrint('AccessToken convertido com sucesso.');
        debugPrint(
          'Usuário retornado: ${loginResponse.usuario.nome}',
        );
      }

      await Prefs.saveString(
        'accessToken',
        loginResponse.accessToken,
      );

      if (kDebugMode) {
        debugPrint('AccessToken salvo no SharedPreferences.');
      }

      await Prefs.saveString(
        'usuarioId',
        loginResponse.usuario.usuarioId,
      );

      await Prefs.saveString(
        'usuarioNome',
        loginResponse.usuario.nome,
      );

      if (kDebugMode) {
        debugPrint('Dados do usuário salvos.');
        debugPrint('Login finalizado com sucesso.');
      }

      return loginResponse;
    } on DioException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('======== ERRO DIO NO LOGIN ========');
        debugPrint(
          ApiService.getDetailedError(error),
        );
        debugPrintStack(stackTrace: stackTrace);
        debugPrint('===================================');
      }

      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('====== ERRO INTERNO NO LOGIN ======');
        debugPrint('TIPO: ${error.runtimeType}');
        debugPrint('ERRO: $error');
        debugPrintStack(stackTrace: stackTrace);
        debugPrint('===================================');
      }

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