import 'package:flutter/material.dart';

import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/core/texto_utils.dart';
import 'package:gs_zelo_flutter/core/view_state.dart';
import 'package:gs_zelo_flutter/models/bairro.dart';
import 'package:gs_zelo_flutter/services/api_exception.dart';
import 'package:gs_zelo_flutter/services/bairro_service.dart';
import 'package:gs_zelo_flutter/widgets/campo_busca.dart';
import 'package:gs_zelo_flutter/widgets/estados.dart';

class BairrosScreen extends StatefulWidget {
  const BairrosScreen({super.key});

  @override
  State<BairrosScreen> createState() => _BairrosScreenState();
}

class _BairrosScreenState extends State<BairrosScreen> {
  final _service = BairroService();
  final _buscaController = TextEditingController();

  ViewState _estado = ViewState.inicial;
  List<Bairro> _bairros = [];
  String _mensagemErro = '';

  List<Bairro> get _filtrados {
    final termo = TextoUtils.normalizar(_buscaController.text);
    if (termo.isEmpty) return _bairros;
    return _bairros
        .where((b) => TextoUtils.normalizar(b.nome).contains(termo))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _estado = ViewState.carregando);
    try {
      final bairros = await _service.listarBairros();
      if (!mounted) return;
      setState(() {
        _bairros = bairros;
        _estado = ViewState.sucesso;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = e.mensagem;
        _estado = ViewState.erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bairros'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh),
            onPressed: _estado == ViewState.carregando ? null : _carregar,
          ),
        ],
      ),
      body: switch (_estado) {
        ViewState.inicial => EstadoMensagem(
          icone: Icons.location_city_outlined,
          titulo: 'Painel público por bairro',
          descricao:
              'Carregue a lista de bairros de São Paulo para ver os indicadores.',
          acao: ElevatedButton(
            onPressed: _carregar,
            child: const Text('Carregar bairros'),
          ),
        ),
        ViewState.carregando => const EstadoCarregando(
          mensagem: 'Buscando bairros no IBGE...',
        ),
        ViewState.erro => EstadoErro(
          mensagem: _mensagemErro,
          onTentarNovamente: _carregar,
        ),
        ViewState.sucesso => _conteudo(),
      },
    );
  }

  Widget _conteudo() {
    final itens = _filtrados;
    return Column(
      children: [
        CampoBusca(
          controller: _buscaController,
          dica: 'Buscar bairro',
          onChanged: (_) => setState(() {}),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espacos.m,
            0,
            Espacos.m,
            Espacos.p,
          ),
          child: Row(
            children: [
              const Icon(Icons.public, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${itens.length} de ${_bairros.length} distritos · fonte: IBGE',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: itens.isEmpty
              ? const EstadoMensagem(
                  icone: Icons.search_off,
                  titulo: 'Nenhum bairro encontrado',
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView.separated(
                    itemCount: itens.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) {
                      final bairro = itens[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaria.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            bairro.nome.substring(0, 1),
                            style: const TextStyle(
                              color: AppColors.primaria,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(bairro.nome),
                        subtitle: Text(bairro.municipio),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.detalheBairro, arguments: bairro),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
