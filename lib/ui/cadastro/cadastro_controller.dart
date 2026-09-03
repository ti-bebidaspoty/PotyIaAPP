import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/data/models/response_model.dart';
import 'package:poty_ia_app/data/services/usuario_service.dart';

class CadastroController extends GetxController {
  CadastroController({UsuarioService? usuarioService})
      : _usuarioService = usuarioService ?? UsuarioService();

  final UsuarioService _usuarioService;
  final cpfController = TextEditingController();
  final isLoading = false.obs;

  String? validarCpf(String? value) {
    final cpf = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';

    if (cpf.isEmpty) {
      return 'Informe o CPF.';
    }

    if (cpf.length != 11) {
      return 'CPF deve possuir 11 numeros.';
    }

    return null;
  }

  Future<bool> criarUsuario() async {
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;

    try {
      final cpf = cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final resposta = await _usuarioService.criar(cpf);

      if (resposta is Success<dynamic>) {
        return true;
      }

      final falha = resposta as Failure<dynamic>;
      Get.snackbar(
        'Cadastro nao realizado',
        falha.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    cpfController.dispose();
    super.onClose();
  }
}