class TextoUtils {
  TextoUtils._();

  static const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  static const _semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  static String normalizar(String texto) {
    final buffer = StringBuffer();
    for (final char in texto.split('')) {
      final indice = _comAcento.indexOf(char);
      buffer.write(indice >= 0 ? _semAcento[indice] : char);
    }
    return buffer.toString().toLowerCase().trim();
  }

  static String somenteDigitos(String texto) =>
      texto.replaceAll(RegExp(r'[^0-9]'), '');

  static String formatarData(DateTime data) {
    String doisDigitos(int n) => n.toString().padLeft(2, '0');
    return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year}';
  }

  static String tempoDecorrido(DateTime data, {DateTime? agora}) {
    final dias = (agora ?? DateTime.now()).difference(data).inDays;
    if (dias <= 0) return 'hoje';
    if (dias == 1) return 'há 1 dia';
    return 'há $dias dias';
  }
}
