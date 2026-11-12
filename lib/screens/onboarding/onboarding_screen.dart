import 'package:flutter/material.dart';

import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/onboarding_item.dart';
import 'package:gs_zelo_flutter/services/preferences_service.dart';
import 'package:gs_zelo_flutter/widgets/onboarding_pagina.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _paginas = [
    OnboardingItem(
      icone: Icons.photo_camera_outlined,
      titulo: 'Registre em segundos',
      descricao:
          'Viu um buraco, um poste apagado ou lixo acumulado? '
          'Escolha a categoria, informe o local e pronto.',
    ),
    OnboardingItem(
      icone: Icons.groups_outlined,
      titulo: 'Confirme com a vizinhança',
      descricao:
          'Moradores confirmam as ocorrências. Quanto mais confirmações, '
          'maior a prioridade do problema.',
    ),
    OnboardingItem(
      icone: Icons.timeline_outlined,
      titulo: 'Acompanhe até a solução',
      descricao:
          'Veja cada etapa: registrada, em análise, em execução e resolvida. '
          'No final, avalie o serviço.',
    ),
    OnboardingItem(
      icone: Icons.query_stats_outlined,
      titulo: 'Transparência por bairro',
      descricao:
          'O painel público mostra ocorrências abertas e o tempo médio de '
          'resolução de cada bairro.',
    ),
  ];

  final _pageController = PageController();
  final _preferences = PreferencesService();

  int _paginaAtual = 0;
  bool _naoMostrarNovamente = false;

  bool get _ehUltimaPagina => _paginaAtual == _paginas.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _avancar() {
    if (_ehUltimaPagina) {
      _finalizar();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _voltar() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finalizar() async {
    await _preferences.salvarOnboardingVisto(_naoMostrarNovamente);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finalizar,
                child: const Text('Pular'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _paginas.length,
                onPageChanged: (pagina) =>
                    setState(() => _paginaAtual = pagina),
                itemBuilder: (_, i) => OnboardingPagina(item: _paginas[i]),
              ),
            ),
            IndicadorPaginas(total: _paginas.length, atual: _paginaAtual),
            const SizedBox(height: Espacos.m),
            CheckboxListTile(
              value: _naoMostrarNovamente,
              onChanged: (valor) =>
                  setState(() => _naoMostrarNovamente = valor ?? false),
              title: const Text('Não mostrar novamente'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: Espacos.p),
              dense: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espacos.m,
                0,
                Espacos.m,
                Espacos.m,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _paginaAtual == 0 ? null : _voltar,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: Espacos.m),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _avancar,
                      icon: Icon(
                        _ehUltimaPagina ? Icons.check : Icons.arrow_forward,
                      ),
                      label: Text(_ehUltimaPagina ? 'Começar' : 'Avançar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
