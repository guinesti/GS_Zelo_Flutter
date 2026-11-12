import 'package:flutter/material.dart';

import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/core/texto_utils.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/services/ocorrencia_repository.dart';
import 'package:gs_zelo_flutter/services/prioridade_service.dart';
import 'package:gs_zelo_flutter/widgets/avaliacao_estrelas.dart';
import 'package:gs_zelo_flutter/widgets/estados.dart';
import 'package:gs_zelo_flutter/widgets/linha_do_tempo_status.dart';
import 'package:gs_zelo_flutter/widgets/secao.dart';
import 'package:gs_zelo_flutter/widgets/visual_ocorrencia.dart';

class DetalheOcorrenciaScreen extends StatefulWidget {
  final String ocorrenciaId;

  const DetalheOcorrenciaScreen({super.key, required this.ocorrenciaId});

  @override
  State<DetalheOcorrenciaScreen> createState() =>
      _DetalheOcorrenciaScreenState();
}

class _DetalheOcorrenciaScreenState extends State<DetalheOcorrenciaScreen> {
  final _repositorio = OcorrenciaRepository.instancia;
  final _prioridade = const PrioridadeService();

  Ocorrencia? _ocorrencia;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final o = await _repositorio.buscarPorId(widget.ocorrenciaId);
    if (!mounted) return;
    setState(() {
      _ocorrencia = o;
      _carregando = false;
    });
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(texto), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _confirmar() async {
    final atualizada = await _repositorio.confirmar(widget.ocorrenciaId);
    if (!mounted || atualizada == null) return;
    setState(() => _ocorrencia = atualizada);
    _mostrarMensagem('Obrigado! Sua confirmação aumenta a prioridade.');
  }

  Future<void> _alternarAcompanhamento() async {
    final acompanhando = await _repositorio.alternarAcompanhamento(
      widget.ocorrenciaId,
    );
    if (!mounted) return;
    setState(() {});
    _mostrarMensagem(
      acompanhando
          ? 'Você receberá as atualizações desta ocorrência.'
          : 'Acompanhamento removido.',
    );
  }

  Future<void> _avaliar(int nota) async {
    final atualizada = await _repositorio.avaliar(widget.ocorrenciaId, nota);
    if (!mounted || atualizada == null) return;
    setState(() => _ocorrencia = atualizada);
    _mostrarMensagem('Avaliação registrada: $nota de 5.');
  }

  @override
  Widget build(BuildContext context) {
    final o = _ocorrencia;
    final acompanhando = _repositorio.estaAcompanhando(widget.ocorrenciaId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          if (o != null)
            IconButton(
              tooltip: acompanhando ? 'Deixar de acompanhar' : 'Acompanhar',
              icon: Icon(acompanhando ? Icons.bookmark : Icons.bookmark_border),
              onPressed: _alternarAcompanhamento,
            ),
        ],
      ),
      body: _carregando
          ? const EstadoCarregando()
          : o == null
          ? EstadoMensagem(
              icone: Icons.help_outline,
              titulo: 'Ocorrência não encontrada',
              acao: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            )
          : _conteudo(o),
    );
  }

  Widget _conteudo(Ocorrencia o) {
    final tema = Theme.of(context);
    final prioridade = _prioridade.classificar(o);
    final jaConfirmou = _repositorio.jaConfirmou(o.id);

    return ListView(
      padding: const EdgeInsets.all(Espacos.m),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoriaAvatar(categoria: o.categoria, raio: 28),
            const SizedBox(width: Espacos.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.categoria.label,
                    style: tema.textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    o.titulo,
                    style: tema.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Espacos.p),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Etiqueta.status(o.status),
                      if (o.status.estaAberta) Etiqueta.prioridade(prioridade),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Espacos.g),
        Secao(
          titulo: 'Informações',
          icone: Icons.info_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (o.descricao.isNotEmpty) ...[
                Text(o.descricao),
                const SizedBox(height: 12),
              ],
              LinhaInfo(icone: Icons.place_outlined, texto: o.endereco),
              if (o.cep.isNotEmpty)
                LinhaInfo(
                  icone: Icons.markunread_mailbox_outlined,
                  texto: 'CEP ${o.cep}',
                ),
              LinhaInfo(
                icone: Icons.event_outlined,
                texto:
                    'Registrada em ${TextoUtils.formatarData(o.criadaEm)} (${TextoUtils.tempoDecorrido(o.criadaEm)})',
              ),
              if (o.resolvidaEm != null)
                LinhaInfo(
                  icone: Icons.task_alt,
                  texto: 'Resolvida em ${o.diasEmAberto()} dia(s)',
                ),
              if (o.proximaServicoEssencial)
                const LinhaInfo(
                  icone: Icons.school_outlined,
                  texto: 'Próxima a escola, hospital ou ponto de ônibus',
                ),
              LinhaInfo(
                icone: Icons.person_outline,
                texto: o.anonima
                    ? 'Registro anônimo'
                    : 'Registrada por um morador',
              ),
            ],
          ),
        ),
        Secao(
          titulo: 'Confirmações da vizinhança',
          icone: Icons.groups_outlined,
          child: Row(
            children: [
              Text(
                '${o.confirmacoes}',
                style: tema.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaria,
                ),
              ),
              const SizedBox(width: Espacos.p),
              const Expanded(
                child: Text('moradores confirmaram este problema'),
              ),
            ],
          ),
        ),
        Secao(
          titulo: 'Andamento',
          icone: Icons.timeline_outlined,
          child: LinhaDoTempoStatus(atual: o.status),
        ),
        if (!o.status.estaAberta)
          Secao(
            titulo: o.avaliacao == null ? 'Avalie a solução' : 'Sua avaliação',
            icone: Icons.star_outline,
            child: AvaliacaoEstrelas(nota: o.avaliacao, onAvaliar: _avaliar),
          ),
        if (o.status.estaAberta)
          ElevatedButton.icon(
            onPressed: jaConfirmou ? null : _confirmar,
            icon: Icon(jaConfirmou ? Icons.check : Icons.thumb_up_alt_outlined),
            label: Text(
              jaConfirmou ? 'Você já confirmou' : 'Confirmar ocorrência',
            ),
          ),
        const SizedBox(height: Espacos.m),
      ],
    );
  }
}
