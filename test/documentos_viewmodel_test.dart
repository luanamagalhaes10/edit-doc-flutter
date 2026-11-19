import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persiste CRUD após recriar o ViewModel e isola usuários', () async {
    SharedPreferences.setMockInitialValues({});
    final primeira = DocumentosViewModel(DocumentoStorageService(), 1);
    addTearDown(primeira.dispose);
    expect(await primeira.carregar(), isTrue);
    expect(await primeira.salvar(' Rascunho ', 'Versão inicial'), isTrue);
    final id = primeira.documentos.single.id;
    expect(
      await primeira.salvar('Ofício', 'Versão final\nLinha 2', id: id),
      isTrue,
    );

    final restaurada = DocumentosViewModel(DocumentoStorageService(), 1);
    addTearDown(restaurada.dispose);
    expect(await restaurada.carregar(), isTrue);
    expect(restaurada.documentos.single.titulo, 'Ofício');
    expect(restaurada.documentos.single.conteudo, 'Versão final\nLinha 2');

    final outroUsuario = DocumentosViewModel(DocumentoStorageService(), 2);
    addTearDown(outroUsuario.dispose);
    expect(await outroUsuario.carregar(), isTrue);
    expect(outroUsuario.documentos, isEmpty);

    expect(await restaurada.excluir(id), isTrue);
    expect(await primeira.carregar(), isTrue);
    expect(primeira.documentos, isEmpty);
  });
}
