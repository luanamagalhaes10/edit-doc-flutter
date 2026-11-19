import 'package:material_ui/material_ui.dart';

import '../models/documento.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'widgets/componentes.dart';

class TelaEditor extends StatefulWidget {
  final DocumentosViewModel documentos;
  final Documento? documento;

  const TelaEditor({super.key, required this.documentos, this.documento});

  @override
  State<TelaEditor> createState() => _TelaEditorState();
}

class _TelaEditorState extends State<TelaEditor> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.documento?.titulo);
  late final _conteudo = TextEditingController(
    text: widget.documento?.conteudo,
  );

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final sucesso = await widget.documentos.salvar(
      _titulo.text,
      _conteudo.text,
      id: widget.documento?.id,
    );
    if (!mounted) return;
    if (sucesso) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titulo.dispose();
    _conteudo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.documentos,
    builder: (context, _) => PopScope(
      canPop: !widget.documentos.ocupado,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.documento == null ? 'Novo documento' : 'Editar documento',
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _titulo,
                    decoration: campo('Título'),
                    enabled: !widget.documentos.ocupado,
                    validator: (titulo) => (titulo ?? '').trim().isEmpty
                        ? 'Informe um título.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conteudo,
                    decoration: campo('Conteúdo'),
                    enabled: !widget.documentos.ocupado,
                    keyboardType: TextInputType.multiline,
                    minLines: 8,
                    maxLines: 16,
                  ),
                  const SizedBox(height: 16),
                  if (widget.documentos.erro case final erro?) Text(erro),
                  FilledButton(
                    onPressed: widget.documentos.ocupado ? null : _salvar,
                    child: Text(
                      widget.documentos.ocupado
                          ? 'Salvando...'
                          : 'Salvar documento',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
