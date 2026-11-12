import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/services/ocorrencia_repository.dart';
import 'package:gs_zelo_flutter/services/preferences_service.dart';
import 'package:gs_zelo_flutter/widgets/secao.dart';
import 'package:gs_zelo_flutter/widgets/zelo_logo.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  Future<void> _reverIntroducao(BuildContext context) async {
    await PreferencesService().salvarOnboardingVisto(false);
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
  }

  Future<void> _restaurarDados(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar dados de exemplo?'),
        content: const Text(
          'As ocorrências registradas neste aparelho serão substituídas pelos dados de demonstração.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;
    await OcorrenciaRepository.instancia.restaurarDadosIniciais();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dados restaurados.')));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Zelo')),
      body: ListView(
        padding: const EdgeInsets.all(Espacos.m),
        children: [
          const Center(child: ZeloLogo(tamanho: 96)),
          const SizedBox(height: Espacos.p),
          Text(
            'Zelo — Zeladoria Colaborativa',
            textAlign: TextAlign.center,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Espacos.p),
          Text(
            'Moradores registram problemas dos espaços públicos, confirmam as ocorrências '
            'da vizinhança e acompanham cada etapa até a solução.',
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: Espacos.g),
          const Secao(
            titulo: 'Conexão com os ODS',
            icone: Icons.public,
            child: Column(
              children: [
                _ItemOds(
                  numero: 11,
                  texto: 'Cidades e comunidades sustentáveis',
                ),
                _ItemOds(
                  numero: 9,
                  texto: 'Indústria, inovação e infraestrutura',
                ),
                _ItemOds(numero: 10, texto: 'Redução das desigualdades'),
              ],
            ),
          ),
          const Secao(
            titulo: 'Fontes de dados',
            icone: Icons.cloud_outlined,
            child: Column(
              children: [
                LinhaInfo(
                  icone: Icons.location_city_outlined,
                  texto: 'Bairros: API de Localidades do IBGE',
                ),
                LinhaInfo(
                  icone: Icons.markunread_mailbox_outlined,
                  texto: 'Endereços: API ViaCEP',
                ),
                LinhaInfo(
                  icone: Icons.phone_android,
                  texto: 'Ocorrências: salvas no aparelho (funciona offline)',
                ),
              ],
            ),
          ),
          Secao(
            titulo: 'Configurações',
            icone: Icons.settings_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _reverIntroducao(context),
                  icon: const Icon(Icons.slideshow_outlined),
                  label: const Text('Rever introdução'),
                ),
                const SizedBox(height: Espacos.p),
                TextButton.icon(
                  onPressed: () => _restaurarDados(context),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar dados de exemplo'),
                ),
              ],
            ),
          ),
          Text(
            'Global Solution 2026.2 · FIAP · CitizenTech',
            textAlign: TextAlign.center,
            style: tema.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemOds extends StatelessWidget {
  final int numero;
  final String texto;

  const _ItemOds({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacos.p),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaria,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$numero',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('ODS $numero — $texto')),
        ],
      ),
    );
  }
}
