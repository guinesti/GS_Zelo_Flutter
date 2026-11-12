import 'categoria.dart';
import 'status_ocorrencia.dart';

class Ocorrencia {
  final String id;
  final String titulo;
  final String descricao;
  final Categoria categoria;
  final StatusOcorrencia status;
  final String logradouro;
  final String bairro;
  final String cep;
  final DateTime criadaEm;
  final DateTime? resolvidaEm;
  final int confirmacoes;
  final bool proximaServicoEssencial;
  final bool anonima;
  final int? avaliacao;

  const Ocorrencia({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.status,
    required this.logradouro,
    required this.bairro,
    required this.cep,
    required this.criadaEm,
    this.resolvidaEm,
    this.confirmacoes = 0,
    this.proximaServicoEssencial = false,
    this.anonima = false,
    this.avaliacao,
  });

  String get endereco => logradouro.isEmpty ? bairro : '$logradouro — $bairro';

  int diasEmAberto({DateTime? agora}) {
    final fim = resolvidaEm ?? agora ?? DateTime.now();
    return fim.difference(criadaEm).inDays;
  }

  Ocorrencia copyWith({
    StatusOcorrencia? status,
    DateTime? resolvidaEm,
    int? confirmacoes,
    int? avaliacao,
  }) {
    return Ocorrencia(
      id: id,
      titulo: titulo,
      descricao: descricao,
      categoria: categoria,
      status: status ?? this.status,
      logradouro: logradouro,
      bairro: bairro,
      cep: cep,
      criadaEm: criadaEm,
      resolvidaEm: resolvidaEm ?? this.resolvidaEm,
      confirmacoes: confirmacoes ?? this.confirmacoes,
      proximaServicoEssencial: proximaServicoEssencial,
      anonima: anonima,
      avaliacao: avaliacao ?? this.avaliacao,
    );
  }

  factory Ocorrencia.fromJson(Map<String, dynamic> json) {
    return Ocorrencia(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String? ?? '',
      categoria: Categoria.fromName(json['categoria'] as String),
      status: StatusOcorrencia.fromName(json['status'] as String),
      logradouro: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cep: json['cep'] as String? ?? '',
      criadaEm: DateTime.parse(json['criadaEm'] as String),
      resolvidaEm: json['resolvidaEm'] == null
          ? null
          : DateTime.parse(json['resolvidaEm'] as String),
      confirmacoes: json['confirmacoes'] as int? ?? 0,
      proximaServicoEssencial:
          json['proximaServicoEssencial'] as bool? ?? false,
      anonima: json['anonima'] as bool? ?? false,
      avaliacao: json['avaliacao'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'categoria': categoria.name,
    'status': status.name,
    'logradouro': logradouro,
    'bairro': bairro,
    'cep': cep,
    'criadaEm': criadaEm.toIso8601String(),
    'resolvidaEm': resolvidaEm?.toIso8601String(),
    'confirmacoes': confirmacoes,
    'proximaServicoEssencial': proximaServicoEssencial,
    'anonima': anonima,
    'avaliacao': avaliacao,
  };
}
