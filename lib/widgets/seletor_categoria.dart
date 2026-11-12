import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/core/app_theme.dart';
import 'package:gs_zelo_flutter/models/categoria.dart';
import 'package:gs_zelo_flutter/widgets/visual_ocorrencia.dart';

class SeletorCategoria extends StatelessWidget {
  final Categoria? selecionada;
  final ValueChanged<Categoria?> onSelecionar;
  final bool permitirTodas;

  const SeletorCategoria({
    super.key,
    required this.selecionada,
    required this.onSelecionar,
    this.permitirTodas = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
        children: [
          if (permitirTodas)
            _chip(
              rotulo: 'Todas',
              icone: Icons.apps,
              selecionado: selecionada == null,
              onTap: () => onSelecionar(null),
            ),
          for (final categoria in Categoria.values)
            _chip(
              rotulo: categoria.label,
              icone: VisualOcorrencia.iconeCategoria(categoria),
              selecionado: selecionada == categoria,
              onTap: () => onSelecionar(categoria),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String rotulo,
    required IconData icone,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: Espacos.p),
      child: ChoiceChip(
        label: Text(rotulo),
        avatar: Icon(
          icone,
          size: 18,
          color: selecionado ? Colors.white : AppColors.primaria,
        ),
        selected: selecionado,
        showCheckmark: false,
        selectedColor: AppColors.primaria,
        labelStyle: TextStyle(
          color: selecionado ? Colors.white : Colors.black87,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
