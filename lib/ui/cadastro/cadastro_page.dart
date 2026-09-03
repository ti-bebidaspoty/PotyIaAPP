import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/routes/app_routes.dart';
import 'package:poty_ia_app/ui/cadastro/cadastro_controller.dart';
import 'package:poty_ia_app/ui/core/formatters/cpf_input_formatter.dart';
import 'package:video_player/video_player.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  late final VideoPlayerController _videoController;
  bool _videoInitialized = false;
  bool _videoFailed = false;

  CadastroController get controller => Get.find<CadastroController>();

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/paty.mp4');
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.play();
      if (mounted) setState(() => _videoInitialized = true);
    } catch (_) {
      if (mounted) setState(() => _videoFailed = true);
    }
  }

  Future<void> _register() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!await controller.criarUsuario() || !mounted) return;

    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Cadastro realizado'),
        content: const Text(
          'Use seu CPF como usuario e sua data de nascimento como senha, sem barras, no formato ddMMaaaa.',
        ),
        actions: [
          FilledButton(onPressed: Get.back, child: const Text('Entendi')),
        ],
      ),
      barrierDismissible: false,
    );
    if (mounted) Get.back();
  }

  InputDecoration _fieldDecoration() {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      hintText: 'Digite seu CPF',
      hintStyle: const TextStyle(color: _CadastroColors.fieldHint),
      filled: true,
      fillColor: _CadastroColors.fieldSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: const Icon(
        Icons.person_outline,
        color: _CadastroColors.brandGreen,
      ),
      border: border(_CadastroColors.fieldBorder, 1),
      enabledBorder: border(_CadastroColors.fieldBorder, 1.2),
      focusedBorder: border(_CadastroColors.brandGreen, 2),
      errorBorder: border(_CadastroColors.error, 1.4),
      focusedErrorBorder: border(_CadastroColors.error, 2),
      errorStyle: const TextStyle(color: _CadastroColors.error),
    );
  }

  Widget _video() {
    if (_videoFailed) {
      return const ColoredBox(
        color: _CadastroColors.videoBackground,
        child: Center(
          child: Icon(Icons.videocam_off_outlined, color: Colors.white70),
        ),
      );
    }
    if (!_videoInitialized || !_videoController.value.isInitialized) {
      return const ColoredBox(
        color: _CadastroColors.videoBackground,
        child: Center(
          child: CircularProgressIndicator(color: _CadastroColors.lime),
        ),
      );
    }
    final size = _videoController.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(_videoController),
      ),
    );
  }

  Widget _form(BuildContext context, {required bool desktop}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(desktop ? 34 : 26),
      decoration: BoxDecoration(
        color: _CadastroColors.formCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _CadastroColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _CadastroColors.logoBorder,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/poty.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'BEBIDAS POTY',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _CadastroColors.textStrong,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Criar cadastro',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _CadastroColors.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Informe seu CPF para criar o seu acesso.',
              style: TextStyle(color: _CadastroColors.fieldHint),
            ),
            const SizedBox(height: 24),
            Text(
              'CPF *',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _CadastroColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.cpfController,
              validator: controller.validarCpf,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [const CpfInputFormatter()],
              onFieldSubmitted: (_) => _register(),
              style: const TextStyle(
                color: _CadastroColors.fieldText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: _fieldDecoration(),
            ),
            const SizedBox(height: 28),
            Obx(
              () => SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: controller.isLoading.value ? null : _register,
                  style: FilledButton.styleFrom(
                    backgroundColor: _CadastroColors.brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Criar cadastro'),
                            SizedBox(width: 10),
                            Icon(Icons.person_add_alt_1_outlined),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.offNamed(AppRoutes.login),
              child: const Text('Ja possui cadastro? Entrar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CadastroColors.backgroundDark,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _CadastroColors.backgroundTop,
              _CadastroColors.backgroundMiddle,
              _CadastroColors.backgroundBottom,
            ],
            stops: [0, .58, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = kIsWeb && constraints.maxWidth >= 900;
              final form = _form(context, desktop: desktop);
              if (desktop) {
                const larguraMaximaPainel = 1440.0;
                const paddingExterno = 32.0;
                const paddingInternoVideo = 24.0;
                const flexVideo = 14.0;
                const flexFormulario = 8.0;

                final larguraPainel = math.min(
                  constraints.maxWidth - (paddingExterno * 2),
                  larguraMaximaPainel,
                );
                final larguraVideo =
                    larguraPainel * (flexVideo / (flexVideo + flexFormulario));
                final proporcaoVideo =
                    _videoController.value.isInitialized &&
                        _videoController.value.aspectRatio > 0
                    ? _videoController.value.aspectRatio
                    : 16 / 9;
                final alturaPainel = math.max(
                  520.0,
                  ((larguraVideo - (paddingInternoVideo * 2)) /
                          proporcaoVideo) +
                      (paddingInternoVideo * 2),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(paddingExterno),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 64),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: SizedBox(
                          height: alturaPainel,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _CadastroColors.desktopShell,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    blurRadius: 54,
                                    offset: const Offset(0, 26),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 14,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(26),
                                        child: _video(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: ColoredBox(
                                      color: _CadastroColors.desktopAccessArea,
                                      child: Center(
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(38),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 440,
                                            ),
                                            child: form,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _CadastroColors.videoBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _video(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      form,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

abstract final class _CadastroColors {
  static const backgroundTop = Color(0xFF0C2117);
  static const backgroundMiddle = Color(0xFF174126);
  static const backgroundBottom = Color(0xFF466B28);
  static const backgroundDark = Color(0xFF0C2117);
  static const desktopShell = Color(0xFFF1F5EC);
  static const desktopAccessArea = Color(0xFFDDE9D5);
  static const videoBackground = Color(0xFF09110D);
  static const formCard = Color(0xFFF6F8F2);
  static const cardBorder = Color(0xFFBFD0B5);
  static const brandGreen = Color(0xFF174126);
  static const lime = Color(0xFFB6CC45);
  static const textStrong = Color(0xFF173020);
  static const fieldSurface = Color(0xFFFFFFFF);
  static const fieldBorder = Color(0xFFB8C8B2);
  static const fieldText = Color(0xFF173020);
  static const fieldHint = Color(0xFF7B897B);
  static const logoBorder = Color(0xFFD1DDCB);
  static const error = Color(0xFFC6433D);
}
