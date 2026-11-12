import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';

class EstadoMensagem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? descricao;
  final Widget? acao;

  const EstadoMensagem({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espacos.g),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 56,
              color: AppColors.primaria.withValues(alpha: 0.6),
            ),
            const SizedBox(height: Espacos.m),
            Text(
              titulo,
              style: tema.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (descricao != null) ...[
              const SizedBox(height: Espacos.p),
              Text(
                descricao!,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (acao != null) ...[const SizedBox(height: Espacos.m), acao!],
          ],
        ),
      ),
    );
  }
}

class EstadoCarregando extends StatelessWidget {
  final String mensagem;

  const EstadoCarregando({super.key, this.mensagem = 'Carregando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: Espacos.m),
          Text(mensagem),
        ],
      ),
    );
  }
}

class EstadoErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;

  const EstadoErro({
    super.key,
    required this.mensagem,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return EstadoMensagem(
      icone: Icons.cloud_off_outlined,
      titulo: 'Algo deu errado',
      descricao: mensagem,
      acao: ElevatedButton.icon(
        onPressed: onTentarNovamente,
        icon: const Icon(Icons.refresh),
        label: const Text('Tentar novamente'),
      ),
    );
  }
}
