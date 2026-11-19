import 'package:material_ui/material_ui.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';
import '../models/usuario.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'editor_view.dart';
import 'widgets/componentes.dart';

class TelaHome extends StatefulWidget {
  final AuthViewModel auth;
  final DadosSessao sessao;
  const TelaHome({super.key, required this.auth, required this.sessao});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  AuthViewModel get auth => widget.auth;
  DadosSessao get sessao => widget.sessao;
  late final documentos = DocumentosViewModel(
    DocumentoStorageService(),
    sessao.id,
  );

  @override
  void initState() {
    super.initState();
    documentos.carregar();
  }

  @override
  void dispose() {
    documentos.dispose();
    super.dispose();
  }

  void _abrirEditor([Documento? documento]) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TelaEditor(documentos: documentos, documento: documento),
      ),
    );
  }

  Future<void> _excluir(Documento documento) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir documento?'),
        content: Text(documento.titulo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou == true && mounted) await documentos.excluir(documento.id);
  }

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
            tooltip: 'Alternar tema',
            icon: Icon(
              auth.preferenciasAtuais.escuro
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: auth.ocupado || auth.consultando
                ? null
                : () async {
                    final sucesso = await auth.alterarTema(
                      !auth.preferenciasAtuais.escuro,
                    );
                    if (!sucesso && context.mounted) {
                      avisar(context, auth.mensagem ?? 'Tente novamente.');
                    }
                  },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: auth.consultando || auth.ocupado
                ? null
                : () async {
                    final sucesso = await auth.sair();
                    if (!context.mounted) return;
                    if (!sucesso) {
                      avisar(context, auth.mensagem ?? 'Tente novamente.');
                      return;
                    }
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
              ListenableBuilder(
                listenable: documentos,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Meus documentos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: documentos.ocupado
                            ? null
                            : () => _abrirEditor(),
                        icon: const Icon(Icons.add),
                        label: const Text('Novo documento'),
                      ),
                    ),
                    if (documentos.ocupado) const LinearProgressIndicator(),
                    if (documentos.erro case final erro?) ...[
                      Text(erro),
                      TextButton(
                        onPressed: documentos.carregar,
                        child: const Text('Recarregar lista'),
                      ),
                    ],
                    if (!documentos.ocupado &&
                        documentos.erro == null &&
                        documentos.documentos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Nenhum documento salvo.'),
                      ),
                    for (final documento in documentos.documentos)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(documento.titulo),
                          onTap: documentos.ocupado
                              ? null
                              : () => _abrirEditor(documento),
                          trailing: IconButton(
                            tooltip: 'Excluir documento',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: documentos.ocupado
                                ? null
                                : () => _excluir(documento),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
