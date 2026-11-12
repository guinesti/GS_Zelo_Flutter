import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';

class Secao extends StatelessWidget {
  final String titulo;
  final Widget child;
  final IconData? icone;

  const Secao({
    super.key,
    required this.titulo,
    required this.child,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: Espacos.m),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Espacos.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 20, color: AppColors.primaria),
                  const SizedBox(width: Espacos.p),
                ],
                Text(
                  titulo,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String texto;

  const LinhaInfo({super.key, required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: Espacos.p),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
