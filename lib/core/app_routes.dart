import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/models/bairro.dart';
import 'package:gs_zelo_flutter/screens/ocorrencias/detalhe_ocorrencia_screen.dart';
import 'package:gs_zelo_flutter/screens/ocorrencias/nova_ocorrencia_screen.dart';
import 'package:gs_zelo_flutter/screens/onboarding/onboarding_screen.dart';
import 'package:gs_zelo_flutter/screens/shell/home_shell.dart';
import 'package:gs_zelo_flutter/screens/splash/splash_screen.dart';
import 'package:gs_zelo_flutter/screens/bairros/detalhe_bairro_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const detalheOcorrencia = '/ocorrencia';
  static const novaOcorrencia = '/ocorrencia/nova';
  static const detalheBairro = '/bairro';

  static Route<dynamic> gerarRota(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _rota(settings, const SplashScreen());
      case onboarding:
        return _rota(settings, const OnboardingScreen());
      case home:
        return _rota(settings, const HomeShell());
      case detalheOcorrencia:
        final id = settings.arguments as String;
        return _rota(settings, DetalheOcorrenciaScreen(ocorrenciaId: id));
      case novaOcorrencia:
        return _rota(settings, const NovaOcorrenciaScreen());
      case detalheBairro:
        final bairro = settings.arguments as Bairro;
        return _rota(settings, DetalheBairroScreen(bairro: bairro));
      default:
        return _rota(settings, const HomeShell());
    }
  }

  static MaterialPageRoute<dynamic> _rota(
    RouteSettings settings,
    Widget tela,
  ) => MaterialPageRoute(builder: (_) => tela, settings: settings);
}
