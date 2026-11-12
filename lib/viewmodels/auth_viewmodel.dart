import 'package:material_ui/material_ui.dart';

import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/usuario.dart';

class AuthViewModel extends ChangeNotifier {
  final BancoDadosLocal _banco;
  final PreferencesService _preferencias;
  bool _ocupado = false;
  bool _consultando = false;
  bool _escuroCadastro = false;
  double _fonteCadastro = 16;
  String? _mensagem;
  DadosSessao? _sessao;
  PreferenciasUsuario _preferenciasAtuais = const PreferenciasUsuario();
  List<Usuario> _usuarios = const [];

  AuthViewModel(this._banco, this._preferencias);

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
      _preferenciasAtuais = await _preferencias.ler(usuario.id);
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

  void sair() {
    _sessao = null;
    _usuarios = const [];
    _preferenciasAtuais = const PreferenciasUsuario();
    _mensagem = null;
    notifyListeners();
  }
}
