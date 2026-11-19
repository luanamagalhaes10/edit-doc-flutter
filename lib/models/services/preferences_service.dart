import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';

class PreferencesService {
  static const _sessao = 'entrelinhas.sessao';

  Future<void> salvar(int id, PreferenciasUsuario preferencias) async {
    final dados = await SharedPreferences.getInstance();
    if (!await dados.setBool(
          'entrelinhas.usuario.$id.tema',
          preferencias.escuro,
        ) ||
        !await dados.setString(
          'entrelinhas.usuario.$id.fonte',
          preferencias.fonte.toString(),
        )) {
      throw StateError('Falha ao salvar preferências.');
    }
  }

  Future<PreferenciasUsuario> ler(int id) async {
    final dados = await SharedPreferences.getInstance();
    return PreferenciasUsuario(
      escuro: dados.getBool('entrelinhas.usuario.$id.tema') ?? false,
      fonte:
          double.tryParse(
            dados.getString('entrelinhas.usuario.$id.fonte') ?? '',
          ) ??
          16,
    );
  }

  Future<int?> lerSessao() async {
    final dados = await SharedPreferences.getInstance();
    return int.tryParse(dados.getString(_sessao) ?? '');
  }

  Future<void> salvarSessao(int? id) async {
    final dados = await SharedPreferences.getInstance();
    final salvo = id == null
        ? await dados.remove(_sessao)
        : await dados.setString(_sessao, id.toString());
    if (!salvo) throw StateError('Falha ao atualizar a sessão.');
  }
}
