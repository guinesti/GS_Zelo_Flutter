import 'package:gs_zelo_flutter/models/ocorrencia.dart';
import 'package:gs_zelo_flutter/models/prioridades.dart';

class PrioridadeService {
  const PrioridadeService();

  static const _pesoGravidade = 3.0;
  static const _pesoConfirmacao = 1.5;
  static const _pesoDia = 0.5;
  static const _bonusServicoEssencial = 8.0;
  static const _limiteDias = 30;

  double pontuacao(Ocorrencia o, {DateTime? agora}) {
    if (!o.status.estaAberta) return 0;

    final dias = o.diasEmAberto(agora: agora).clamp(0, _limiteDias);
    final pontos =
        o.categoria.peso * _pesoGravidade +
        o.confirmacoes * _pesoConfirmacao +
        dias * _pesoDia +
        (o.proximaServicoEssencial ? _bonusServicoEssencial : 0);
    return pontos.toDouble();
  }

  Prioridade classificar(Ocorrencia o, {DateTime? agora}) {
    final pontos = pontuacao(o, agora: agora);
    if (pontos >= 30) return Prioridade.alta;
    if (pontos >= 18) return Prioridade.media;
    return Prioridade.baixa;
  }

  List<Ocorrencia> ordenar(List<Ocorrencia> lista) {
    final copia = [...lista];
    copia.sort((a, b) => pontuacao(b).compareTo(pontuacao(a)));
    return copia;
  }
}
