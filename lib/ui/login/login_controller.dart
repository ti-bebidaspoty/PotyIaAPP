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



  final cpfController = TextEditingController();

  final nascimentoController = TextEditingController();



  final isLoading = false.obs;

  final senhaOculta = true.obs;



  String? validarCpf(String? value) {

    if(value == null || value.trim().isEmpty){

      return 'Informe o CPF.';

    }


    final cpf = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );


    if(cpf.length != 11){

      return 'CPF deve possuir 11 números.';

    }


    return null;

  }



  String? validarNascimento(String? value) {

    if(value == null || value.trim().isEmpty){

      return 'Informe a senha.';

    }


    final data = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );


    if(data.length != 8){

      return 'Informe no formato ddMMyyyy.';

    }


    return null;

  }



  void alterarVisibilidadeSenha(){

    senhaOculta.toggle();

  }




  Future<void> login() async {


    if(isLoading.value){

      return;

    }



    final cpf =
    cpfController.text.trim();



    final senha =
    nascimentoController.text.trim();



    try {


      isLoading.value = true;



      debugPrint(
          '========== INICIANDO LOGIN =========='
      );


      debugPrint(
          'CPF informado: ${cpf.isNotEmpty}'
      );


      debugPrint(
          'Senha nascimento informada: '
              '${senha.isNotEmpty}'
      );


      debugPrint(
          '======================================'
      );



      final resultado =
      await _authService.login(

        cpf: cpf,

        dataNascimento: senha,

      );



      debugPrint(
          '========== LOGIN CONCLUÍDO =========='
      );


      debugPrint(
          'Usuário ID: '
              '${resultado.usuario.usuarioId}'
      );


      debugPrint(
          'Nome: '
              '${resultado.usuario.nome}'
      );


      debugPrint(
          'Token recebido: '
              '${resultado.accessToken.isNotEmpty}'
      );


      debugPrint(
          'RefreshToken recebido: '
              '${resultado.refreshToken.isNotEmpty}'
      );


      debugPrint(
          '====================================='
      );



      FocusManager.instance.primaryFocus?.unfocus();



      Get.offAllNamed(
        AppRoutes.home,
      );



    } catch(error, stackTrace){



      debugPrint(
          '========== ERRO NO LOGIN =========='
      );


      debugPrint(
          'Tipo: ${error.runtimeType}'
      );


      debugPrint(
          'Erro: $error'
      );



      if(error is DioException){

        debugPrint(
          ApiService.getDetailedError(error),
        );

      }



      debugPrintStack(
        stackTrace: stackTrace,
      );


      debugPrint(
          '==================================='
      );



      final mensagem =
      ApiService.getErrorMessage(error);



      Get.snackbar(

        'Erro no login',

        mensagem,


        snackPosition:
        SnackPosition.BOTTOM,


        margin:
        const EdgeInsets.all(16),


        duration:
        const Duration(seconds:6),


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
  void onClose(){

    cpfController.dispose();

    nascimentoController.dispose();


    super.onClose();

  }


}