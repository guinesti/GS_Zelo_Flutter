import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/core/view_state.dart';
import 'package:gs_zelo_flutter/models/endereco.dart';

class ConsultaCepCard extends StatelessWidget {
  final ViewState estado;
  final Endereco? endereco;
  final String? erro;
  final VoidCallback onTentarNovamente;

  const ConsultaCepCard({
    super.key,
    required this.estado,
    required this.onTentarNovamente,
    this.endereco,
    this.erro,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icone;
    final Color cor;
    final Widget conteudo;

    switch (estado) {
      case ViewState.inicial:
        icone = Icons.info_outline;
        cor = Colors.grey.shade600;
        conteudo = const Text(
          'Digite o CEP e toque na lupa para preencher o endereço automaticamente.',
        );
      case ViewState.carregando:
        icone = Icons.hourglass_top;
        cor = AppColors.primaria;
        conteudo = const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Consultando o ViaCEP...'),
          ],
        );
      case ViewState.sucesso:
        icone = Icons.check_circle_outline;
        cor = AppColors.prioridadeBaixa;
        conteudo = Text('Endereço encontrado: ${endereco?.resumo ?? ''}');
      case ViewState.erro:
        icone = Icons.error_outline;
        cor = AppColors.prioridadeAlta;
        conteudo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(erro ?? 'Não foi possível consultar o CEP.'),
            TextButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: Espacos.p),
          Expanded(child: conteudo),
        ],
      ),
    );
  }
}
