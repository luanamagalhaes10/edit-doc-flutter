// Entidade preparada para a Fase 2. Ainda não há CRUD nesta entrega.
class Documento {
  final int id;
  final int usuarioId;
  final String titulo;
  final String conteudo;

  const Documento({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.conteudo,
  });
}
