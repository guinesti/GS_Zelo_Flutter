import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/bairro.dart';
import 'package:gs_zelo_flutter/models/indicadores_bairro.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/services/ocorrencia_repository.dart';
import 'package:gs_zelo_flutter/services/prioridade_service.dart';
import 'package:gs_zelo_flutter/widgets/estados.dart';
import 'package:gs_zelo_flutter/widgets/indicador_card.dart';
import 'package:gs_zelo_flutter/widgets/ocorrencia_card.dart';

class DetalheBairroScreen extends StatefulWidget {
  final Bairro bairro;

  const DetalheBairroScreen({super.key, required this.bairro});

  @override
  State<DetalheBairroScreen> createState() => _DetalheBairroScreenState();
}

class _DetalheBairroScreenState extends State<DetalheBairroScreen> {
  final _repositorio = OcorrenciaRepository.instancia;
  final _prioridade = const PrioridadeService();

  List<Ocorrencia> _ocorrencias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await _repositorio.listarPorBairro(widget.bairro.nome);
    if (!mounted) return;
    setState(() {
      _ocorrencias = _prioridade.ordenar(lista);
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhe(Ocorrencia o) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.detalheOcorrencia, arguments: o.id);
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bairro.nome)),
      body: _carregando ? const EstadoCarregando() : _conteudo(),
    );
  }

  Widget _conteudo() {
    final tema = Theme.of(context);
    final ind = _repositorio.calcularIndicadores(_ocorrencias);

    return ListView(
      padding: const EdgeInsets.only(bottom: Espacos.g),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espacos.m,
            Espacos.m,
            Espacos.m,
            Espacos.p,
          ),
          child: Text(
            'Indicadores do bairro',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _gradeIndicadores(ind),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espacos.m,
            Espacos.g,
            Espacos.m,
            Espacos.p,
          ),
          child: Text(
            'Ocorrências (${_ocorrencias.length})',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (_ocorrencias.isEmpty)
          const EstadoMensagem(
            icone: Icons.sentiment_satisfied_alt_outlined,
            titulo: 'Nenhuma ocorrência neste bairro',
            descricao:
                'Viu algum problema por aqui? Registre na aba Ocorrências.',
          )
        else
          for (final o in _ocorrencias)
            OcorrenciaCard(
              ocorrencia: o,
              prioridade: _prioridade.classificar(o),
              acompanhando: _repositorio.estaAcompanhando(o.id),
              onTap: () => _abrirDetalhe(o),
            ),
      ],
    );
  }

  Widget _gradeIndicadores(IndicadoresBairro ind) {
    String formatar(double? valor, String sufixo) => valor == null
        ? '—'
        : '${valor.toStringAsFixed(1).replaceAll('.', ',')}$sufixo';

    final cards = [
      IndicadorCard(
        icone: Icons.pending_actions_outlined,
        valor: '${ind.abertas}',
        rotulo: 'Ocorrências abertas',
        cor: AppColors.prioridadeAlta,
      ),
      IndicadorCard(
        icone: Icons.task_alt,
        valor: '${ind.percentualResolvidas.round()}%',
        rotulo: 'Resolvidas (${ind.resolvidas} de ${ind.total})',
        cor: AppColors.prioridadeBaixa,
      ),
      IndicadorCard(
        icone: Icons.timer_outlined,
        valor: formatar(ind.tempoMedioResolucaoDias, ' d'),
        rotulo: 'Tempo médio de resolução',
      ),
      IndicadorCard(
        icone: Icons.star_outline,
        valor: formatar(ind.notaMedia, ''),
        rotulo: 'Satisfação média (1 a 5)',
        cor: AppColors.destaque,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: cards,
    );
  }
}
