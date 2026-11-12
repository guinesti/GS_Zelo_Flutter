import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gs_zelo_flutter/core/texto_utils.dart';
import 'package:gs_zelo_flutter/models/endereco.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class CepService {
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  CepService({http.Client? client}) : _client = client ?? http.Client();

  Future<Endereco> buscar(String cepDigitado) async {
    final cep = TextoUtils.somenteDigitos(cepDigitado);
    if (cep.length != 8) {
      throw const ApiException('O CEP precisa ter 8 números.');
    }

    final uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    try {
      final resposta = await _client.get(uri).timeout(_timeout);

      if (resposta.statusCode != 200) {
        throw ApiException(
          'Não foi possível consultar o CEP (${resposta.statusCode}).',
        );
      }

      final json =
          jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;

      if (json.containsKey('erro')) {
        throw const ApiException('CEP não encontrado.');
      }

      return Endereco.fromJson(json);
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
      throw const ApiException('Não foi possível consultar o CEP.');
    }
  }
}
