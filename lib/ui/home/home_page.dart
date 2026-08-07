import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:poty_ia_app/data/services/prefs.dart';
import 'package:poty_ia_app/routes/app_routes.dart';
import 'package:poty_ia_app/ui/home/widgets/suri_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout() async {
    await Prefs.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }

  void _abrirPaty() {
    Get.to(
          () => const SuriChatPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HomeColors.deepest,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _HomeColors.deepest,
              _HomeColors.forest,
              _HomeColors.olive,
            ],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _HomeBackgroundArtwork(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final horizontalPadding = isMobile ? 16.0 : 28.0;

                  return Column(
                    children: [
                      _HomeHeader(
                        horizontalPadding: horizontalPadding,
                        onLogout: _logout,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, bodyConstraints) {
                            final verticalPadding = isMobile ? 16.0 : 24.0;
                            final availableHeight = (
                                bodyConstraints.maxHeight -
                                    (verticalPadding * 2)
                            ).clamp(0.0, double.infinity).toDouble();

                            return SingleChildScrollView(
                              keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalPadding,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: availableHeight,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: isMobile ? 520 : 560,
                                    ),
                                    child: _AssistantPresentationCard(
                                      isDesktop: !isMobile,
                                      onOpenChat: _abrirPaty,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final double horizontalPadding;
  final Future<void> Function() onLogout;

  const _HomeHeader({
    required this.horizontalPadding,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 390;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: _HomeBrandHeader(
              showSubtitle: !isNarrow,
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 12 : 15,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                    if (!isNarrow) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Sair',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBrandHeader extends StatelessWidget {
  final bool showSubtitle;

  const _HomeBrandHeader({
    required this.showSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = showSubtitle ? 70.0 : 60.0;

    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.30),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: _HomeColors.olive.withValues(alpha: 0.22),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.13),
                blurRadius: 5,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _HomeColors.forest,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Image.asset(
                    'assets/images/poty.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Center(
                        child: Icon(
                          Icons.business_rounded,
                          color: _HomeColors.limeSoft,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BEBIDAS POTY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Tecnologia da Informação',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onOpenChat;

  const _HeroSection({required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 860;

        final introduction = _HeroIntroduction(isDesktop: isDesktop);
        final assistantCard = _AssistantPresentationCard(
          isDesktop: isDesktop,
          onOpenChat: onOpenChat,
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: introduction),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: assistantCard),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: assistantCard,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: introduction,
            ),
          ],
        );
      },
    );
  }
}

class _HeroIntroduction extends StatelessWidget {
  final bool isDesktop;

  const _HeroIntroduction({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 540 : 0),
      padding: EdgeInsets.all(isDesktop ? 42 : 25),
      decoration: BoxDecoration(
        color: _HomeColors.lightCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _AvailabilityBadge(),
          SizedBox(height: isDesktop ? 28 : 22),
          Text(
            'Olá! Eu sou a Paty.',
            style: isDesktop
                ? theme.textTheme.displaySmall?.copyWith(
              color: _HomeColors.textStrong,
              fontWeight: FontWeight.w800,
              height: 1.04,
              letterSpacing: -1.2,
            )
                : theme.textTheme.headlineMedium?.copyWith(
              color: _HomeColors.textStrong,
              fontWeight: FontWeight.w800,
              height: 1.08,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sua assistente virtual para dúvidas, acessos, sistemas, '
                'equipamentos e solicitações de atendimento.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _HomeColors.textMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 30),
          const _InformationItem(
            icon: Icons.lock_reset_rounded,
            title: 'Acessos e senhas',
            description: 'Solicite acessos ou recupere sua senha.',
          ),
          const SizedBox(height: 17),
          const _InformationItem(
            icon: Icons.computer_rounded,
            title: 'Sistemas e equipamentos',
            description: 'Informe erros, falhas ou lentidão.',
          ),
          const SizedBox(height: 17),
          const _InformationItem(
            icon: Icons.confirmation_number_rounded,
            title: 'Solicitações de TI',
            description: 'Registre uma nova demanda para atendimento.',
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: _HomeColors.lime.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _HomeColors.lime.withValues(alpha: 0.34),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingStatusDot(),
          SizedBox(width: 9),
          Text(
            'ASSISTENTE DISPONÍVEL',
            style: TextStyle(
              color: _HomeColors.forest,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingStatusDot extends StatefulWidget {
  const _PulsingStatusDot();

  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: _HomeColors.brandGreenLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InformationItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _HomeColors.brandTint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _HomeColors.brandTintBorder),
          ),
          child: Icon(
            icon,
            size: 22,
            color: _HomeColors.brandGreen,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _HomeColors.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _HomeColors.textMuted,
                  height: 1.38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssistantPresentationCard extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onOpenChat;

  const _AssistantPresentationCard({
    required this.isDesktop,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 540 : 0),
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102C1D),
            _HomeColors.forest,
            _HomeColors.olive,
          ],
          stops: [0.0, 0.60, 1.0],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.23),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -80,
            top: -90,
            child: _DecorativeCircle(size: 250, opacity: 0.07),
          ),
          const Positioned(
            left: -85,
            bottom: -105,
            child: _DecorativeCircle(size: 260, opacity: 0.055),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PatyLoopVideo(compact: !isDesktop),
              SizedBox(height: isDesktop ? 24 : 20),
              Text(
                'Paty',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'A Inteligência Artificial da Bebidas Poty',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isDesktop ? 26 : 22),
              FilledButton.icon(
                onPressed: onOpenChat,
                style: FilledButton.styleFrom(
                  foregroundColor: _HomeColors.buttonText,
                  backgroundColor: _HomeColors.lime,
                  disabledBackgroundColor:
                  _HomeColors.lime.withValues(alpha: 0.45),
                  minimumSize: const Size.fromHeight(58),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_rounded, size: 21),
                label: const Text('Falar com a Paty'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatyLoopVideo extends StatefulWidget {
  final bool compact;

  const _PatyLoopVideo({required this.compact});

  @override
  State<_PatyLoopVideo> createState() => _PatyLoopVideoState();
}

class _PatyLoopVideoState extends State<_PatyLoopVideo> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/videos/paty.mp4',
    );

    _initialization = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0);
    await _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            padding: EdgeInsets.all(widget.compact ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(widget.compact ? 22 : 26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 13),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.compact ? 17 : 20),
              child: ColoredBox(
                color: const Color(0xFF09110D),
                child: FutureBuilder<void>(
                  future: _initialization,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const _VideoErrorState();
                    }

                    if (snapshot.connectionState != ConnectionState.done ||
                        !_controller.value.isInitialized) {
                      return const _VideoLoadingState();
                    }

                    final videoSize = _controller.value.size;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: videoSize.width,
                            height: videoSize.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        const IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x00000000),
                                  Color(0x08000000),
                                  Color(0x62000000),
                                ],
                                stops: [0.0, 0.62, 1.0],
                              ),
                            ),
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VideoLoadingState extends StatelessWidget {
  const _VideoLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          color: _HomeColors.lime,
          strokeWidth: 2.4,
        ),
      ),
    );
  }
}

class _VideoErrorState extends StatelessWidget {
  const _VideoErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              color: Colors.white.withValues(alpha: 0.68),
              size: 32,
            ),
            const SizedBox(height: 9),
            Text(
              'Não foi possível carregar o vídeo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuriChatPage extends StatelessWidget {
  const SuriChatPage({super.key});

  void _fecharChat() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // No mobile, o conteúdo fica atrás do AppBar para esconder
    // o cabeçalho interno da SURI.
    //
    // Na Web, isso fica desativado para preservar o clique
    // no botão de fechar sobre o HtmlElementView.
    final esconderCabecalhoSuri = !kIsWeb;

    return Scaffold(
      extendBodyBehindAppBar: esconderCabecalhoSuri,
      backgroundColor: _HomeColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(82),
        child: AppBar(
          toolbarHeight: 82,
          automaticallyImplyLeading: false,
          titleSpacing: 18,

          // Fundo verde opaco para esconder o conteúdo da SURI.
          backgroundColor: _HomeColors.forest,
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: false,

          elevation: 0,
          scrolledUnderElevation: 0,

          systemOverlayStyle: SystemUiOverlayStyle.light,

          flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _HomeColors.deepest,
                  _HomeColors.forest,
                  _HomeColors.olive,
                ],
                stops: [
                  0.0,
                  0.58,
                  1.0,
                ],
              ),
            ),
          ),

          shape: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),

          title: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/paty.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const ColoredBox(
                        color: _HomeColors.forest,
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 29,
                          color: _HomeColors.limeSoft,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paty',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'A Inteligência Artificial da Poty',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 13,
                        height: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            IconButton(
              tooltip: 'Fechar atendimento',
              onPressed: _fecharChat,
              iconSize: 27,
              color: Colors.white,
              icon: const Icon(
                Icons.close_rounded,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE7F0DF),
              _HomeColors.lightBackground,
              Color(0xFFD9E8D0),
            ],
          ),
        ),
        child: SuriView(),
      ),
    );
  }
}

class _HomeBackgroundArtwork extends StatelessWidget {
  const _HomeBackgroundArtwork();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const Positioned(
            top: -220,
            right: -170,
            child: _OutlinedCircle(size: 520, opacity: 0.06),
          ),
          const Positioned(
            top: -85,
            right: -35,
            child: _OutlinedCircle(size: 280, opacity: 0.045),
          ),
          Positioned(
            left: -270,
            bottom: -340,
            child: Container(
              width: 650,
              height: 650,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _HomeColors.lime.withValues(alpha: 0.045),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _OutlinedCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _OutlinedCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

abstract final class _HomeColors {
  static const deepest = Color(0xFF0C2117);
  static const forest = Color(0xFF174126);
  static const olive = Color(0xFF466B28);

  static const lime = Color(0xFFB6CC45);
  static const limeSoft = Color(0xFFD8E986);
  static const buttonText = Color(0xFF172014);

  static const lightBackground = Color(0xFFEAF2E2);
  static const lightCard = Color(0xFFF6F8F2);

  static const textStrong = Color(0xFF172014);
  static const textMuted = Color(0xFF5C6858);

  static const brandGreen = Color(0xFF174126);
  static const brandGreenLight = Color(0xFF4F7A42);
  static const brandTint = Color(0xFFE4EEDB);
  static const brandTintBorder = Color(0xFFCBDDBF);
}
