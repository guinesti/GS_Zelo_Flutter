import 'package:flutter/material.dart';
import 'package:gs_zelo_flutter/screens/acompanhando/acompanhando_screen.dart';
import 'package:gs_zelo_flutter/screens/bairros/bairros_screen.dart';
import 'package:gs_zelo_flutter/screens/ocorrencias/ocorrencias_screen.dart';
import 'package:gs_zelo_flutter/screens/sobre/sobre_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  Widget _telaAtual() => switch (_indice) {
    0 => const OcorrenciasScreen(),
    1 => const BairrosScreen(),
    2 => const AcompanhandoScreen(),
    _ => const SobreScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telaAtual(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Ocorrências',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city),
            label: 'Bairros',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Acompanhando',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}
