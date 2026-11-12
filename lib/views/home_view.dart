import 'package:material_ui/material_ui.dart';

import '../models/usuario.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/componentes.dart';

class TelaHome extends StatelessWidget {
  final AuthViewModel auth;
  final DadosSessao sessao;
  const TelaHome({super.key, required this.auth, required this.sessao});

  Future<void> _mostrarPreferencias(BuildContext context) async {
    final sucesso = await auth.consultarPreferencias();
    if (!context.mounted) return;
    if (!sucesso) {
      avisar(context, auth.mensagem ?? 'Tente novamente.');
      return;
    }
    final preferencias = auth.preferenciasAtuais;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suas preferências'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Tema'),
              subtitle: Text(preferencias.escuro ? 'Escuro' : 'Claro'),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Tamanho da fonte'),
              subtitle: Text('${preferencias.fonte.toInt()}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarUsuarios(BuildContext context) async {
    final sucesso = await auth.consultarUsuarios();
    if (!context.mounted) return;
    if (!sucesso) {
      avisar(context, auth.mensagem ?? 'Tente novamente.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuários no banco local'),
        content: SizedBox(
          width: 420,
          height: 260,
          child: ListView.builder(
            itemCount: auth.usuarios.length,
            itemBuilder: (context, index) {
              final usuario = auth.usuarios[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${usuario.id}')),
                title: Text(usuario.nome),
                subtitle: Text(usuario.email),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: auth,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Entrelinhas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: auth.consultando
                ? null
                : () {
                    auth.sair();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
          ),
        ],
      ),
      bottomNavigationBar: const Rodape(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.auto_stories, size: 64),
              const SizedBox(height: 16),
              Text(
                'Olá, ${sessao.nome}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Este é seu espaço de leitura e organização.',
                style: TextStyle(fontSize: auth.preferenciasAtuais.fonte),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Preferências do usuário'),
                  subtitle: const Text(
                    'Veja o tema e o tamanho da fonte escolhidos.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: auth.consultando
                      ? null
                      : () => _mostrarPreferencias(context),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Usuários no banco local'),
                  subtitle: const Text('Consulte os leitores cadastrados.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: auth.consultando
                      ? null
                      : () => _mostrarUsuarios(context),
                ),
              ),
              if (auth.consultando)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 24),
              const Text(
                'Versão de estudo: os dados são simulados em memória e '
                'se perdem ao recarregar. O CRUD será desenvolvido na próxima fase.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
