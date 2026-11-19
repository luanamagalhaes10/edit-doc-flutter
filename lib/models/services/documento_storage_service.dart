import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../documento.dart';

class DocumentoStorageService {
  String _chave(int usuarioId) => 'entrelinhas.usuario.$usuarioId.documentos';

  Future<List<Documento>> listar(int usuarioId) async {
    final dados = await SharedPreferences.getInstance();
    await dados.reload();
    final itens =
        jsonDecode(dados.getString(_chave(usuarioId)) ?? '[]') as List;
    return itens
        .map((item) => Documento.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Documento>> criar(
    int usuarioId,
    String titulo,
    String conteudo,
  ) async {
    final documentos = await listar(usuarioId);
    var id = DateTime.now().microsecondsSinceEpoch;
    while (documentos.any((documento) => documento.id == id)) {
      id++;
    }
    documentos.add(
      Documento(
        id: id,
        usuarioId: usuarioId,
        titulo: titulo,
        conteudo: conteudo,
      ),
    );
    return _salvar(usuarioId, documentos);
  }

  Future<List<Documento>> editar(Documento documento) async {
    final documentos = await listar(documento.usuarioId);
    final indice = documentos.indexWhere((item) => item.id == documento.id);
    if (indice < 0) throw StateError('Documento não encontrado.');
    documentos[indice] = documento;
    return _salvar(documento.usuarioId, documentos);
  }

  Future<List<Documento>> excluir(int usuarioId, int id) async {
    final documentos = await listar(usuarioId);
    documentos.removeWhere((item) => item.id == id);
    return _salvar(usuarioId, documentos);
  }

  Future<List<Documento>> _salvar(
    int usuarioId,
    List<Documento> documentos,
  ) async {
    final dados = await SharedPreferences.getInstance();
    if (!await dados.setString(_chave(usuarioId), jsonEncode(documentos))) {
      throw StateError('Falha ao salvar documentos.');
    }
    return documentos;
  }
}
