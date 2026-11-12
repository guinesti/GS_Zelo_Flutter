import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/core/texto_utils.dart';
import 'package:gs_zelo_flutter/core/view_state.dart';
import 'package:gs_zelo_flutter/models/categoria.dart';
import 'package:gs_zelo_flutter/models/endereco.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/models/status_ocorrencia.dart';
import 'package:gs_zelo_flutter/services/api_exception.dart';
import 'package:gs_zelo_flutter/services/cep_service.dart';
import 'package:gs_zelo_flutter/services/ocorrencia_repository.dart';
import 'package:gs_zelo_flutter/widgets/consulta_cep_card.dart';
import 'package:gs_zelo_flutter/widgets/seletor_categoria.dart';

class NovaOcorrenciaScreen extends StatefulWidget {
  const NovaOcorrenciaScreen({super.key});

  @override
  State<NovaOcorrenciaScreen> createState() => _NovaOcorrenciaScreenState();
}

class _NovaOcorrenciaScreenState extends State<NovaOcorrenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cepService = CepService();
  final _repositorio = OcorrenciaRepository.instancia;

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();

  Categoria _categoria = Categoria.buraco;
  bool _proximaServicoEssencial = false;
  bool _anonima = false;
  bool _salvando = false;

  ViewState _estadoCep = ViewState.inicial;
  Endereco? _endereco;
  String? _erroCep;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _estadoCep = ViewState.carregando;
      _erroCep = null;
    });

    try {
      final endereco = await _cepService.buscar(_cepController.text);
      if (!mounted) return;
      setState(() {
        _endereco = endereco;
        _estadoCep = ViewState.sucesso;
        _logradouroController.text = endereco.logradouro;
        _bairroController.text = endereco.bairro;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _estadoCep = ViewState.erro;
        _erroCep = e.mensagem;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final cepDigitos = TextoUtils.somenteDigitos(_cepController.text);
    final nova = Ocorrencia(
      id: _repositorio.gerarId(),
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoria,
      status: StatusOcorrencia.registrada,
      logradouro: _logradouroController.text.trim(),
      bairro: _bairroController.text.trim(),
      cep: cepDigitos.length == 8
          ? '${cepDigitos.substring(0, 5)}-${cepDigitos.substring(5)}'
          : '',
      criadaEm: DateTime.now(),
      proximaServicoEssencial: _proximaServicoEssencial,
      anonima: _anonima,
    );

    final resultado = await _repositorio.registrar(nova);
    if (!mounted) return;

    final mensagem = resultado.agrupada
        ? 'Já existia uma ocorrência igual neste local. Sua confirmação foi somada a ela.'
        : 'Ocorrência registrada! Você vai acompanhar o andamento.';
    Navigator.of(context).pop(mensagem);
  }

  String? _obrigatorio(String? valor, String campo) =>
      (valor == null || valor.trim().isEmpty) ? 'Informe $campo' : null;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ocorrência')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Espacos.m),
          children: [
            _titulo(tema, 'Categoria'),
            SeletorCategoria(
              selecionada: _categoria,
              permitirTodas: false,
              onSelecionar: (c) {
                if (c != null) setState(() => _categoria = c);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Espacos.m),
                  TextFormField(
                    controller: _tituloController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 60,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Ex.: Buraco em frente ao número 120',
                    ),
                    validator: (v) => _obrigatorio(v, 'um título'),
                  ),
                  const SizedBox(height: Espacos.p),
                  TextFormField(
                    controller: _descricaoController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: Espacos.g),
                  _tituloSemPadding(tema, 'Local'),
                  const SizedBox(height: Espacos.p),
                  TextFormField(
                    controller: _cepController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onFieldSubmitted: (_) => _buscarCep(),
                    decoration: InputDecoration(
                      labelText: 'CEP',
                      hintText: 'Somente números',
                      suffixIcon: IconButton(
                        tooltip: 'Buscar CEP',
                        icon: const Icon(Icons.search),
                        onPressed: _estadoCep == ViewState.carregando
                            ? null
                            : _buscarCep,
                      ),
                    ),
                  ),
                  const SizedBox(height: Espacos.p),
                  ConsultaCepCard(
                    estado: _estadoCep,
                    endereco: _endereco,
                    erro: _erroCep,
                    onTentarNovamente: _buscarCep,
                  ),
                  const SizedBox(height: Espacos.m),
                  TextFormField(
                    controller: _logradouroController,
                    decoration: const InputDecoration(
                      labelText: 'Rua / referência',
                    ),
                    validator: (v) =>
                        _obrigatorio(v, 'a rua ou uma referência'),
                  ),
                  const SizedBox(height: Espacos.m),
                  TextFormField(
                    controller: _bairroController,
                    decoration: const InputDecoration(labelText: 'Bairro'),
                    validator: (v) => _obrigatorio(v, 'o bairro'),
                  ),
                  const SizedBox(height: Espacos.m),
                  CheckboxListTile(
                    value: _proximaServicoEssencial,
                    onChanged: (v) =>
                        setState(() => _proximaServicoEssencial = v ?? false),
                    title: const Text(
                      'Perto de escola, hospital ou ponto de ônibus',
                    ),
                    subtitle: const Text('Aumenta a prioridade'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _anonima,
                    onChanged: (v) => setState(() => _anonima = v),
                    title: const Text('Registrar de forma anônima'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: Espacos.m),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _salvando ? null : _salvar,
                      icon: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Enviar ocorrência'),
                    ),
                  ),
                  const SizedBox(height: Espacos.p),
                  Text(
                    'O registro fica salvo no celular, mesmo sem internet.',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
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

  Widget _titulo(ThemeData tema, String texto) => Padding(
    padding: const EdgeInsets.fromLTRB(Espacos.m, 0, Espacos.m, Espacos.p),
    child: _tituloSemPadding(tema, texto),
  );

  Widget _tituloSemPadding(ThemeData tema, String texto) => Text(
    texto,
    style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
  );
}
