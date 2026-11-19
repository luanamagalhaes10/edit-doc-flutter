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

  factory Documento.fromJson(Map<String, dynamic> json) => Documento(
    id: json['id'] as int,
    usuarioId: json['usuarioId'] as int,
    titulo: json['titulo'] as String,
    conteudo: json['conteudo'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'titulo': titulo,
    'conteudo': conteudo,
  };
}
