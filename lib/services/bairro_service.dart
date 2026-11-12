import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gs_zelo_flutter/models/bairro.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class BairroService {
  static const _codigoSaoPaulo = 3550308;
  static const _baseUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades';
  static const _timeout = Duration(seconds: 12);

  final http.Client _client;

  BairroService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Bairro>> listarBairros({
    int codigoMunicipio = _codigoSaoPaulo,
  }) async {
    final uri = Uri.parse('$_baseUrl/municipios/$codigoMunicipio/distritos');

    try {
      final resposta = await _client.get(uri).timeout(_timeout);

      if (resposta.statusCode != 200) {
        throw ApiException(
          'O servidor do IBGE respondeu com erro (${resposta.statusCode}).',
        );
      }

      final dados =
          jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
      final bairros =
          dados
              .map((item) => Bairro.fromJson(item as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome));
      return bairros;
    } on SocketException {
      throw const ApiException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Falha de comunicação com o servidor. Tente novamente.',
      );
    } on TimeoutException {
      throw const ApiException(
        'O servidor demorou para responder. Tente novamente.',
      );
    } on FormatException {
      throw const ApiException(
        'Os dados recebidos estão em um formato inesperado.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Não foi possível carregar os bairros.');
    }
  }
}
