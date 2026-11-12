import 'package:material_ui/material_ui.dart';

const desenvolvedora = 'Luana Magalhães';

class Rodape extends StatelessWidget {
  const Rodape({super.key});

  @override
  Widget build(BuildContext context) => const BottomAppBar(
    child: Center(child: Text('Desenvolvido por $desenvolvedora')),
  );
}

InputDecoration campo(String nome) =>
    InputDecoration(labelText: nome, border: const OutlineInputBorder());

void avisar(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
}
