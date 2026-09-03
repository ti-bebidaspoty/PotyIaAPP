import 'package:dio/dio.dart';
import 'package:poty_ia_app/data/helpers/api_helper.dart';
import 'package:poty_ia_app/data/models/response_model.dart';
import 'package:poty_ia_app/data/services/api_service.dart';

class UsuarioService {
  final Dio _client = ApiService.dio;

  Future<ResponseModel<dynamic>> criar(String cpf) async {
    return ApiHelper.request<dynamic>(
          () => _client.post('/Usuario/$cpf'),
      fromJson: (data) => data,
    );
  }
}