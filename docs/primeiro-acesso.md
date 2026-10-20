# Primeiro acesso

## Conectar ao servidor

Se o administrador já definiu o servidor na instalação, esta tela não aparece. Senão, o app pede o
endereço do GLPI (por exemplo `glpi.exemplo.com.br`) e confere se o plugin está instalado. Veja as
mensagens em [Instalação nas estações](instalacao-estacoes.md#instalação-manual).

## Entrar

- **Com a conta do Windows:** com a opção ativada no plugin, o app entra sozinho ao abrir
  ("Entrando com a sua conta do Windows…").
- **Com usuário e senha:** a tela aparece quando a conta do Windows não funciona ou está desativada.
  O usuário pode ser digitado como `usuario`, `EXEMPLO\usuario` ou `usuario@exemplo.com.br`.
  "Lembrar meu usuário" guarda só o nome de usuário. Depois de 5 senhas erradas seguidas, o app espera
  30 segundos antes de aceitar outra tentativa.

  ![Tela de login](imagens/tela-login.png)

- Se a sessão expirar no meio do uso, o app tenta a conta do Windows sozinho; se não der, a tela de
  login abre por cima, sem perder o que está aberto, e a ação é repetida depois de entrar.

## Usar

- **Meus chamados:** o seletor no topo da lista tem visões prontas:
  - para todos: Abertos por mim, Meus pendentes, Meus solucionados (30 dias), Aguardando minha
    aprovação e Observando;
  - para perfis técnicos, em "Atendimento": Atribuídos a mim, Pendentes atribuídos a mim,
    Solucionados por mim (7 dias), Dos meus grupos, Sem técnico nos meus grupos e Atrasados.
  "Só em aberto" vale nas visões que não definem o status.
- **Filtrar:** "Filtrar…" no seletor combina status, categoria, requerente, técnico, grupo,
  observador, período e título (técnico, grupo e observador só para perfis técnicos). "Salvar como
  filtro" grava nas pesquisas salvas do GLPI: o filtro aparece em outros computadores e no GLPI web.
  No menu "⋯" do filtro: editar, renomear, definir como padrão (o app abre nele) e excluir.
- **Abrir um chamado:** aba **Novo chamado**, com os formulários do GLPI que o usuário pode responder.
  O rascunho é salvo sozinho até o envio, e dá para anexar arquivos ou uma captura de tela.
- **Responder:** no chamado aberto, com texto formatado, imagens coladas e anexos. Na lateral, cada
  perfil altera só o que pode alterar na tela do GLPI (direitos do perfil e modelo de chamado).
- **Novidades:** notificação do Windows e número no ícone da barra de tarefas e da bandeja.
- **Tema:** na engrenagem (canto superior direito) — seguir o Windows, claro ou escuro, com ou sem as
  cores do GLPI.

## Sair e trocar de servidor

- **Sair** (engrenagem ou menu da bandeja): encerra a sessão neste computador e apaga o que é do
  usuário. O app continua na bandeja e não entra sozinho até o usuário pedir. **Fechar o GLPI Desktop
  Client**, no menu da bandeja, encerra o app.
- **Trocar servidor** (engrenagem): sai da sessão, esquece o servidor escolhido e volta para "Conectar
  ao servidor". Não aparece quando o administrador travou o servidor (`lockServer`).
