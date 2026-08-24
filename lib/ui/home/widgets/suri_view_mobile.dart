import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';

class SuriSessionController {
  Future<void> Function()? _limparSessao;

  /// Mantém a mesma API pública da implementação Web para que a Home
  /// compile nas duas plataformas. No mobile, a limpeza da sessão da SURI
  /// já é feita diretamente pela WebView ao abrir/fechar a Paty.
  static Future<void> limparDadosNoLogout() async {
    debugPrint(
      'Logout mobile: limpeza Web específica não se aplica.',
    );
  }

  void _attach(Future<void> Function() limparSessao) {
    _limparSessao = limparSessao;
  }

  void _detach() {
    _limparSessao = null;
  }

  Future<void> limparSessao() async {
    final limpar = _limparSessao;

    if (limpar != null) {
      await limpar();
    }
  }
}

class SuriView extends StatefulWidget {
  final SuriSessionController? sessionController;

  const SuriView({
    super.key,
    this.sessionController,
  });

  @override
  State<SuriView> createState() => _SuriViewState();
}

class _SuriViewState extends State<SuriView> {
  static const String _suriUrl =
      'https://potyiasuri.bebidaspoty.com.br/suri.html';

  late final WebViewController _controller;

  final WebViewCookieManager _cookieManager = WebViewCookieManager();

  // Esta flag pertence somente a ESTA tela da Paty.
  // Ao fechar a Paty pelo X, o SuriView é destruído.
  // Na próxima abertura, um novo SuriView é criado e a flag volta para false,
  // fazendo cookies/cache/localStorage serem limpos antes de carregar o chat.
  bool _sessaoPreparadaNestaTela = false;

  bool _carregando = true;
  bool _chatPronto = false;

  int _progresso = 0;

  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    widget.sessionController?._attach(_limparSessaoCompleta);
    _configurarWebView();
  }

  @override
  void didUpdateWidget(covariant SuriView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionController != widget.sessionController) {
      oldWidget.sessionController?._detach();
      widget.sessionController?._attach(_limparSessaoCompleta);
    }
  }

  @override
  void dispose() {
    widget.sessionController?._detach();
    super.dispose();
  }

  Future<void> _configurarWebView() async {
    _controller = WebViewController(
      onPermissionRequest:
      defaultTargetPlatform == TargetPlatform.iOS
          ? (WebViewPermissionRequest request) async {
        final tiposSolicitados = request.types;

        debugPrint(
          'Permissão solicitada pela WebView iOS: '
              '${tiposSolicitados.map((tipo) => tipo.name).join(', ')}',
        );

        final solicitacaoValida =
            tiposSolicitados.isNotEmpty &&
                tiposSolicitados.every(
                      (tipo) =>
                  tipo ==
                      WebViewPermissionResourceType.camera ||
                      tipo ==
                          WebViewPermissionResourceType.microphone,
                );

        if (solicitacaoValida) {
          debugPrint(
            'Permissão da WebView concedida no iOS.',
          );

          await request.grant();
        } else {
          debugPrint(
            'Permissão desconhecida da WebView negada no iOS.',
          );

          await request.deny();
        }
      }
          : null,
    )
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setBackgroundColor(
        _SuriColors.lightBackground,
      )
      ..addJavaScriptChannel(
        'PotySuri',
        onMessageReceived: _receberMensagemJavaScript,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) {
              return;
            }

            setState(() {
              _carregando = true;
              _chatPronto = false;
              _progresso = 0;
              _mensagemErro = null;
            });

            debugPrint(
              'Iniciando página da Suri: $url',
            );
          },

          onProgress: (int progress) {
            if (!mounted) {
              return;
            }

            setState(() {
              _progresso = progress;
            });
          },

          onPageFinished: (String url) {
            debugPrint(
              'Página HTML da Suri carregada: $url',
            );
          },

          onWebResourceError: (
              WebResourceError error,
              ) {
            final isMainFrame =
                error.isForMainFrame ?? false;

            if (!isMainFrame) {
              debugPrint(
                'Erro secundário da WebView: '
                    '${error.description}',
              );

              return;
            }

            _mostrarErro(
              'Erro ao abrir a página da Paty: '
                  '${error.description}',
            );
          },

          onNavigationRequest: (
              NavigationRequest request,
              ) {
            debugPrint(
              'Navegação WebView: '
                  '${request.url}',
            );

            return NavigationDecision.navigate;
          },
        ),
      );

    /*
   * ============================================================
   * GEOLOCALIZAÇÃO NO ANDROID
   * ============================================================
   */

    if (defaultTargetPlatform == TargetPlatform.android &&
        _controller.platform is AndroidWebViewController) {
      final androidController =
      _controller.platform as AndroidWebViewController;

      // Habilita a API JavaScript de geolocalização no WebView.
      await androidController.setGeolocationEnabled(true);

      // Trata as solicitações de localização feitas pela página/SURI.
      await androidController
          .setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (
            GeolocationPermissionsRequestParams request,
            ) async {
          debugPrint(
            'Geolocalização solicitada por: ${request.origin}',
          );

          final uri = Uri.tryParse(request.origin);

          final host =
              uri?.host.toLowerCase() ?? '';

          /*
         * Só permitimos as origens utilizadas pelo Poty IA/SURI.
         */
          final origemPermitida =
              host == 'app.talkjs.com' ||
                  host.endsWith('.talkjs.com') ||
                  host == 'webchat.chatbotmaker.io' ||
                  host.endsWith('.chatbotmaker.io') ||
                  host == 'potyiasuri.bebidaspoty.com.br';

          if (!origemPermitida) {
            debugPrint(
              'Geolocalização NEGADA para origem não autorizada: '
                  '${request.origin}',
            );

            return const GeolocationPermissionsResponse(
              allow: false,
              retain: false,
            );
          }

          /*
         * Verifica a permissão do próprio Android.
         */
          var status =
          await Permission.location.status;

          if (!status.isGranted) {
            debugPrint(
              'Solicitando permissão de localização ao usuário...',
            );

            status =
            await Permission.location.request();
          }

          final permitido = status.isGranted;

          debugPrint(
            permitido
                ? 'Localização permitida para ${request.origin}'
                : 'Localização negada pelo usuário.',
          );

          return GeolocationPermissionsResponse(
            allow: permitido,
            retain: permitido,
          );
        },
      );
    }

    await _abrirSuri();
  }

  void _receberMensagemJavaScript(
      JavaScriptMessage message,
      ) {
    final mensagem = message.message;

    debugPrint(
      'Mensagem recebida da Suri: $mensagem',
    );

    if (mensagem == 'POTY_SURI_READY') {
      _marcarComoPronto();
      return;
    }

    const prefixoErro = 'POTY_SURI_ERROR:';

    if (mensagem.startsWith(prefixoErro)) {
      final descricao = mensagem
          .substring(prefixoErro.length)
          .trim();

      _mostrarErro(
        descricao.isEmpty
            ? 'O chatbot retornou um erro.'
            : descricao,
      );
    }
  }

  Future<void> _limparSessaoCompleta() async {
    debugPrint(
      'Limpando cookies, cache e armazenamento da Paty...',
    );

    try {
      final tinhaCookies = await _cookieManager.clearCookies();

      await _controller.clearCache();
      await _controller.clearLocalStorage();

      debugPrint(
        'Sessão da Paty limpa. '
            'Cookies removidos: $tinhaCookies',
      );
    } catch (erro, stackTrace) {
      debugPrint(
        'Falha ao limpar completamente a sessão da Paty: $erro',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> _prepararNovaSessaoDaSuri() async {
    if (_sessaoPreparadaNestaTela) {
      return;
    }

    debugPrint(
      'Nova abertura da Paty: limpando sessão anterior...',
    );

    try {
      await _limparSessaoCompleta();
    } catch (_) {
      // A falha de limpeza não impede a abertura do chat.
      // O parâmetro v=... também evita reaproveitar o HTML em cache.
    } finally {
      _sessaoPreparadaNestaTela = true;
    }
  }

  Future<void> _abrirSuri() async {
    try {
      await _prepararNovaSessaoDaSuri();

      final uri = Uri.parse(
        '$_suriUrl'
            '?mobile=true'
            '&platform=mobile'
            '&v=${DateTime.now().millisecondsSinceEpoch}',
      );

      await _controller.loadRequest(uri);
    } catch (erro, stackTrace) {
      debugPrint(
        'Erro ao carregar WebView: $erro',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _mostrarErro(
        'Não foi possível carregar a Paty.',
      );
    }
  }

  void _marcarComoPronto() {
    if (!mounted) {
      return;
    }

    setState(() {
      _carregando = false;
      _chatPronto = true;
      _progresso = 100;
      _mensagemErro = null;
    });

    debugPrint(
      'Chat da Suri pronto no mobile.',
    );
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) {
      return;
    }

    setState(() {
      _carregando = false;
      _chatPronto = false;
      _mensagemErro = mensagem;
    });

    debugPrint(
      'Erro na Suri mobile: $mensagem',
    );
  }

  Future<void> _tentarNovamente() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _carregando = true;
      _chatPronto = false;
      _progresso = 0;
      _mensagemErro = null;
    });

    await _abrirSuri();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _SuriBackground(),

        WebViewWidget(
          controller: _controller,
        ),

        if (_carregando)
          _SuriMobileLoading(
            progresso: _progresso,
          ),

        if (!_carregando &&
            !_chatPronto &&
            _mensagemErro != null)
          _SuriMobileError(
            mensagem: _mensagemErro!,
            onRetry: _tentarNovamente,
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

class _SuriMobileLoading extends StatelessWidget {
  final int progresso;

  const _SuriMobileLoading({
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    final progressoNormalizado =
    progresso > 0 && progresso < 100
        ? progresso / 100
        : null;

    final textoProgresso = progresso > 0
        ? 'Preparando atendimento: $progresso%'
        : 'Preparando seu atendimento.';

    return _SuriBackgroundOverlay(
      child: _SuriLoadingContent(
        progressoNormalizado: progressoNormalizado,
        textoProgresso: textoProgresso,
      ),
    );
  }
}

class _SuriBackgroundOverlay extends StatelessWidget {
  final Widget child;

  const _SuriBackgroundOverlay({
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
                top: -140,
                right: -110,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _SuriColors.lime.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -150,
                bottom: -190,
                child: Container(
                  width: 390,
                  height: 390,
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
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuriLoadingContent extends StatelessWidget {
  final double? progressoNormalizado;
  final String textoProgresso;

  const _SuriLoadingContent({
    this.progressoNormalizado,
    this.textoProgresso = 'Preparando seu atendimento.',
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          28,
          30,
          28,
          28,
        ),
        decoration: BoxDecoration(
          color: _SuriColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _SuriColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: _SuriColors.deepest.withValues(
                alpha: 0.13,
              ),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
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
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: const _PatyLoadingVideo(),
            ),
            const SizedBox(height: 24),
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
              textoProgresso,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: _SuriColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progressoNormalizado,
                backgroundColor:
                _SuriColors.progressBackground,
                valueColor:
                const AlwaysStoppedAnimation<Color>(
                  _SuriColors.lime,
                ),
              ),
            ),
            const SizedBox(height: 15),
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
    );
  }
}

class _SuriMobileError extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onRetry;

  const _SuriMobileError({
    required this.mensagem,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _SuriBackgroundOverlay(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            28,
            30,
            28,
            28,
          ),
          decoration: BoxDecoration(
            color: _SuriColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _SuriColors.errorBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: _SuriColors.deepest.withValues(
                  alpha: 0.14,
                ),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _SuriColors.errorSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _SuriColors.errorBorder,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 34,
                  color: _SuriColors.error,
                ),
              ),
              const SizedBox(height: 22),
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
              const SizedBox(height: 25),
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
  static const progressBackground = Color(0xFFDCE6D7);

  static const textStrong = Color(0xFF17301F);
  static const textMuted = Color(0xFF5F6F61);

  static const error = Color(0xFFB5473F);
  static const errorSurface = Color(0xFFFCEBE8);
  static const errorBorder = Color(0xFFEAC0BB);
}
