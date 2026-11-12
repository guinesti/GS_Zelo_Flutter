import 'dart:convert';

import 'package:gs_zelo_flutter/core/texto_utils.dart';
import 'package:gs_zelo_flutter/models/categoria.dart';
import 'package:gs_zelo_flutter/models/indicadores_bairro.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/models/status_ocorrencia.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultadoRegistro {
  final Ocorrencia ocorrencia;

  final bool agrupada;

  const ResultadoRegistro(this.ocorrencia, {required this.agrupada});
}

class OcorrenciaRepository {
  OcorrenciaRepository._();

  static final OcorrenciaRepository instancia = OcorrenciaRepository._();

  static const _chaveOcorrencias = 'ocorrencias';
  static const _chaveAcompanhando = 'acompanhando';
  static const _chaveConfirmadas = 'confirmadas';

  List<Ocorrencia>? _cache;
  Set<String> _acompanhando = {};
  Set<String> _confirmadas = {};

  Future<void> _carregar() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_chaveOcorrencias);

    if (salvo == null) {
      _cache = _dadosIniciais();
      await _persistir();
    } else {
      final lista = jsonDecode(salvo) as List<dynamic>;
      _cache = lista
          .map((e) => Ocorrencia.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _acompanhando = (prefs.getStringList(_chaveAcompanhando) ?? []).toSet();
    _confirmadas = (prefs.getStringList(_chaveConfirmadas) ?? []).toSet();
  }

  Future<void> _persistir() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveOcorrencias,
      jsonEncode(_cache!.map((o) => o.toJson()).toList()),
    );
    await prefs.setStringList(_chaveAcompanhando, _acompanhando.toList());
    await prefs.setStringList(_chaveConfirmadas, _confirmadas.toList());
  }

  Future<List<Ocorrencia>> listar() async {
    await _carregar();
    return List.unmodifiable(_cache!);
  }

  Future<Ocorrencia?> buscarPorId(String id) async {
    await _carregar();
    for (final o in _cache!) {
      if (o.id == id) return o;
    }
    return null;
  }

  Future<List<Ocorrencia>> listarAcompanhadas() async {
    await _carregar();
    return _cache!.where((o) => _acompanhando.contains(o.id)).toList();
  }

  Future<List<Ocorrencia>> listarPorBairro(String nomeBairro) async {
    await _carregar();
    final alvo = TextoUtils.normalizar(nomeBairro);
    return _cache!
        .where((o) => TextoUtils.normalizar(o.bairro) == alvo)
        .toList();
  }

  bool estaAcompanhando(String id) => _acompanhando.contains(id);

  bool jaConfirmou(String id) => _confirmadas.contains(id);

  List<Ocorrencia> filtrar(
    List<Ocorrencia> lista, {
    String busca = '',
    Categoria? categoria,
    bool somenteAbertas = false,
  }) {
    final termo = TextoUtils.normalizar(busca);
    return lista.where((o) {
      final casaTexto =
          termo.isEmpty ||
          TextoUtils.normalizar(o.titulo).contains(termo) ||
          TextoUtils.normalizar(o.bairro).contains(termo) ||
          TextoUtils.normalizar(o.logradouro).contains(termo);
      final casaCategoria = categoria == null || o.categoria == categoria;
      final casaStatus = !somenteAbertas || o.status.estaAberta;
      return casaTexto && casaCategoria && casaStatus;
    }).toList();
  }

  IndicadoresBairro calcularIndicadores(List<Ocorrencia> doBairro) {
    final resolvidas = doBairro.where((o) => !o.status.estaAberta).toList();
    final avaliadas = resolvidas.where((o) => o.avaliacao != null).toList();

    double? media(Iterable<num> valores) => valores.isEmpty
        ? null
        : valores.reduce((a, b) => a + b) / valores.length;

    return IndicadoresBairro(
      abertas: doBairro.length - resolvidas.length,
      resolvidas: resolvidas.length,
      confirmacoes: doBairro.fold(0, (soma, o) => soma + o.confirmacoes),
      tempoMedioResolucaoDias: media(resolvidas.map((o) => o.diasEmAberto())),
      notaMedia: media(avaliadas.map((o) => o.avaliacao!)),
    );
  }

  Future<ResultadoRegistro> registrar(Ocorrencia nova) async {
    await _carregar();

    final existente = _buscarDuplicada(nova);
    if (existente != null) {
      final atualizada = await confirmar(existente.id);
      return ResultadoRegistro(atualizada ?? existente, agrupada: true);
    }

    _cache!.insert(0, nova);
    _acompanhando.add(nova.id);
    await _persistir();
    return ResultadoRegistro(nova, agrupada: false);
  }

  Ocorrencia? _buscarDuplicada(Ocorrencia nova) {
    final cepNovo = TextoUtils.somenteDigitos(nova.cep);
    final localNovo = TextoUtils.normalizar(
      '${nova.logradouro}|${nova.bairro}',
    );

    for (final o in _cache!) {
      if (!o.status.estaAberta || o.categoria != nova.categoria) continue;
      final mesmoCep =
          cepNovo.isNotEmpty && TextoUtils.somenteDigitos(o.cep) == cepNovo;
      final mesmoLocal =
          TextoUtils.normalizar('${o.logradouro}|${o.bairro}') == localNovo;
      if (mesmoCep || mesmoLocal) return o;
    }
    return null;
  }

  Future<Ocorrencia?> confirmar(String id) async {
    await _carregar();
    final indice = _cache!.indexWhere((o) => o.id == id);
    if (indice < 0 || _confirmadas.contains(id)) return null;

    final atualizada = _cache![indice].copyWith(
      confirmacoes: _cache![indice].confirmacoes + 1,
    );
    _cache![indice] = atualizada;
    _confirmadas.add(id);
    await _persistir();
    return atualizada;
  }

  Future<bool> alternarAcompanhamento(String id) async {
    await _carregar();
    final acompanhando = !_acompanhando.contains(id);
    if (acompanhando) {
      _acompanhando.add(id);
    } else {
      _acompanhando.remove(id);
    }
    await _persistir();
    return acompanhando;
  }

  Future<Ocorrencia?> avaliar(String id, int nota) async {
    await _carregar();
    final indice = _cache!.indexWhere((o) => o.id == id);
    if (indice < 0 || _cache![indice].status.estaAberta) return null;

    final atualizada = _cache![indice].copyWith(
      avaliacao: nota.clamp(1, 5).toInt(),
    );
    _cache![indice] = atualizada;
    await _persistir();
    return atualizada;
  }

  Future<void> restaurarDadosIniciais() async {
    _cache = _dadosIniciais();
    _acompanhando = {};
    _confirmadas = {};
    await _persistir();
  }

  String gerarId() => DateTime.now().microsecondsSinceEpoch.toString();

  List<Ocorrencia> _dadosIniciais() {
    final hoje = DateTime.now();
    DateTime diasAtras(int d) => hoje.subtract(Duration(days: d));

    return [
      Ocorrencia(
        id: 'seed-1',
        titulo: 'Buraco grande perto do ponto de ônibus',
        descricao:
            'Buraco de cerca de 1 metro na faixa da direita. Motos desviam para a outra faixa.',
        categoria: Categoria.buraco,
        status: StatusOcorrencia.emAnalise,
        logradouro: 'Estrada de Itapecerica',
        bairro: 'Capão Redondo',
        cep: '05835-005',
        criadaEm: diasAtras(12),
        confirmacoes: 18,
        proximaServicoEssencial: true,
      ),
      Ocorrencia(
        id: 'seed-2',
        titulo: 'Rua inteira sem iluminação',
        descricao:
            'Quatro postes apagados em sequência. A rua fica totalmente escura depois das 18h.',
        categoria: Categoria.iluminacao,
        status: StatusOcorrencia.registrada,
        logradouro: 'Rua Professor Oscar Barreto Filho',
        bairro: 'Grajaú',
        cep: '04844-000',
        criadaEm: diasAtras(6),
        confirmacoes: 9,
        proximaServicoEssencial: true,
      ),
      Ocorrencia(
        id: 'seed-3',
        titulo: 'Lixo acumulado na esquina',
        descricao:
            'Descarte irregular de entulho e sacos de lixo. Risco de entupir o bueiro.',
        categoria: Categoria.lixo,
        status: StatusOcorrencia.emExecucao,
        logradouro: 'Rua Dr. Luís Aires',
        bairro: 'Itaquera',
        cep: '08220-000',
        criadaEm: diasAtras(4),
        confirmacoes: 5,
      ),
      Ocorrencia(
        id: 'seed-4',
        titulo: 'Calçada quebrada em frente à escola',
        descricao:
            'Placas de concreto soltas. Crianças e idosos precisam andar pela rua.',
        categoria: Categoria.calcada,
        status: StatusOcorrencia.registrada,
        logradouro: 'Rua Domingos de Morais',
        bairro: 'Vila Mariana',
        cep: '04010-100',
        criadaEm: diasAtras(9),
        confirmacoes: 7,
        proximaServicoEssencial: true,
      ),
      Ocorrencia(
        id: 'seed-5',
        titulo: 'Poste piscando a noite toda',
        descricao: 'Lâmpada com defeito, acende e apaga.',
        categoria: Categoria.iluminacao,
        status: StatusOcorrencia.resolvida,
        logradouro: 'Rua dos Pinheiros',
        bairro: 'Pinheiros',
        cep: '05422-001',
        criadaEm: diasAtras(15),
        resolvidaEm: diasAtras(11),
        confirmacoes: 3,
        avaliacao: 5,
      ),
      Ocorrencia(
        id: 'seed-6',
        titulo: 'Buraco na faixa de pedestres',
        descricao: 'Buraco no meio da faixa, perto do semáforo.',
        categoria: Categoria.buraco,
        status: StatusOcorrencia.resolvida,
        logradouro: 'Avenida Paulista',
        bairro: 'Bela Vista',
        cep: '01310-100',
        criadaEm: diasAtras(10),
        resolvidaEm: diasAtras(8),
        confirmacoes: 12,
        avaliacao: 4,
      ),
      Ocorrencia(
        id: 'seed-7',
        titulo: 'Entulho bloqueando a calçada',
        descricao: 'Restos de obra ocupando toda a largura da calçada.',
        categoria: Categoria.lixo,
        status: StatusOcorrencia.registrada,
        logradouro: 'Rua Direita',
        bairro: 'Sé',
        cep: '01002-000',
        criadaEm: diasAtras(2),
        confirmacoes: 1,
      ),
      Ocorrencia(
        id: 'seed-8',
        titulo: 'Lixo acumulado há semanas',
        descricao:
            'Coleta não passa com regularidade. Mau cheiro e presença de ratos.',
        categoria: Categoria.lixo,
        status: StatusOcorrencia.resolvida,
        logradouro: 'Rua Marcílio Dias',
        bairro: 'Capão Redondo',
        cep: '05861-000',
        criadaEm: diasAtras(30),
        resolvidaEm: diasAtras(9),
        confirmacoes: 14,
        avaliacao: 2,
      ),
    ];
  }
}
