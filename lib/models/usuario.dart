class Usuario {
  final int id;
  final String nome;
  final String email;
  final String senha;

  const Usuario(this.id, this.nome, this.email, this.senha);
}

class DadosSessao {
  final int id;
  final String nome;

  const DadosSessao(this.id, this.nome);
}

class PreferenciasUsuario {
  final bool escuro;
  final double fonte;

  const PreferenciasUsuario({this.escuro = false, this.fonte = 16});
}
