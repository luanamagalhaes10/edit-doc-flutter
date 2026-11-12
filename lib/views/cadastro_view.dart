import 'package:material_ui/material_ui.dart';

import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/componentes.dart';

class TelaCadastro extends StatefulWidget {
  final AuthViewModel auth;
  const TelaCadastro({super.key, required this.auth});
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;
    final sucesso = await widget.auth.cadastrar(
      _nome.text,
      _email.text,
      _senha.text,
    );
    if (!mounted) return;
    avisar(context, widget.auth.mensagem ?? 'Tente novamente.');
    if (sucesso) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.auth,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Crie sua conta')),
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
                TextFormField(
                  controller: _nome,
                  decoration: campo('Nome completo'),
                  validator: validarNome,
                ),
                const SizedBox(height: 16),
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
                DropdownButtonFormField<bool>(
                  initialValue: widget.auth.escuroCadastro,
                  decoration: campo('Tema do app'),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Tema Claro')),
                    DropdownMenuItem(value: true, child: Text('Tema Escuro')),
                  ],
                  onChanged: widget.auth.ocupado
                      ? null
                      : (valor) {
                          if (valor != null) widget.auth.selecionarTema(valor);
                        },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<double>(
                  initialValue: widget.auth.fonteCadastro,
                  decoration: campo('Tamanho da fonte'),
                  items: const [
                    DropdownMenuItem(value: 14, child: Text('Pequena (14)')),
                    DropdownMenuItem(value: 16, child: Text('Média (16)')),
                    DropdownMenuItem(value: 20, child: Text('Grande (20)')),
                  ],
                  onChanged: widget.auth.ocupado
                      ? null
                      : (valor) {
                          if (valor != null) widget.auth.selecionarFonte(valor);
                        },
                ),
                const SizedBox(height: 16),
                Text(
                  'Uma boa história começa com uma palavra.',
                  style: TextStyle(fontSize: widget.auth.fonteCadastro),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.auth.ocupado ? null : _cadastrar,
                  child: Text(
                    widget.auth.ocupado ? 'Cadastrando...' : 'Cadastrar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
