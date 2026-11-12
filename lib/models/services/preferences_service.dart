import '../usuario.dart';

// Fase 1: simula chave-valor como no DartPad. shared_preferences será usado
// na Fase 2, depois da entrega da migração arquitetural.
class PreferencesService {
  final Map<String, Object> _valores = {};

  Future<void> salvar(int id, PreferenciasUsuario preferencias) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _valores['usuario.$id.tema'] = preferencias.escuro ? 'escuro' : 'claro';
    _valores['usuario.$id.fonte'] = preferencias.fonte;
  }

  Future<PreferenciasUsuario> ler(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return PreferenciasUsuario(
      escuro: _valores['usuario.$id.tema'] == 'escuro',
      fonte: (_valores['usuario.$id.fonte'] as double?) ?? 16,
    );
  }
}
