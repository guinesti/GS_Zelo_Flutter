import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/core/texto_utils.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/models/prioridades.dart';
import 'package:gs_zelo_flutter/widgets/visual_ocorrencia.dart';

class OcorrenciaCard extends StatelessWidget {
  final Ocorrencia ocorrencia;
  final Prioridade prioridade;
  final bool acompanhando;
  final VoidCallback onTap;
  final VoidCallback? onAlternarAcompanhamento;

  const OcorrenciaCard({
    super.key,
    required this.ocorrencia,
    required this.prioridade,
    required this.acompanhando,
    required this.onTap,
    this.onAlternarAcompanhamento,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoriaAvatar(categoria: ocorrencia.categoria),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ocorrencia.titulo,
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            ocorrencia.endereco,
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Etiqueta.status(ocorrencia.status),
                        if (ocorrencia.status.estaAberta)
                          Etiqueta.prioridade(prioridade),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ocorrencia.confirmacoes} confirmações · ${TextoUtils.tempoDecorrido(ocorrencia.criadaEm)}',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onAlternarAcompanhamento != null)
                IconButton(
                  tooltip: acompanhando ? 'Deixar de acompanhar' : 'Acompanhar',
                  onPressed: onAlternarAcompanhamento,
                  icon: Icon(
                    acompanhando ? Icons.bookmark : Icons.bookmark_border,
                    color: acompanhando ? AppColors.primaria : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
