import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/services/ocorrencia_repository.dart';
import 'package:gs_zelo_flutter/services/prioridade_service.dart';
import 'package:gs_zelo_flutter/widgets/estados.dart';
import 'package:gs_zelo_flutter/widgets/ocorrencia_card.dart';

class AcompanhandoScreen extends StatefulWidget {
  const AcompanhandoScreen({super.key});

  @override
  State<AcompanhandoScreen> createState() => _AcompanhandoScreenState();
}

class _AcompanhandoScreenState extends State<AcompanhandoScreen> {
  final _repositorio = OcorrenciaRepository.instancia;
  final _prioridade = const PrioridadeService();

  List<Ocorrencia> _lista = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await _repositorio.listarAcompanhadas();
    if (!mounted) return;
    setState(() {
      _lista = _prioridade.ordenar(lista);
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhe(Ocorrencia o) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.detalheOcorrencia, arguments: o.id);
    _carregar();
  }

  Future<void> _remover(Ocorrencia o) async {
    await _repositorio.alternarAcompanhamento(o.id);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Removida de Acompanhando.'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              await _repositorio.alternarAcompanhamento(o.id);
              _carregar();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhando')),
      body: _carregando
          ? const EstadoCarregando()
          : _lista.isEmpty
          ? const EstadoMensagem(
              icone: Icons.bookmark_border,
              titulo: 'Você ainda não acompanha nenhuma ocorrência',
              descricao:
                  'Toque no marcador de uma ocorrência para receber as atualizações dela aqui.',
            )
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _lista.length,
                itemBuilder: (_, i) {
                  final o = _lista[i];
                  return OcorrenciaCard(
                    ocorrencia: o,
                    prioridade: _prioridade.classificar(o),
                    acompanhando: true,
                    onTap: () => _abrirDetalhe(o),
                    onAlternarAcompanhamento: () => _remover(o),
                  );
                },
              ),
            ),
    );
  }
}
