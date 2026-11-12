class ApiException implements Exception {
  final String mensagem;

  const ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}
