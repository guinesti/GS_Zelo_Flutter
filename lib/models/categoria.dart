enum Categoria {
  buraco('Buraco na via', 5),
  iluminacao('Iluminação apagada', 4),
  lixo('Lixo acumulado', 3),
  calcada('Calçada quebrada', 4),
  outros('Outros', 2);

  const Categoria(this.label, this.peso);

  final String label;
  final int peso;

  static Categoria fromName(String nome) => Categoria.values.firstWhere(
    (c) => c.name == nome,
    orElse: () => Categoria.outros,
  );
}
