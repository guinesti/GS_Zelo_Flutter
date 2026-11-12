import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';

class AvaliacaoEstrelas extends StatelessWidget {
  final int? nota;
  final ValueChanged<int>? onAvaliar;

  const AvaliacaoEstrelas({super.key, required this.nota, this.onAvaliar});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final valor = i + 1;
        final preenchida = nota != null && valor <= nota!;
        return IconButton(
          tooltip: '$valor estrela${valor > 1 ? 's' : ''}',
          onPressed: onAvaliar == null ? null : () => onAvaliar!(valor),
          icon: Icon(
            preenchida ? Icons.star_rounded : Icons.star_outline_rounded,
            color: preenchida ? AppColors.destaque : Colors.grey,
            size: 32,
          ),
        );
      }),
    );
  }
}
