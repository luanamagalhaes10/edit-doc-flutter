import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/validadores.dart';
import '../usuario.dart';

class EmailJaCadastrado implements Exception {}

class BancoDadosLocal {
  static const _chave = 'entrelinhas.usuarios';

  Future<Usuario> insert(String nome, String email, String senha) async {
    final dados = await SharedPreferences.getInstance();
    final usuarios = _ler(dados);
    final chave = normalizarEmail(email);
    if (usuarios.any((usuario) => usuario.email == chave)) {
      throw EmailJaCadastrado();
    }

    final id = usuarios.isEmpty ? 1 : usuarios.last.id + 1;
    final random = Random.secure();
    final sal = base64UrlEncode(List.generate(16, (_) => random.nextInt(256)));
    final usuario = Usuario(
      id,
      nome.trim(),
      chave,
      '$sal:${_hash(sal, senha)}',
    );
    usuarios.add(usuario);
    if (!await dados.setString(
      _chave,
      jsonEncode(
        usuarios
            .map(
              (u) => {
                'id': u.id,
                'nome': u.nome,
                'email': u.email,
                'senha': u.senha,
              },
            )
            .toList(),
      ),
    )) {
      throw StateError('Falha ao salvar usuário.');
    }
    return usuario;
  }

  Future<Usuario?> autenticar(String email, String senha) async {
    final chave = normalizarEmail(email);
    for (final usuario in await query()) {
      if (usuario.email == chave) {
        final credencial = usuario.senha.split(':');
        return _hash(credencial.first, senha) == credencial.last
            ? usuario
            : null;
      }
    }
    return null;
  }

  Future<List<Usuario>> query() async {
    return List<Usuario>.unmodifiable(
      _ler(await SharedPreferences.getInstance()),
    );
  }

  List<Usuario> _ler(SharedPreferences dados) {
    final registros = jsonDecode(dados.getString(_chave) ?? '[]') as List;
    return registros.map((registro) {
      final json = registro as Map<String, dynamic>;
      return Usuario(
        json['id'] as int,
        json['nome'] as String,
        json['email'] as String,
        json['senha'] as String,
      );
    }).toList();
  }

  String _hash(String sal, String senha) =>
      Hmac(sha256, utf8.encode(senha)).convert(utf8.encode(sal)).toString();
}
