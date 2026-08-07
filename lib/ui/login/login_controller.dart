import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/data/services/api_service.dart';
import 'package:poty_ia_app/data/services/auth_service.dart';
import 'package:poty_ia_app/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _authService;

  LoginController({
    AuthService? authService,
  }) : _authService = authService ?? AuthService();

  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();

  final isLoading = false.obs;
  final senhaOculta = true.obs;

  String? validarUsuario(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o usuário.';
    }

    return null;
  }

  String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha.';
    }

    return null;
  }

  void alterarVisibilidadeSenha() {
    senhaOculta.toggle();
  }

  Future<void> login() async {
    if (isLoading.value) {
      return;
    }

    final usuario = usuarioController.text.trim();
    final senha = senhaController.text;

    try {
      isLoading.value = true;

      debugPrint('========== INICIANDO LOGIN ==========');
      debugPrint('Usuário informado: ${usuario.isNotEmpty}');
      debugPrint('====================================');

      final resultado = await _authService.login(
        usuario: usuario,
        senha: senha,
      );

      debugPrint('========== LOGIN CONCLUÍDO ==========');
      debugPrint(
        'Usuário ID: ${resultado.usuario.usuarioId}',
      );
      debugPrint(
        'Nome: ${resultado.usuario.nome}',
      );
      debugPrint(
        'Token recebido: '
            '${resultado.accessToken.isNotEmpty}',
      );
      debugPrint('=====================================');

      FocusManager.instance.primaryFocus?.unfocus();

      Get.offAllNamed(AppRoutes.home);
    } catch (error, stackTrace) {
      debugPrint('========== ERRO NO LOGIN ==========');
      debugPrint('Tipo: ${error.runtimeType}');
      debugPrint('Erro: $error');

      if (error is DioException) {
        debugPrint(
          ApiService.getDetailedError(error),
        );
      }

      debugPrintStack(stackTrace: stackTrace);
      debugPrint('===================================');

      final mensagem =
      ApiService.getErrorMessage(error);

      Get.snackbar(
        'Erro no login',
        mensagem,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
        backgroundColor:
        Get.theme.colorScheme.errorContainer,
        colorText:
        Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usuarioController.dispose();
    senhaController.dispose();

    super.onClose();
  }
}