import 'package:material_ui/material_ui.dart';

import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/componentes.dart';

class TelaLogin extends StatefulWidget {
  final AuthViewModel auth;
  const TelaLogin({super.key, required this.auth});
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    final sucesso = await widget.auth.entrar(_email.text, _senha.text);
    if (!mounted) return;
    if (sucesso) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: widget.auth.sessao,
      );
    } else {
      avisar(context, widget.auth.mensagem ?? 'Tente novamente.');
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.auth,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Entrelinhas')),
      bottomNavigationBar: const Rodape(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.menu_book, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Sua leitura começa aqui',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre para acessar seus documentos e preferências.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  decoration: campo('E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: validarEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senha,
                  decoration: campo('Senha'),
                  obscureText: true,
                  validator: validarSenha,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.auth.ocupado ? null : _entrar,
                  child: Text(widget.auth.ocupado ? 'Entrando...' : 'Entrar'),
                ),
                TextButton(
                  onPressed: widget.auth.ocupado
                      ? null
                      : () {
                          widget.auth.prepararCadastro();
                          Navigator.pushNamed(context, '/cadastro');
                        },
                  child: const Text('Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
