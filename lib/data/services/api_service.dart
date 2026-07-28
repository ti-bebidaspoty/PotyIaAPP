import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/data/services/prefs.dart';
import 'package:poty_ia_app/routes/app_routes.dart';

class ApiService {
  static const String baseUrl =
      'https://potyiaapi.bebidaspoty.com.br/api';

  static bool _redirecionandoParaLogin = false;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {

        final requiresAuth =
            options.extra['requiresAuth'] != false;

        if (requiresAuth) {
          final accessToken =
          await Prefs.getString('accessToken');

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] =
            'Bearer $accessToken';
          }
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        final requiresAuth =
            error.requestOptions.extra['requiresAuth'] != false;

        if (error.response?.statusCode == 401 && requiresAuth) {
          await _handleUnauthorized();
        }

        final apiMessage = _extractApiMessage(
          error.response?.data,
        );

        if (apiMessage != null && apiMessage.isNotEmpty) {
          error = error.copyWith(message: apiMessage);
        }

        return handler.next(error);
      },
    ),
  );

  static Dio get dio => _dio;

  static Future<void> _handleUnauthorized() async {
    if (_redirecionandoParaLogin) {
      return;
    }

    _redirecionandoParaLogin = true;

    try {
      await Prefs.deleteAll();

      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      Future<void>.delayed(
        const Duration(milliseconds: 500),
            () {
          _redirecionandoParaLogin = false;
        },
      );
    }
  }

  static String? _extractApiMessage(dynamic data) {
    if (data is Map) {
      const possibleKeys = [
        'Resposta',
        'Mensagem',
        'Message',
        'message',
        'title',
      ];

      for (final key in possibleKeys) {
        final value = data[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return null;
  }

  static String getErrorMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final possibleMessages = [
          responseData['Resposta'],
          responseData['Mensagem'],
          responseData['Message'],
          responseData['message'],
          responseData['title'],
          responseData['detail'],
        ];

        for (final message in possibleMessages) {
          if (message != null &&
              message.toString().trim().isNotEmpty) {
            return message.toString();
          }
        }

        final errors = responseData['errors'];

        if (errors != null) {
          return errors.toString();
        }
      }

      if (responseData is String &&
          responseData.trim().isNotEmpty) {
        return responseData;
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'A conexão com a API excedeu o tempo limite.';

        case DioExceptionType.sendTimeout:
          return 'O envio dos dados excedeu o tempo limite.';

        case DioExceptionType.receiveTimeout:
          return 'A API demorou demais para responder.';

        case DioExceptionType.connectionError:
          return 'Não foi possível conectar à API. '
              'Verifique internet, DNS, certificado e endereço do servidor.';

        case DioExceptionType.badCertificate:
          return 'O certificado HTTPS da API não foi aceito.';

        case DioExceptionType.cancel:
          return 'A requisição foi cancelada.';

        case DioExceptionType.badResponse:
          return 'A API retornou o status HTTP '
              '${error.response?.statusCode}. '
              'Resposta: ${error.response?.data}';

        case DioExceptionType.unknown:
          return 'Erro desconhecido do Dio: '
              '${error.message ?? error.error}';
        case DioExceptionType.transformTimeout:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }

    if (error is FormatException) {
      return 'Erro ao interpretar a resposta da API: '
          '${error.message}';
    }

    return 'Erro do tipo ${error.runtimeType}: $error';
  }

  static String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Os dados enviados são inválidos.';

      case 401:
        return 'Usuário ou senha inválidos.';

      case 403:
        return 'Você não possui permissão para esta operação.';

      case 404:
        return 'O recurso solicitado não foi encontrado.';

      case 500:
        return 'O servidor encontrou um erro interno.';

      default:
        return 'Não foi possível concluir a solicitação.';
    }
  }

  static String getDetailedError(DioException error) {
    final request = error.requestOptions;
    final response = error.response;

    final details = StringBuffer();

    details.writeln('Tipo do erro: ${error.type}');
    details.writeln('Mensagem do Dio: ${error.message}');
    details.writeln('Método: ${request.method}');
    details.writeln('URL: ${request.uri}');
    details.writeln('Status HTTP: ${response?.statusCode ?? 'sem resposta'}');

    details.writeln(
      'Content-Type: ${response?.headers.value('content-type') ?? 'não informado'}',
    );

    details.writeln(
      'Resposta da API: ${response?.data ?? 'nenhuma resposta'}',
    );

    if (error.error != null) {
      details.writeln('Erro interno: ${error.error}');
    }

    return details.toString();
  }
}