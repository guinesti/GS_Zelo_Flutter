enum StatusOcorrencia {
  registrada('Registrada'),
  emAnalise('Em análise'),
  emExecucao('Em execução'),
  resolvida('Resolvida');

  const StatusOcorrencia(this.label);

  final String label;

  bool get estaAberta => this != StatusOcorrencia.resolvida;

  static StatusOcorrencia fromName(String nome) =>
      StatusOcorrencia.values.firstWhere(
        (s) => s.name == nome,
        orElse: () => StatusOcorrencia.registrada,
      );
}
