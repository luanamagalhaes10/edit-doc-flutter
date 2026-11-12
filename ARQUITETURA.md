# Relatório de migração para MVVM — Fase 1

**Aluna:** Luana Magalhães

**Aplicativo:** Entrelinhas

**Repositório:** https://github.com/luanamagalhaes10/edit-doc-flutter

## 1. Onde ficou cada parte do código

No DartPad, todas as classes estavam em um único arquivo. Nesta versão, separei o projeto pela responsabilidade de cada parte, mantendo as telas de Login, Cadastro e Home e as consultas de preferências e usuários.

| Parte do arquivo do DartPad | Arquivo no projeto | Responsabilidade |
| --- | --- | --- |
| `main`, `MeuApp` e configuração das rotas | `lib/main.dart` | Iniciar o app, criar os serviços e o ViewModel e configurar o tema e a navegação. |
| `Usuario`, `DadosSessao` e `PreferenciasUsuario` | `lib/models/usuario.dart` | Representar os dados usados pela aplicação. |
| `BancoDadosLocal` e `EmailJaCadastrado` | `lib/models/services/banco_local_service.dart` | Simular o cadastro e a consulta de usuários em memória. |
| `PreferenciasLocais`, renomeada para `PreferencesService` | `lib/models/services/preferences_service.dart` | Simular a gravação e a leitura do tema e do tamanho de fonte por usuário. |
| Regras antes presentes nas telas | `lib/viewmodels/auth_viewmodel.dart` | Coordenar cadastro, login, logout, preferências, consultas, mensagens e indicadores de carregamento. |
| `TelaLogin` | `lib/views/login_view.dart` | Exibir os campos, validar o formulário e navegar depois do resultado do ViewModel. |
| `TelaCadastro` | `lib/views/cadastro_view.dart` | Exibir os dados e os seletores de preferência do cadastro. |
| `TelaHome` | `lib/views/home_view.dart` | Mostrar o nome recebido pela rota e abrir os diálogos de preferências e usuários. |
| `Rodape`, `campo`, `avisar` e identificação da desenvolvedora | `lib/views/widgets/componentes.dart` | Reunir componentes visuais reutilizados pelas telas. |
| `normalizarEmail`, `validarNome`, `validarEmail` e `validarSenha` | `lib/utils/validadores.dart` | Centralizar a normalização e as validações dos formulários. |

Os arquivos `models/documento.dart`, `viewmodels/documentos_viewmodel.dart` e `views/editor_view.dart` deixam preparada a estrutura solicitada para a próxima fase. Eles não existiam no código anterior. O editor ainda não foi incluído nas rotas e não há CRUD de documentos nesta entrega.

## 2. Estrutura, construtores e imports

Cada arquivo passou a importar apenas as classes que utiliza. O ambiente usado nos testes tem Flutter 3.50, que sinaliza o antigo import `package:flutter/material.dart` como obsoleto. Por isso, adicionei a biblioteca oficial `material_ui` e usei `package:material_ui/material_ui.dart` nas interfaces e no código que depende de `ThemeMode`. Essa adaptação mantém os mesmos widgets Material sem os avisos do analisador. As telas recebem o `AuthViewModel` pelo construtor; o ViewModel recebe o banco e o serviço de preferências. Essas instâncias são criadas uma única vez no estado de `MeuApp`, para que as três telas compartilhem os mesmos dados durante a execução.

O banco e as preferências deixaram de usar membros estáticos e passaram a guardar seus dados em instâncias. Isso também permite testar uma instância sem misturar seus dados com os de outra. As listas internas e os estados ficam privados, com acesso por getters. A consulta de usuários devolve uma lista imutável.

As rotas nomeadas `/` e `/cadastro` ficaram no `MaterialApp`. A rota `/home` é criada em `onGenerateRoute`, que verifica o tipo do argumento e se o identificador corresponde à sessão ativa antes de montar a Home. O login continua usando `pushReplacementNamed`, enviando `DadosSessao` em `arguments`; a Home recebe esse objeto pelo construtor e mostra o nome do usuário. O cadastro usa `pop` ao terminar, e o logout remove o histórico para impedir o retorno à Home pelo botão de voltar.

O `GlobalKey<FormState>` e os `TextEditingController` continuam nas telas, porque controlam os campos da interface. Os controladores são descartados em `dispose`. As telas também continuam responsáveis por navegação, `SnackBar` e diálogos. Os serviços e o ViewModel não recebem `BuildContext` nem decidem como desenhar a interface.

## 3. O que mudou no gerenciamento de estado

Removi os `setState` que atualizavam o carregamento do login, o tema e a fonte selecionados no cadastro, o carregamento do cadastro e o indicador de consulta da Home. Esses valores passaram a ser controlados pelo `AuthViewModel`, que estende `ChangeNotifier`.

| Estado anterior | Estado atual no ViewModel |
| --- | --- |
| `_ocupado` no Login e no Cadastro | `_ocupado`, compartilhado pelas operações de autenticação e cadastro. |
| `_escuro` e `_fonte` no Cadastro | `_escuroCadastro` e `_fonteCadastro`, alterados pelos métodos dos seletores. |
| `temaAtual`, um `ValueNotifier` global | Getter `tema`, calculado a partir de `_preferenciasAtuais`. |
| `_consultando` na Home | `_consultando`, que controla as consultas e desabilita os cards enquanto carregam. |
| Fonte carregada ao iniciar a Home | `_preferenciasAtuais`, carregada no login antes de navegar. |
| Resultado das consultas tratado dentro da Home | `_usuarios` e `_preferenciasAtuais`, consultados pelos métodos do ViewModel. |

Quando o usuário escolhe um tema ou uma fonte, a tela chama um método do ViewModel. O método altera o valor e chama `notifyListeners()`. O `ListenableBuilder` escuta esse aviso e reconstrói a interface com o estado atualizado. O mesmo acontece no início e no fim das operações assíncronas, permitindo desabilitar botões e mostrar o carregamento.

No login, por exemplo, a tela valida o `Form` e chama `entrar`. O ViewModel consulta o banco, carrega as preferências e define a sessão. Só depois a tela recebe o resultado e navega. O `ListenableBuilder` de `MeuApp` também escuta o ViewModel e aplica o tema escolhido. Assim, as telas cuidam da apresentação e o ViewModel coordena as regras e os dados.

A Home passou a ser um `StatelessWidget`. Login e Cadastro continuam como `StatefulWidget` apenas para manter e descartar os controladores dos campos. Nenhuma tela desta versão usa `setState`.

## Limite desta entrega

Esta é a **Fase 1, anterior ao CRUD e à persistência permanente**. O banco e as preferências ainda são simulações assíncronas em memória, como no DartPad. Ao recarregar a página, os cadastros e as preferências são apagados. O pacote `shared_preferences` faz parte da preparação do projeto; sua integração real, a sessão persistente e os documentos em JSON ficam para a Fase 2, após a entrega desta migração.

O uso de senhas em memória serve somente para a atividade acadêmica. Esta versão não implementa autenticação de produção.
