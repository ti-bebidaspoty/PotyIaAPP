import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/ui/core/themes/app_breakpoints.dart';
import 'package:poty_ia_app/ui/core/themes/cores.dart';
import 'package:poty_ia_app/ui/core/themes/app_spacing.dart';
import 'package:poty_ia_app/ui/core/widgets/app_logo.dart';
import 'package:poty_ia_app/ui/login/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginController get controller => Get.find<LoginController>();

  Future<void> _enviarLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final formularioValido =
        _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    await controller.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop =
          AppBreakpoints.isDesktop(width);

          if (isDesktop) {
            return _DesktopLoginLayout(
              formKey: _formKey,
              controller: controller,
              onSubmit: _enviarLogin,
            );
          }

          return _CompactLoginLayout(
            formKey: _formKey,
            controller: controller,
            onSubmit: _enviarLogin,
          );
        },
      ),
    );
  }
}

class _DesktopLoginLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginController controller;
  final Future<void> Function() onSubmit;

  const _DesktopLoginLayout({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 11,
          child: _BrandPanel(),
        ),
        Expanded(
          flex: 9,
          child: ColoredBox(
            color: AppColors.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppSpacing.xxl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 440,
                  ),
                  child: _LoginForm(
                    formKey: formKey,
                    controller: controller,
                    onSubmit: onSubmit,
                    showHeaderLogo: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactLoginLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginController controller;
  final Future<void> Function() onSubmit;

  const _CompactLoginLayout({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDeep,
            AppColors.primaryDark,
            AppColors.primary,
            Color(0xFF8F9443),
          ],
          stops: [
            0.0,
            0.40,
            0.82,
            1.0,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  const AppLogo(
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    elevation: 8,
                    shadowColor:
                    AppColors.textPrimary.withValues(
                      alpha: 0.18,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.sizeOf(context).width < 380
                            ? AppSpacing.lg
                            : AppSpacing.xl,
                      ),
                      child: _LoginForm(
                        formKey: formKey,
                        controller: controller,
                        onSubmit: onSubmit,
                        showHeaderLogo: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDeep,
            AppColors.primaryDark,
            AppColors.primary,
            Color(0xFF8F9443),
          ],
          stops: [
            0.0,
            0.40,
            0.82,
            1.0,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _DecorativeCircle(
              size: 340,
              opacity: 0.08,
            ),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _DecorativeCircle(
              size: 420,
              opacity: 0.06,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(
                  foregroundColor: Colors.white,
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 560,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inteligência para decisões mais rápidas.',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Uma plataforma inteligente para facilitar '
                            'o acesso às informações e apoiar os processos '
                            'da Poty.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Colors.white.withValues(
                            alpha: 0.82,
                          ),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FeatureBadge(
                            icon: Icons.lock_outline_rounded,
                            text: 'Ambiente seguro',
                          ),
                          _FeatureBadge(
                            icon: Icons.bolt_rounded,
                            text: 'Acesso rápido',
                          ),
                          _FeatureBadge(
                            icon: Icons.auto_awesome_rounded,
                            text: 'Potencializado por IA',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Bebidas Poty • Tecnologia da Informação',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: Colors.white.withValues(
                      alpha: 0.62,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginController controller;
  final Future<void> Function() onSubmit;
  final bool showHeaderLogo;

  const _LoginForm({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
    required this.showHeaderLogo,
  });

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeaderLogo) ...[
              const AppLogo(),
              const SizedBox(height: AppSpacing.xxl),
            ],
            Text(
              'Bem-vindo',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Informe suas credenciais para acessar o sistema.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Usuário',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: controller.usuarioController,
              validator: controller.validarUsuario,
              autofillHints: const [
                AutofillHints.username,
              ],
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Digite seu usuário',
                prefixIcon:
                Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Senha',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Obx(
                  () => TextFormField(
                controller: controller.senhaController,
                validator: controller.validarSenha,
                obscureText:
                controller.senhaOculta.value,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [
                  AutofillHints.password,
                ],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  onSubmit();
                },
                decoration: InputDecoration(
                  hintText: 'Digite sua senha',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                  ),
                  suffixIcon: IconButton(
                    tooltip:
                    controller.senhaOculta.value
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: controller
                        .alterarVisibilidadeSenha,
                    icon: AnimatedSwitcher(
                      duration:
                      const Duration(milliseconds: 180),
                      child: Icon(
                        controller.senhaOculta.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(
                          controller.senhaOculta.value,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
                  () => SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : onSubmit,
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 180),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                        : const Row(
                      key: ValueKey('button'),
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text('Entrar'),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
        color: Colors.white.withValues(
          alpha: opacity,
        ),
      ),
    );
  }
}