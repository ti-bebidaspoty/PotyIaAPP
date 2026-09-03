import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/routes/app_routes.dart';
import 'package:poty_ia_app/ui/core/formatters/cpf_input_formatter.dart';
import 'package:poty_ia_app/ui/login/login_controller.dart';
import 'package:video_player/video_player.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final VideoPlayerController _videoController;

  bool _videoInicializado = false;
  bool _erroNoVideo = false;

  LoginController get controller => Get.find<LoginController>();

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/paty.mp4');

    _inicializarVideo();
  }

  Future<void> _inicializarVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);

      if (!mounted) {
        return;
      }

      setState(() {
        _videoInicializado = true;
      });

      await _videoController.play();
    } catch (error, stackTrace) {
      debugPrint('Erro ao carregar o vídeo do login: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _erroNoVideo = true;
      });
    }
  }

  Future<void> _enviarLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final formularioValido = _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    await controller.login();
  }

  InputDecoration _decorationCampo({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _LoginColors.fieldHint,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: _LoginColors.fieldSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: Icon(icon, color: _LoginColors.brandGreen, size: 21),
      suffixIcon: suffixIcon,
      border: border(_LoginColors.fieldBorder, 1),
      enabledBorder: border(_LoginColors.fieldBorder, 1.2),
      focusedBorder: border(_LoginColors.brandGreen, 2),
      errorBorder: border(_LoginColors.error, 1.4),
      focusedErrorBorder: border(_LoginColors.error, 2),
      errorStyle: const TextStyle(
        color: _LoginColors.error,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _labelCampo(BuildContext context, String texto) {
    return Row(
      children: [
        Text(
          texto,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: _LoginColors.textStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '*',
          style: TextStyle(
            color: _LoginColors.brandGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _conteudoVideo({required BoxFit fit}) {
    if (_erroNoVideo) {
      return const ColoredBox(
        color: _LoginColors.videoBackground,
        child: Center(
          child: Icon(
            Icons.videocam_off_outlined,
            color: Colors.white70,
            size: 44,
          ),
        ),
      );
    }

    if (!_videoInicializado || !_videoController.value.isInitialized) {
      return const ColoredBox(
        color: _LoginColors.videoBackground,
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: _LoginColors.lime,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    final tamanhoVideo = _videoController.value.size;

    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: tamanhoVideo.width,
        height: tamanhoVideo.height,
        child: VideoPlayer(_videoController),
      ),
    );
  }

  Widget _buildVideoCompacto() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _LoginColors.videoBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _conteudoVideo(fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildPainelVideoWeb() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_LoginColors.videoPanelTop, _LoginColors.videoPanelBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _VideoPanelArtwork(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: _LoginColors.videoBackground,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.34),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _conteudoVideo(fit: BoxFit.cover),
                    const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00000000),
                              Color(0x05000000),
                              Color(0x24000000),
                            ],
                            stops: [0, 0.70, 1],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCabecalhoLogin(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _LoginColors.logoBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/poty.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.business_rounded,
                  color: _LoginColors.brandGreen,
                  size: 34,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'BEBIDAS POTY',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _LoginColors.textStrong,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulario(BuildContext context, {bool webDesktop = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        webDesktop ? 34 : 26,
        webDesktop ? 34 : 28,
        webDesktop ? 34 : 26,
        webDesktop ? 32 : 26,
      ),
      decoration: BoxDecoration(
        color: _LoginColors.formCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _LoginColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: webDesktop ? 0.12 : 0.18),
            blurRadius: webDesktop ? 28 : 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCabecalhoLogin(context),
              SizedBox(height: webDesktop ? 32 : 28),
              _labelCampo(context, 'CPF'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.cpfController,
                validator: controller.validarCpf,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.number,
                inputFormatters: const [CpfInputFormatter()],
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).nextFocus();
                },
                style: const TextStyle(
                  color: _LoginColors.fieldText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _decorationCampo(
                  hint: 'Digite seu CPF',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 20),
              _labelCampo(context, 'Senha'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.nascimentoController,
                validator: controller.validarNascimento,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                autofillHints: const [AutofillHints.birthday],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _enviarLogin();
                },
                style: const TextStyle(
                  color: _LoginColors.fieldText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _decorationCampo(
                  hint: 'Digite sua Senha',
                  icon: Icons.lock,
                ),
              ),
              SizedBox(height: webDesktop ? 30 : 28),
              Obx(
                () => SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: controller.isLoading.value ? null : _enviarLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: _LoginColors.brandGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _LoginColors.brandGreen
                          .withValues(alpha: 0.45),
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.75,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              key: ValueKey('button'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offNamed(AppRoutes.cadastro),
                child: const Text('Ainda nao possui cadastro? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutWebDesktop(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    const larguraMaximaPainel = 1440.0;
    const paddingExterno = 32.0;
    const paddingInternoVideo = 24.0;
    const flexVideo = 14.0;
    const flexFormulario = 8.0;

    final larguraDisponivel = math.max(
      0.0,
      constraints.maxWidth - (paddingExterno * 2),
    );

    final larguraPainel = math.min(larguraDisponivel, larguraMaximaPainel);

    final larguraColunaVideo =
        larguraPainel * (flexVideo / (flexVideo + flexFormulario));

    final larguraUtilVideo = math.max(
      0.0,
      larguraColunaVideo - (paddingInternoVideo * 2),
    );

    final proporcaoVideo =
        _videoController.value.isInitialized &&
            _videoController.value.aspectRatio > 0
        ? _videoController.value.aspectRatio
        : 16 / 9;

    final alturaIdealPeloVideo =
        (larguraUtilVideo / proporcaoVideo) + (paddingInternoVideo * 2);

    final alturaPainel = math.max(520.0, alturaIdealPeloVideo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
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
                    color: _LoginColors.desktopShell,
                    borderRadius: BorderRadius.circular(34),
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
                      Expanded(flex: 14, child: _buildPainelVideoWeb()),
                      Expanded(
                        flex: 8,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: _LoginColors.desktopAccessArea,
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(38),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 440,
                                ),
                                child: _buildFormulario(
                                  context,
                                  webDesktop: true,
                                ),
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

  Widget _buildLayoutCompacto(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final telaPequena = constraints.maxWidth < 420;

    final espacamentoHorizontal = telaPequena ? 16.0 : 24.0;

    final espacamentoVertical = constraints.maxHeight < 720 ? 16.0 : 28.0;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(
        horizontal: espacamentoHorizontal,
        vertical: espacamentoVertical,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(
            0,
            constraints.maxHeight - (espacamentoVertical * 2),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVideoCompacto(),
                SizedBox(height: telaPequena ? 18 : 24),
                _buildFormulario(context),
              ],
            ),
          ),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: _LoginColors.backgroundDark,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _LoginColors.backgroundTop,
              _LoginColors.backgroundMiddle,
              _LoginColors.backgroundBottom,
            ],
            stops: [0, 0.58, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BackgroundArtwork(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final usarLayoutWebDesktop =
                      kIsWeb && constraints.maxWidth >= 900;

                  if (usarLayoutWebDesktop) {
                    return _buildLayoutWebDesktop(context, constraints);
                  }

                  return _buildLayoutCompacto(context, constraints);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundArtwork extends StatelessWidget {
  const _BackgroundArtwork();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -210,
            right: -180,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.045),
              ),
            ),
          ),
          Positioned(
            left: -250,
            bottom: -330,
            child: Container(
              width: 650,
              height: 650,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _LoginColors.lime.withValues(alpha: 0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPanelArtwork extends StatelessWidget {
  const _VideoPanelArtwork();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -120,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
          ),
          Positioned(
            left: -170,
            bottom: -210,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _LoginColors.lime.withValues(alpha: 0.055),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract final class _LoginColors {
  static const backgroundTop = Color(0xFF0C2117);
  static const backgroundMiddle = Color(0xFF174126);
  static const backgroundBottom = Color(0xFF466B28);
  static const backgroundDark = Color(0xFF0C2117);

  static const desktopShell = Color(0xFFF1F5EC);
  static const desktopAccessArea = Color(0xFFDDE9D5);

  static const videoPanelTop = Color(0xFF102C1D);
  static const videoPanelBottom = Color(0xFF315B2C);
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
