String normalizarEmail(String email) => email.trim().toLowerCase();

String? validarNome(String? valor) {
  final partes = (valor ?? '').trim().split(RegExp(r'\s+'));
  if (partes.length < 2 || partes.any((parte) => parte.length < 2)) {
    return 'Informe nome e sobrenome.';
  }
  return null;
}

String? validarEmail(String? valor) {
  final email = normalizarEmail(valor ?? '');
  final formato = RegExp(
    r'^[a-z0-9!#$%&\x27*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\x27*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+com(?:\.br)?$',
  );
  if (!formato.hasMatch(email)) {
    return 'Use um e-mail válido terminado em .com ou .com.br.';
  }
  return null;
}

String? validarSenha(String? valor) {
  if (valor == null || valor.trim().length < 6) {
    return 'A senha precisa ter pelo menos 6 caracteres.';
  }
  return null;
}
