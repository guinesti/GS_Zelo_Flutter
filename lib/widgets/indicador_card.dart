import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';

class IndicadorCard extends StatelessWidget {
  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;

  const IndicadorCard({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    this.cor = AppColors.primaria,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icone, color: cor),
            Text(
              valor,
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cor,
              ),
            ),
            Text(
              rotulo,
              style: tema.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
