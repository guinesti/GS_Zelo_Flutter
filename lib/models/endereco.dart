class Endereco {
  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;

  const Endereco({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
    );
  }

  String get resumo => [
    logradouro,
    bairro,
    '$cidade/$uf',
  ].where((p) => p.trim().isNotEmpty).join(', ');
}
