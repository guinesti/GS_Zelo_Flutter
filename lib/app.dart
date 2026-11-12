import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_routes.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';

class ZeloApp extends StatelessWidget {
  const ZeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zelo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.gerarRota,
    );
  }
}
