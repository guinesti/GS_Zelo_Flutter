import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';

class CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final String dica;
  final ValueChanged<String> onChanged;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.dica,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espacos.m,
        Espacos.m,
        Espacos.m,
        Espacos.p,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: dica,
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar busca',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}
