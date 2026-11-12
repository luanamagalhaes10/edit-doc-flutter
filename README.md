# Entrelinhas — edit-doc-flutter

Aplicativo Flutter de Luana Magalhães, migrado do DartPad para a arquitetura MVVM.

**Entrega atual: Fase 1.** Login, cadastro, tema, fonte e consultas de preferências e usuários. As simulações em memória foram mantidas. A implementação do CRUD e da persistência permanente fica para depois da entrega desta fase.

O relatório pedido na atividade está em [ARQUITETURA.md](ARQUITETURA.md).

## Executar no Codespaces

1. Abra **Code → Codespaces → Create codespace on main** e aguarde a configuração do container.
2. Confirme a confiança na pasta, se solicitado.
3. No terminal, execute `flutter pub get`.
4. Pressione **F5** e selecione **Rodar App Flutter (Web Preview)**. A porta 8080 está configurada para abrir o preview automaticamente.

O projeto já foi inicializado. Não é necessário executar `flutter create` novamente.

Para executar pelo terminal:

```sh
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

## Conferir o funcionamento

- Tente entrar com os campos vazios: as mensagens de validação devem aparecer.
- Abra **Cadastre-se**, informe nome e sobrenome, e-mail terminado em `.com` ou `.com.br` e senha de pelo menos seis caracteres.
- Escolha o tema e o tamanho da fonte e conclua o cadastro.
- Entre com os dados cadastrados. A Home deve mostrar o nome e aplicar o tema escolhido.
- Abra os dois cards para consultar as preferências e os usuários cadastrados.
- Saia do app. O botão de voltar não deve reabrir a Home.
- Tente cadastrar novamente o mesmo e-mail: o app deve avisar sobre a duplicidade.

Nesta fase, recarregar a página apaga os dados simulados. Os arquivos do editor e dos documentos são preparações para a Fase 2 e ainda não oferecem CRUD.

## Verificações do projeto

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

Os testes cobrem validações, duplicidade de e-mail, credenciais, preferências, consulta de usuários e navegação entre as três telas.

### Resultado da verificação

Verificado com Flutter 3.50.0 e Dart 3.14.0, em ambiente Linux:

- `flutter analyze`: nenhum problema encontrado.
- `flutter test`: quatro testes aprovados, incluindo o fluxo das três telas, tema escuro, fonte, consultas e logout.
- `flutter build web`: compilação concluída.
- Código de `lib/` e `test/` formatado com `dart format`.

A abertura pelo F5 dentro do Codespaces ainda está pendente. A criação do recurso foi bloqueada pela revisão automática por possível cobrança e depende de autorização da titular da conta. Os resultados acima foram obtidos neste ambiente Linux; não são um teste do preview do Codespaces.
