class IndicadoresBairro {
  final int abertas;
  final int resolvidas;
  final int confirmacoes;
  final double? tempoMedioResolucaoDias;
  final double? notaMedia;

  const IndicadoresBairro({
    required this.abertas,
    required this.resolvidas,
    required this.confirmacoes,
    this.tempoMedioResolucaoDias,
    this.notaMedia,
  });

  int get total => abertas + resolvidas;

  double get percentualResolvidas => total == 0 ? 0 : resolvidas / total * 100;
}
