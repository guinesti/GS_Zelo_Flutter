import 'package:flutter/material.dart';

class ZeloLogo extends StatelessWidget {
  final double tamanho;

  const ZeloLogo({super.key, this.tamanho = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_zelo.png',
      width: tamanho,
      height: tamanho,
      semanticLabel: 'Logo do Zelo',
    );
  }
}
