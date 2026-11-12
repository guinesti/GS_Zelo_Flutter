class Bairro {
  final int id;
  final String nome;
  final String municipio;

  const Bairro({required this.id, required this.nome, required this.municipio});

  factory Bairro.fromJson(Map<String, dynamic> json) {
    final municipio = json['municipio'] as Map<String, dynamic>?;
    return Bairro(
      id: json['id'] as int,
      nome: json['nome'] as String,
      municipio: municipio?['nome'] as String? ?? '',
    );
  }
}
