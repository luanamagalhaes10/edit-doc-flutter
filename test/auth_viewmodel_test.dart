import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/utils/validadores.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('valida nome, senha e domínio estrito', () {
    expect(validarNome('Luana Magalhães'), isNull);
    expect(validarNome('Luana'), isNotNull);
    expect(validarSenha('12345'), isNotNull);
    expect(validarSenha('123456'), isNull);
    for (final email in ['pessoa@exemplo.com', 'Pessoa@exemplo.com.br']) {
      expect(validarEmail(email), isNull);
    }
    for (final email in [
      'sem-arroba.com',
      'pessoa@exemplo.org',
      'pessoa@exemplo.com.evil',
      'pessoa@@exemplo.com',
      'a b@exemplo.com',
    ]) {
      expect(validarEmail(email), isNotNull);
    }
  });

  test('cadastro, duplicidade, autenticação, preferências e logout', () async {
    final auth = AuthViewModel(BancoDadosLocal(), PreferencesService());
    addTearDown(auth.dispose);
    var notificacoes = 0;
    auth.addListener(() => notificacoes++);
    auth.selecionarTema(true);
    auth.selecionarFonte(20);
    final cadastro = auth.cadastrar(
      'Luana Magalhães',
      'LUANA@EXEMPLO.COM',
      '123456',
    );
    expect(auth.ocupado, isTrue);
    expect(await cadastro, isTrue);
    expect(auth.ocupado, isFalse);
    expect(
      await auth.cadastrar('Outra Pessoa', 'luana@exemplo.com', 'abcdef'),
      isFalse,
    );
    expect(auth.mensagem, contains('já está cadastrado'));
    expect(await auth.entrar('luana@exemplo.com', 'errada'), isFalse);
    expect(auth.sessao, isNull);
    expect(await auth.entrar(' luana@exemplo.com ', '123456'), isTrue);
    expect(auth.sessao!.nome, 'Luana Magalhães');
    expect(auth.preferenciasAtuais.escuro, isTrue);
    expect(auth.preferenciasAtuais.fonte, 20);
    expect(await auth.consultarPreferencias(), isTrue);
    expect(await auth.consultarUsuarios(), isTrue);
    expect(auth.usuarios.length, 1);
    expect(notificacoes, greaterThan(10));
    expect(await auth.alterarTema(false), isTrue);
    final restaurada = AuthViewModel(BancoDadosLocal(), PreferencesService());
    addTearDown(restaurada.dispose);
    await restaurada.restaurarSessao();
    expect(restaurada.sessao?.nome, 'Luana Magalhães');
    expect(restaurada.preferenciasAtuais.escuro, isFalse);
    expect(restaurada.preferenciasAtuais.fonte, 20);
    expect(await auth.sair(), isTrue);
    await restaurada.restaurarSessao();
    expect(restaurada.sessao, isNull);
    expect(auth.sessao, isNull);
    expect(auth.usuarios, isEmpty);
    expect(auth.preferenciasAtuais.escuro, isFalse);
  });

  test(
    'banco mantém usuários entre instâncias e retorna lista imutável',
    () async {
      final banco = BancoDadosLocal();
      await banco.insert('Uma Pessoa', 'pessoa@exemplo.com.br', '123456');
      final usuarios = await banco.query();
      expect(() => usuarios.clear(), throwsUnsupportedError);
      expect(await BancoDadosLocal().query(), hasLength(1));
    },
  );
}
