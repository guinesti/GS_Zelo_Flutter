import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/onboarding_item.dart';

class OnboardingPagina extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPagina({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espacos.g),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primaria.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icone, size: 80, color: AppColors.primaria),
          ),
          const SizedBox(height: Espacos.g * 1.5),
          Text(
            item.titulo,
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: Espacos.m),
          Text(
            item.descricao,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class IndicadorPaginas extends StatelessWidget {
  final int total;
  final int atual;

  const IndicadorPaginas({super.key, required this.total, required this.atual});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final ativo = i == atual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: ativo ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ativo ? AppColors.primaria : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}  