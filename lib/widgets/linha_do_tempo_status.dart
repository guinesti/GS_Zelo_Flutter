import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/status_ocorrencia.dart';

class LinhaDoTempoStatus extends StatelessWidget {
  final StatusOcorrencia atual;

  const LinhaDoTempoStatus({super.key, required this.atual});

  @override
  Widget build(BuildContext context) {
    final etapas = StatusOcorrencia.values;
    return Column(
      children: [
        for (var i = 0; i < etapas.length; i++)
          _Etapa(
            status: etapas[i],
            concluida: etapas[i].index <= atual.index,
            atual: etapas[i] == atual,
            ultima: i == etapas.length - 1,
          ),
      ],
    );
  }
}

class _Etapa extends StatelessWidget {
  final StatusOcorrencia status;
  final bool concluida;
  final bool atual;
  final bool ultima;

  const _Etapa({
    required this.status,
    required this.concluida,
    required this.atual,
    required this.ultima,
  });

  @override
  Widget build(BuildContext context) {
    final cor = concluida ? AppColors.primaria : Colors.grey.shade400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              concluida ? Icons.check_circle : Icons.radio_button_unchecked,
              color: cor,
              size: 22,
            ),
            if (!ultima) Container(width: 2, height: 24, color: cor),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            status.label,
            style: TextStyle(
              fontWeight: atual ? FontWeight.w700 : FontWeight.w400,
              color: concluida ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
