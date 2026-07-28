import 'package:flutter/material.dart';
import 'package:poty_ia_app/ui/core/themes/cores.dart';

class AppLogo extends StatelessWidget {
  final bool showName;
  final double height;
  final Color? foregroundColor;

  const AppLogo({
    super.key,
    this.showName = true,
    this.height = 70,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: height,
          height: height,
          child: Image.asset(
            'assets/images/logo_transparente.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 12),
          Text(
            'Poty IA',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}