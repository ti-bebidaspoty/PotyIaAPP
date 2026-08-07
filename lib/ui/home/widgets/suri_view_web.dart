import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class SuriView extends StatefulWidget {
  const SuriView({super.key});

  @override
  State<SuriView> createState() => _SuriViewState();
}

class _SuriViewState extends State<SuriView> {
  late final JSFunction _messageListener;

  web.HTMLIFrameElement? _iframe;

  Timer? _timeout;
  Timer? _fallbackTimer;

  int _iframeVersion = 0;

  bool _carregando = true;
  bool _iframeCriado = false;

  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _registrarListener();
  }

  void _registrarListener() {
    _messageListener = ((web.Event event) {
      if (event is! web.MessageEvent) {
        return;
      }

      final data = event.data.dartify();

      if (data is! String || !mounted) {
        return;
      }

      debugPrint(
        'Mensagem recebida do iframe da Suri: $data',
      );

      if (data == 'POTY_SURI_READY') {
        _marcarChatComoCarregado();
        return;
      }

      const prefixoErro = 'POTY_SURI_ERROR:';

      if (data.startsWith(prefixoErro)) {
        final mensagem = data
            .substring(prefixoErro.length)
            .trim();

        _mostrarErro(
          mensagem.isEmpty
              ? 'O SDK da Suri retornou um erro.'
              : mensagem,
        );
      }
    }).toJS;

    web.window.addEventListener(
      'message',
      _messageListener,
    );
  }

  void _configurarIframe(Object element) {
    final iframe =
    element as web.HTMLIFrameElement;

    _iframe = iframe;
    _iframeCriado = true;

    iframe.style
      ..width = '100%'
      ..height = '100%'
      ..border = '0'
      ..margin = '0'
      ..padding = '0'
      ..display = 'block'
      ..overflow = 'hidden'
      ..background = '#EAF2E2'
      ..backgroundColor = '#EAF2E2';

    iframe.setAttribute(
      'title',
      'Paty - Assistente Virtual',
    );

    iframe.setAttribute(
      'allowtransparency',
      'true',
    );

    iframe.setAttribute(
      'scrolling',
      'no',
    );

    iframe.setAttribute(
      'allow',
      [
        'microphone',
        'clipboard-read',
        'clipboard-write',
      ].join('; '),
    );

    iframe.setAttribute(
      'src',
      'suri.html'
          '?platform=web'
          '&v=${DateTime.now().millisecondsSinceEpoch}'
          '&tentativa=$_iframeVersion',
    );

    debugPrint(
      'Iframe da Suri criado. '
          'Tentativa: $_iframeVersion',
    );

    _iniciarTimeout();
    _iniciarFallback();
  }

  void _iniciarTimeout() {
    _timeout?.cancel();

    _timeout = Timer(
      const Duration(seconds: 30),
          () {
        if (!mounted || !_carregando) {
          return;
        }

        _mostrarErro(
          'O chatbot demorou mais de 30 segundos '
              'para iniciar.',
        );
      },
    );
  }

  void _iniciarFallback() {
    _fallbackTimer?.cancel();

    _fallbackTimer = Timer(
      const Duration(seconds: 8),
          () {
        if (!mounted ||
            !_carregando ||
            !_iframeCriado ||
            _mensagemErro != null) {
          return;
        }

        debugPrint(
          'Fallback acionado: exibindo o iframe da Suri.',
        );

        _marcarChatComoCarregado();
      },
    );
  }

  void _marcarChatComoCarregado() {
    _timeout?.cancel();
    _fallbackTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _carregando = false;
      _mensagemErro = null;
    });

    debugPrint(
      'Tela do chatbot da Suri liberada.',
    );
  }

  void _mostrarErro(String mensagem) {
    _timeout?.cancel();
    _fallbackTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _carregando = false;
      _mensagemErro = mensagem;
    });

    debugPrint(
      'Erro ao carregar a Suri: $mensagem',
    );
  }

  void _tentarNovamente() {
    _timeout?.cancel();
    _fallbackTimer?.cancel();

    setState(() {
      _iframeVersion++;

      _iframe = null;
      _iframeCriado = false;

      _carregando = true;
      _mensagemErro = null;
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _fallbackTimer?.cancel();

    web.window.removeEventListener(
      'message',
      _messageListener,
    );

    _iframe = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _SuriBackground(),

        Positioned.fill(
          child: HtmlElementView.fromTagName(
            key: ValueKey(
              'suri-iframe-$_iframeVersion',
            ),
            tagName: 'iframe',
            onElementCreated: _configurarIframe,
          ),
        ),

        if (_carregando)
          const Positioned.fill(
            child: _SuriLoading(),
          ),

        if (!_carregando &&
            _mensagemErro != null)
          Positioned.fill(
            child: _SuriError(
              mensagem: _mensagemErro!,
              onRetry: _tentarNovamente,
            ),
          ),
      ],
    );
  }
}

class _SuriBackground extends StatelessWidget {
  const _SuriBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _SuriColors.lightBackgroundTop,
            _SuriColors.lightBackground,
            _SuriColors.lightBackgroundBottom,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _SuriOverlayShell extends StatelessWidget {
  final Widget child;

  const _SuriOverlayShell({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _SuriBackground(),
        IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -170,
                right: -120,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _SuriColors.lime.withValues(
                      alpha: 0.07,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -190,
                bottom: -220,
                child: Container(
                  width: 470,
                  height: 470,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _SuriColors.forest.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuriLoading extends StatelessWidget {
  const _SuriLoading();

  @override
  Widget build(BuildContext context) {
    return _SuriOverlayShell(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 430,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            32,
            34,
            32,
            30,
          ),
          decoration: BoxDecoration(
            color: _SuriColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _SuriColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: _SuriColors.deepest.withValues(
                  alpha: 0.13,
                ),
                blurRadius: 38,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _SuriColors.forest,
                      _SuriColors.olive,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _SuriColors.limeSoft.withValues(
                      alpha: 0.55,
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _SuriColors.forest.withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const _PatyLoadingVideo(),
              ),
              const SizedBox(height: 25),
              Text(
                'Carregando a Paty...',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  color: _SuriColors.textStrong,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preparando seu atendimento.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: _SuriColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _SuriColors.forest,
                ),
              ),
              const SizedBox(height: 19),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: _SuriColors.textMuted,
                  ),
                  SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Ambiente corporativo seguro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _SuriColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuriError extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _SuriError({
    required this.mensagem,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _SuriOverlayShell(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 450,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            32,
            34,
            32,
            30,
          ),
          decoration: BoxDecoration(
            color: _SuriColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _SuriColors.errorBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: _SuriColors.deepest.withValues(
                  alpha: 0.14,
                ),
                blurRadius: 38,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _SuriColors.errorSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _SuriColors.errorBorder,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: _SuriColors.error,
                ),
              ),
              const SizedBox(height: 23),
              Text(
                'Não foi possível abrir a Paty',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  color: _SuriColors.textStrong,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: _SuriColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: _SuriColors.forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Tentar novamente',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatyLoadingVideo extends StatelessWidget {
  const _PatyLoadingVideo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _SuriColors.deepest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _SuriColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _SuriColors.deepest.withValues(
              alpha: 0.18,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: _SuriColors.deepest,
            child: Image.asset(
              'assets/images/paty.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Center(
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: _SuriColors.limeSoft,
                    size: 56,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _SuriColors {
  static const deepest = Color(0xFF0C2117);
  static const forest = Color(0xFF174126);
  static const olive = Color(0xFF466B28);

  static const lime = Color(0xFFB6CC45);
  static const limeSoft = Color(0xFFD8E986);

  static const lightBackgroundTop = Color(0xFFE7F0DF);
  static const lightBackground = Color(0xFFEAF2E2);
  static const lightBackgroundBottom = Color(0xFFD9E8D0);

  static const surface = Color(0xFFF7F9F3);
  static const border = Color(0xFFC9D8C2);

  static const textStrong = Color(0xFF17301F);
  static const textMuted = Color(0xFF5F6F61);

  static const error = Color(0xFFB5473F);
  static const errorSurface = Color(0xFFFCEBE8);
  static const errorBorder = Color(0xFFEAC0BB);
}
