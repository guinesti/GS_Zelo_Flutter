import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/services/preferences_service.dart';
import 'package:gs_zelo_flutter/widgets/zelo_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duracao = Duration(seconds: 2);

  final _preferences = PreferencesService();

  @override
  void initState() {
    super.initState();
    _decidirProximaTela();
  }

  Future<void> _decidirProximaTela() async {
    final espera = Future<void>.delayed(_duracao);
    final onboardingVisto = await _preferences.onboardingFoiVisto();
    await espera;

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      onboardingVisto ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ZeloLogo(tamanho: 140),
            const SizedBox(height: Espacos.m),
            Text(
              'Zelo',
              style: tema.textTheme.displaySmall?.copyWith(
                color: AppColors.primaria,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Espacos.p),
            Text(
              'Zeladoria colaborativa',
              style: tema.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: Espacos.g * 2),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
