import 'package:material_ui/material_ui.dart';

import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/usuario.dart';

class AuthViewModel extends ChangeNotifier {
  final BancoDadosLocal _banco;
  final PreferencesService _preferencias;
  bool _restaurando = true;
  bool _ocupado = false;
  bool _consultando = false;
  bool _escuroCadastro = false;
  double _fonteCadastro = 16;
  String? _mensagem;
  DadosSessao? _sessao;
  PreferenciasUsuario _preferenciasAtuais = const PreferenciasUsuario();
  List<Usuario> _usuarios = const [];

  AuthViewModel(this._banco, this._preferencias);

  bool get restaurando => _restaurando;
  bool get ocupado => _ocupado;
  bool get consultando => _consultando;
  bool get escuroCadastro => _escuroCadastro;
  double get fonteCadastro => _fonteCadastro;
  String? get mensagem => _mensagem;
  DadosSessao? get sessao => _sessao;
  PreferenciasUsuario get preferenciasAtuais => _preferenciasAtuais;
  List<Usuario> get usuarios => _usuarios;
  ThemeMode get tema =>
      _preferenciasAtuais.escuro ? ThemeMode.dark : ThemeMode.light;

  void prepararCadastro() {
    _escuroCadastro = false;
    _fonteCadastro = 16;
    _mensagem = null;
    notifyListeners();
  }

  void selecionarTema(bool escuro) {
    _escuroCadastro = escuro;
    notifyListeners();
  }

  void selecionarFonte(double fonte) {
    _fonteCadastro = fonte;
    notifyListeners();
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    if (_ocupado) return false;
    final preferencias = PreferenciasUsuario(
      escuro: _escuroCadastro,
      fonte: _fonteCadastro,
    );
    _ocupado = true;
    _mensagem = null;
    notifyListeners();
    try {
      final usuario = await _banco.insert(nome, email, senha);
      await _preferencias.salvar(usuario.id, preferencias);
      _mensagem = 'Cadastro realizado! Entre com seu e-mail e sua senha.';
      return true;
    } on EmailJaCadastrado {
      _mensagem = 'Este e-mail já está cadastrado.';
      return false;
    } catch (_) {
      _mensagem = 'Não foi possível cadastrar. Tente novamente.';
      return false;
    } finally {
      _ocupado = false;
      notifyListeners();
    }
  }

  Future<bool> entrar(String email, String senha) async {
    if (_ocupado) return false;
    _ocupado = true;
    _mensagem = null;
    notifyListeners();
    try {
      final usuario = await _banco.autenticar(email, senha);
      if (usuario == null) {
        _mensagem = 'E-mail ou senha incorretos. Cadastre-se para começar.';
        return false;
      }
      final preferencias = await _preferencias.ler(usuario.id);
      await _preferencias.salvarSessao(usuario.id);
      _preferenciasAtuais = preferencias;
      _sessao = DadosSessao(usuario.id, usuario.nome);
      return true;
    } catch (_) {
      _mensagem = 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      _ocupado = false;
      notifyListeners();
    }
  }

  Future<bool> consultarPreferencias() async {
    final sessaoAtual = _sessao;
    if (_consultando || sessaoAtual == null) return false;
    _consultando = true;
    notifyListeners();
    try {
      _preferenciasAtuais = await _preferencias.ler(sessaoAtual.id);
      return true;
    } catch (_) {
      _mensagem = 'Não foi possível consultar as preferências.';
      return false;
    } finally {
      _consultando = false;
      notifyListeners();
    }
  }

  Future<bool> consultarUsuarios() async {
    if (_consultando || _sessao == null) return false;
    _consultando = true;
    notifyListeners();
    try {
      _usuarios = await _banco.query();
      return true;
    } catch (_) {
      _mensagem = 'Não foi possível consultar os usuários.';
      return false;
    } finally {
      _consultando = false;
      notifyListeners();
    }
  }

  Future<void> restaurarSessao() async {
    try {
      final id = await _preferencias.lerSessao();
      if (id == null) {
        _limparSessao();
        return;
      }
      for (final usuario in await _banco.query()) {
        if (usuario.id == id) {
          _preferenciasAtuais = await _preferencias.ler(id);
          _sessao = DadosSessao(id, usuario.nome);
          return;
        }
      }
      await _preferencias.salvarSessao(null);
      _limparSessao();
    } catch (_) {
      _mensagem = 'Não foi possível restaurar a sessão.';
    } finally {
      _restaurando = false;
      notifyListeners();
    }
  }

  Future<bool> alterarTema(bool escuro) async {
    final sessaoAtual = _sessao;
    if (_ocupado || _consultando || sessaoAtual == null) return false;
    _ocupado = true;
    notifyListeners();
    try {
      final novas = PreferenciasUsuario(
        escuro: escuro,
        fonte: _preferenciasAtuais.fonte,
      );
      await _preferencias.salvar(sessaoAtual.id, novas);
      _preferenciasAtuais = novas;
      return true;
    } catch (_) {
      _mensagem = 'Não foi possível alterar o tema.';
      return false;
    } finally {
      _ocupado = false;
      notifyListeners();
    }
  }

  Future<bool> sair() async {
    if (_ocupado || _consultando) return false;
    _ocupado = true;
    notifyListeners();
    try {
      await _preferencias.salvarSessao(null);
      _limparSessao();
      return true;
    } catch (_) {
      _mensagem = 'Não foi possível encerrar a sessão.';
      return false;
    } finally {
      _ocupado = false;
      notifyListeners();
    }
  }

  void _limparSessao() {
    _sessao = null;
    _usuarios = const [];
    _preferenciasAtuais = const PreferenciasUsuario();
    _mensagem = null;
  }
}
