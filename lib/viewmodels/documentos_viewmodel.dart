import 'package:flutter/foundation.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storage;
  final int usuarioId;
  List<Documento> _documentos = const [];
  bool _ocupado = false;
  bool _descartado = false;
  String? _erro;

  DocumentosViewModel(this._storage, this.usuarioId);

  List<Documento> get documentos => _documentos;
  bool get ocupado => _ocupado;
  String? get erro => _erro;

  Future<bool> carregar() => _executar(() => _storage.listar(usuarioId));

  Future<bool> salvar(String titulo, String conteudo, {int? id}) {
    final nome = titulo.trim();
    return _executar(() {
      if (nome.isEmpty) throw ArgumentError('Informe um título.');
      if (id == null) return _storage.criar(usuarioId, nome, conteudo);
      return _storage.editar(
        Documento(
          id: id,
          usuarioId: usuarioId,
          titulo: nome,
          conteudo: conteudo,
        ),
      );
    });
  }

  Future<bool> excluir(int id) =>
      _executar(() => _storage.excluir(usuarioId, id));

  Future<bool> _executar(Future<List<Documento>> Function() operacao) async {
    if (_ocupado || _descartado) return false;
    _ocupado = true;
    _erro = null;
    notifyListeners();
    try {
      _documentos = List.unmodifiable(await operacao());
      return true;
    } catch (_) {
      _erro = 'Não foi possível concluir a operação. Tente novamente.';
      return false;
    } finally {
      _ocupado = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
