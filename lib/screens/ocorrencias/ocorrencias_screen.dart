import 'package:flutter/material.dart';

import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/categoria.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/services/ocorrencia_repository.dart';
import 'package:gs_zelo_flutter/services/prioridade_service.dart';
import 'package:gs_zelo_flutter/widgets/campo_busca.dart';
import 'package:gs_zelo_flutter/widgets/estados.dart';
import 'package:gs_zelo_flutter/widgets/ocorrencia_card.dart';
import 'package:gs_zelo_flutter/widgets/seletor_categoria.dart';

class OcorrenciasScreen extends StatefulWidget {
  const OcorrenciasScreen({super.key});

  @override
  State<OcorrenciasScreen> createState() => _OcorrenciasScreenState();
}

class _OcorrenciasScreenState extends State<OcorrenciasScreen> {
  final _repositorio = OcorrenciaRepository.instancia;
  final _prioridade = const PrioridadeService();
  final _buscaController = TextEditingController();

  List<Ocorrencia> _todas = [];
  bool _carregando = true;
  Categoria? _categoria;
  bool _somenteAbertas = false;

  List<Ocorrencia> get _filtradas => _prioridade.ordenar(
    _repositorio.filtrar(
      _todas,
      busca: _buscaController.text,
      categoria: _categoria,
      somenteAbertas: _somenteAbertas,
    ),
  );

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
    final lista = await _repositorio.listar();
    if (!mounted) return;
    setState(() {
      _todas = lista;
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhe(Ocorrencia o) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.detalheOcorrencia, arguments: o.id);
    _carregar();
  }

  Future<void> _novaOcorrencia() async {
    final mensagem =
        await Navigator.of(context).pushNamed(AppRoutes.novaOcorrencia)
            as String?;
    await _carregar();
    if (mensagem != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    }
  }

  Future<void> _alternarAcompanhamento(Ocorrencia o) async {
    final acompanhando = await _repositorio.alternarAcompanhamento(o.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            acompanhando
                ? 'Você está acompanhando esta ocorrência.'
                : 'Acompanhamento removido.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final abertas = _todas.where((o) => o.status.estaAberta).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _carregando = true);
              _carregar();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novaOcorrencia,
        backgroundColor: AppColors.destaque,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Registrar'),
      ),
      body: _carregando
          ? const EstadoCarregando(mensagem: 'Carregando ocorrências...')
          : Column(
              children: [
                CampoBusca(
                  controller: _buscaController,
                  dica: 'Buscar por título, rua ou bairro',
                  onChanged: (_) => setState(() {}),
                ),
                SeletorCategoria(
                  selecionada: _categoria,
                  onSelecionar: (c) => setState(() => _categoria = c),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espacos.m,
                    Espacos.p,
                    Espacos.p,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$abertas abertas · ordenadas por prioridade',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ),
                      const Text('Só abertas'),
                      Switch(
                        value: _somenteAbertas,
                        onChanged: (v) => setState(() => _somenteAbertas = v),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _lista()),
              ],
            ),
    );
  }

  Widget _lista() {
    final itens = _filtradas;

    if (itens.isEmpty) {
      return const EstadoMensagem(
        icone: Icons.search_off,
        titulo: 'Nenhuma ocorrência encontrada',
        descricao: 'Ajuste a busca ou os filtros.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: itens.length,
        itemBuilder: (_, i) {
          final o = itens[i];
          return OcorrenciaCard(
            ocorrencia: o,
            prioridade: _prioridade.classificar(o),
            acompanhando: _repositorio.estaAcompanhando(o.id),
            onTap: () => _abrirDetalhe(o),
            onAlternarAcompanhamento: () => _alternarAcompanhamento(o),
          );
        },
      ),
    );
  }
}
