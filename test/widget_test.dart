import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/models/usuario.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('navega pelas três telas, valida e limpa histórico ao sair', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MeuApp());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(
      find.text('A senha precisa ter pelo menos 6 caracteres.'),
      findsOneWidget,
    );
    expect(find.textContaining('Use um e-mail válido'), findsOneWidget);

    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Leitora Teste');
    await tester.enterText(campos.at(1), 'leitora@exemplo.com.br');
    await tester.enterText(campos.at(2), '123456');
    await tester.tap(find.text('Tema Claro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema Escuro').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Média (16)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grande (20)').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Sua leitura começa aqui'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'leitora@exemplo.com.br',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Leitora Teste!'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Olá, Leitora Teste!'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Preferências do usuário'));
    await tester.pumpAndSettle();
    expect(find.text('Suas preferências'), findsOneWidget);
    expect(find.text('Escuro'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuários no banco local'));
    await tester.pumpAndSettle();
    expect(find.text('Leitora Teste'), findsOneWidget);
    expect(find.text('leitora@exemplo.com.br'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    expect(find.text('Sua leitura começa aqui'), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reabrir /home restaura sessão, tema e documentos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/home';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.runAsync(() async {
      final usuario = await BancoDadosLocal().insert(
        'Leitora Teste',
        'leitora@exemplo.com',
        '123456',
      );
      final preferencias = PreferencesService();
      await preferencias.salvar(
        usuario.id,
        const PreferenciasUsuario(escuro: true),
      );
      await preferencias.salvarSessao(usuario.id);
      await DocumentoStorageService().criar(
        usuario.id,
        'Documento revisado',
        'Conteúdo final',
      );
    });

    await tester.pumpWidget(const MeuApp());
    await tester.pumpAndSettle();
    final documento = find.text('Documento revisado');
    expect(documento, findsOneWidget);
    expect(Theme.of(tester.element(documento)).brightness, Brightness.dark);
    expect(find.text('Olá, Leitora Teste!'), findsOneWidget);
  });
}
