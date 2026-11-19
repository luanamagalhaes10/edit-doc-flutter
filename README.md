# Entrelinhas · DocEditor MVVM

Aplicativo Flutter de Luana Magalhães com cadastro, login e editor de documentos. O armazenamento local mantém a sessão, o tema, o tamanho da fonte e os documentos após recarregar a página ou reabrir o aplicativo. Cada conta vê sua própria lista. Os dados Web ficam no navegador usado e a versão Android mantém os dados no dispositivo.

O relatório da etapa anterior está em [ARQUITETURA.md](ARQUITETURA.md).

## Executar no Codespaces

Abra um Codespace na branch `main`, execute `flutter pub get` e selecione **Rodar App Flutter (Web Preview)** com F5. Pelo terminal:

```sh
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

Abra a porta 8080 em uma nova aba. Cadastre uma conta, entre, crie um documento e depois edite o título e o conteúdo. Alterne o tema no topo da tela e recarregue com F5. O aplicativo deve voltar à lista com a sessão, o tema e os dados da edição. Para testar a exclusão, use o ícone da lixeira, confirme e recarregue novamente.

## Verificar e compilar

```sh
flutter analyze
flutter test
flutter build apk --release --target-platform android-arm64
flutter build web --release --base-href /edit-doc-flutter/
```

O instalador fica em `build/app/outputs/flutter-apk/app-release.apk`. A versão Android usa a assinatura de depuração do projeto para a instalação acadêmica. A saída Web fica em `build/web` e deve ser publicada na raiz da branch `gh-pages`.

## Estrutura

- `lib/models/services/preferences_service.dart` guarda as preferências e a sessão.
- `lib/models/services/banco_local_service.dart` guarda as contas locais.
- `lib/models/services/documento_storage_service.dart` grava e lê a lista JSON de documentos de cada conta com `shared_preferences`.
- `lib/viewmodels/documentos_viewmodel.dart` coordena as operações de criar, listar, editar e excluir. A Home e o editor chamam esse ViewModel.
