import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poty_ia_app/data/services/prefs.dart';
import 'package:poty_ia_app/routes/app_routes.dart';
import 'package:poty_ia_app/ui/core/themes/app_breakpoints.dart';
import 'package:poty_ia_app/ui/core/themes/cores.dart';
import 'package:poty_ia_app/ui/core/themes/app_spacing.dart';
import 'package:poty_ia_app/ui/core/widgets/app_logo.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  Future<void> _logout() async {
    await Prefs.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppBreakpoints.isDesktop(
          constraints.maxWidth,
        );

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigation(
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  onLogout: _logout,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _HomeContent(
                    selectedIndex: selectedIndex,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const AppLogo(height: 36),
            actions: [
              IconButton(
                tooltip: 'Sair',
                onPressed: _logout,
                icon: const Icon(
                  Icons.logout_rounded,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _HomeContent(
            selectedIndex: selectedIndex,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon:
                Icon(Icons.chat_bubble_rounded),
                label: 'Assistente',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'Histórico',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _DesktopNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: AppLogo(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: NavigationRail(
                    extended: true,
                    minExtendedWidth: 260,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onSelected,
                    labelType: NavigationRailLabelType.none,
                    groupAlignment: -1,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon:
                        Icon(Icons.home_rounded),
                        label: Text('Início'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.chat_bubble_outline,
                        ),
                        selectedIcon: Icon(
                          Icons.chat_bubble_rounded,
                        ),
                        label: Text('Assistente'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history_outlined),
                        selectedIcon:
                        Icon(Icons.history_rounded),
                        label: Text('Histórico'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sair'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final int selectedIndex;

  const _HomeContent({
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Visão geral',
      'Assistente Poty IA',
      'Histórico',
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1280,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[selectedIndex],
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Bem-vindo ao ambiente Poty IA.',
                  style:
                  Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppSpacing.xl,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMedium,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.lg,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login realizado com sucesso',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                              const SizedBox(
                                height: AppSpacing.xs,
                              ),
                              Text(
                                'A estrutura inicial está pronta '
                                    'para receber as funcionalidades '
                                    'da aplicação.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}