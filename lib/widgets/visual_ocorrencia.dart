import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/categoria.dart';
import 'package:gs_zelo_flutter/models/prioridades.dart';
import 'package:gs_zelo_flutter/models/status_ocorrencia.dart';

class VisualOcorrencia {
  VisualOcorrencia._();

  static IconData iconeCategoria(Categoria c) => switch (c) {
    Categoria.buraco => Icons.warning_amber_rounded,
    Categoria.iluminacao => Icons.lightbulb_outline,
    Categoria.lixo => Icons.delete_outline,
    Categoria.calcada => Icons.directions_walk,
    Categoria.outros => Icons.report_outlined,
  };

  static Color corCategoria(Categoria c) => switch (c) {
    Categoria.buraco => const Color(0xFF8D5A3B),
    Categoria.iluminacao => const Color(0xFFC88A04),
    Categoria.lixo => const Color(0xFF5B7F2A),
    Categoria.calcada => const Color(0xFF4A6FA5),
    Categoria.outros => const Color(0xFF6B6B6B),
  };

  static Color corStatus(StatusOcorrencia s) => switch (s) {
    StatusOcorrencia.registrada => const Color(0xFF6B7280),
    StatusOcorrencia.emAnalise => const Color(0xFF4A6FA5),
    StatusOcorrencia.emExecucao => const Color(0xFFC88A04),
    StatusOcorrencia.resolvida => AppColors.prioridadeBaixa,
  };

  static Color corPrioridade(Prioridade p) => switch (p) {
    Prioridade.alta => AppColors.prioridadeAlta,
    Prioridade.media => AppColors.prioridadeMedia,
    Prioridade.baixa => AppColors.prioridadeBaixa,
  };
}

class CategoriaAvatar extends StatelessWidget {
  final Categoria categoria;
  final double raio;

  const CategoriaAvatar({super.key, required this.categoria, this.raio = 24});

  @override
  Widget build(BuildContext context) {
    final cor = VisualOcorrencia.corCategoria(categoria);
    return CircleAvatar(
      radius: raio,
      backgroundColor: cor.withValues(alpha: 0.14),
      child: Icon(
        VisualOcorrencia.iconeCategoria(categoria),
        color: cor,
        size: raio,
      ),
    );
  }
}

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  final IconData? icone;

  const Etiqueta({
    super.key,
    required this.texto,
    required this.cor,
    this.icone,
  });

  factory Etiqueta.status(StatusOcorrencia s) =>
      Etiqueta(texto: s.label, cor: VisualOcorrencia.corStatus(s));

  factory Etiqueta.prioridade(Prioridade p) => Etiqueta(
    texto: 'Prioridade ${p.label.toLowerCase()}',
    cor: VisualOcorrencia.corPrioridade(p),
    icone: Icons.flag_outlined,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: cor),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              color: cor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
