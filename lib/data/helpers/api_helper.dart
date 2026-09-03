import 'package:dio/dio.dart';
import 'package:poty_ia_app/data/models/response_model.dart';

class ApiHelper {
  static Future<ResponseModel<T>> request<T>(Future<Response> Function() request, {required T Function(dynamic data) fromJson}) async {
    try {
      final res = await request();
      final data = res.data;
      final parsed = fromJson(data);

      return Success(parsed);
    } on DioException catch (e) {
      return Failure(
        errorMessage: _extractMsg(e) ?? 'Erro de comunicação com o servidor',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(errorMessage: 'Erro inesperado: $e');
    }
  }

  static String? _extractMsg(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        return msg;
      }
    }

    if (data is String && data.isNotEmpty) return data;

    return e.message;
  }
}