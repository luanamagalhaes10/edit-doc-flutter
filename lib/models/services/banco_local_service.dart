import '../../utils/validadores.dart';
import '../usuario.dart';

class EmailJaCadastrado implements Exception {}

// Simulação em memória preservada do DartPad. Recarregar apaga os dados.
class BancoDadosLocal {
  final List<Usuario> _usuarios = [];
  int _proximoId = 1;

  Future<Usuario> insert(String nome, String email, String senha) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final chave = normalizarEmail(email);
    if (_usuarios.any((usuario) => usuario.email == chave)) {
      throw EmailJaCadastrado();
    }
    final usuario = Usuario(_proximoId++, nome.trim(), chave, senha);
    _usuarios.add(usuario);
    return usuario;
  }

  Future<Usuario?> autenticar(String email, String senha) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (final usuario in _usuarios) {
      if (usuario.email == normalizarEmail(email) && usuario.senha == senha) {
        return usuario;
      }
    }
    return null;
  }

  Future<List<Usuario>> query() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<Usuario>.unmodifiable(_usuarios);
  }
}
