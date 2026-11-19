import 'package:material_ui/material_ui.dart';

import 'models/services/banco_local_service.dart';
import 'models/services/preferences_service.dart';
import 'models/usuario.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatefulWidget {
  const MeuApp({super.key});
  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  late final AuthViewModel _auth = AuthViewModel(
    BancoDadosLocal(),
    PreferencesService(),
  );

  @override
  void initState() {
    super.initState();
    _auth.restaurarSessao();
  }

  Widget _inicio(BuildContext context) {
    if (_auth.restaurando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final sessao = _auth.sessao;
    return sessao == null
        ? TelaLogin(auth: _auth)
        : TelaHome(key: ValueKey(sessao.id), auth: _auth, sessao: sessao);
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _auth,
    builder: (context, _) => MaterialApp(
      title: 'Entrelinhas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _auth.tema,
      initialRoute: '/',
      routes: {
        '/': (context) => ListenableBuilder(
          listenable: _auth,
          builder: (context, _) => _inicio(context),
        ),
        '/cadastro': (context) => TelaCadastro(auth: _auth),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final dados = settings.arguments;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) =>
                dados is DadosSessao && dados.id == _auth.sessao?.id
                ? TelaHome(auth: _auth, sessao: dados)
                : TelaLogin(auth: _auth),
          );
        }
        return null;
      },
    ),
  );
}
