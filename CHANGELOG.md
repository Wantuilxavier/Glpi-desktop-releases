# Histórico de versões

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). App e plugin saem
juntos em cada release; use os dois da mesma release.

## [0.3.2] — 2026-10-20

### App GLPI Desktop Client 0.3.2

Usa o plugin 0.7.0 (sem mudança no plugin).

#### Corrigido
- Com a solução aguardando a aprovação do usuário, a caixa de resposta continuava embaixo da linha do
  tempo. No GLPI, uma resposta do requerente num chamado solucionado reabre o chamado e marca a
  solução como **recusada**, sem nenhum aviso. Agora, enquanto a solução aguarda aprovação, a caixa
  não aparece: no lugar fica "Para responder, aprove ou recuse a solução no topo do chamado". Depois
  de "Recusar solução" o chamado volta para atendimento e a caixa reaparece.

## [0.3.1] — 2026-10-20

### App GLPI Desktop Client 0.3.1

Usa o plugin 0.7.0 (sem mudança no plugin).

#### Corrigido
- "Anexar arquivo" no chamado falhava em perfis sem o direito "Documento" (Self-Service e técnicos
  sem esse direito): o documento era criado, o vínculo com o chamado era recusado e o arquivo ficava
  solto no GLPI. Agora o documento já nasce ligado ao chamado, como na aba Documentos do GLPI web.
- O botão "Anexar arquivo" não mostrava nada quando o envio falhava. Agora mostra o motivo, com o nome
  do arquivo, e recarrega o chamado depois de anexar para o arquivo aparecer na lista.

## [0.3.0] — 2026-10-20

### App GLPI Desktop Client 0.3.0

#### Adicionado
- **Editor de texto com formatação** na resposta, na solução e nas perguntas de texto longo dos
  formulários: estilo do parágrafo (Parágrafo, Título, Citação), negrito, itálico, sublinhado, cor do
  texto e realce (paleta do editor do GLPI), listas, recuo, link, imagem, tabela e tela cheia. Barra
  navegável pelo teclado; Ctrl+Enter envia a resposta. Editor: Quill 2.0.3 (BSD-3-Clause), empacotado
  com o app.
- Print colado (Ctrl+V) ou imagem escolhida vai dentro do texto, do mesmo jeito que o GLPI web envia.
- Colar do Word ou do navegador mantém negrito, itálico, listas, links e tabelas e tira fontes,
  tamanhos e estilos estranhos.
- O modelo de solução entra formatado; o texto digitado passa da resposta para a solução com a
  formatação.
- Imagens dentro dos acompanhamentos e soluções aparecem no app (baixadas com a sessão do usuário).
- Lista de chamados com largura ajustável: arrastar a alça, duplo clique para voltar ao padrão ou
  setas/Home/End pelo teclado. A largura escolhida é lembrada.
- Visão **Observando**: chamados em que o usuário ou um grupo dele é observador (junta os quadros
  "Seus chamados observados" das visões pessoal e do grupo do GLPI web). "Só em aberto" vale para as
  duas partes. Nos perfis Self-Service a lista vem do plugin, porque a API não deixa esses perfis
  pesquisar por observador.
- **Visões prontas** no seletor da lista, em dois grupos:
  - Meus chamados (todos os perfis): Abertos por mim, Meus pendentes, Meus solucionados (30 dias),
    Aguardando minha aprovação e Observando.
  - Atendimento (perfis técnicos): Atribuídos a mim, Pendentes atribuídos a mim, Solucionados por mim
    (7 dias), Dos meus grupos, Sem técnico nos meus grupos e Atrasados (prazo de solução vencido,
    meus ou dos meus grupos).
  Nas visões que já definem o status, "Só em aberto" some.
- Selo "Você observa este chamado" no cabeçalho do chamado.
- Número de chamados da visão ao lado de "Atualizar".
- **Filtrar chamados**: "Filtrar…" no seletor da lista abre um painel com status, categoria (com ou
  sem subcategorias), requerente, técnico, grupo atribuído, observador, período (abertura ou última
  atualização: 7, 30, 90 dias ou de/até) e título. Vários nomes no mesmo campo valem como "ou";
  campos diferentes, como "e". "Eu mesmo" e "Meus grupos" valem para quem usar o filtro. As listas
  de pessoas, grupos e categorias são as mesmas da pesquisa do GLPI web para o perfil. O resultado
  aparece como "Filtro personalizado", com "×" para voltar à visão anterior.
- "Gerenciar filtros no GLPI" abre as pesquisas salvas no navegador.
- **Filtros salvos nas pesquisas salvas do GLPI**: "Salvar como filtro" grava o filtro com nome no
  GLPI, no mesmo formato da tela de pesquisa, então ele aparece em outros computadores e no GLPI web.
  "Compartilhar com outros usuários" só aparece para quem tem o direito de pesquisa pública no perfil.
- O seletor lista "Meus filtros" e "Compartilhados". Nos do usuário, o menu "⋯" (ou seta para a
  direita) tem Editar, Renomear, Definir/Remover padrão e Excluir (com confirmação; o filtro some
  também do GLPI). Nos públicos de outras pessoas, só "Definir como padrão".
- Filtro padrão: o app abre nele. Fica guardado neste computador, porque a API do GLPI não deixa
  estes perfis gravarem a pesquisa padrão do GLPI web.
- Filtros com opções avançadas feitos no GLPI web (OU/E NÃO entre campos, grupos, outros campos)
  funcionam no app; "Editar" mostra os critérios em texto, só para leitura, com "Editar no GLPI".

#### Alterado
- O seletor da lista virou um menu próprio, com as visões e as ações de filtro, navegável pelo
  teclado.
- Perfis Self-Service não veem técnico, grupo atribuído e observador no filtro nem as visões de
  atendimento: a API do GLPI não deixa esses perfis pesquisar por esses campos.
- Se a busca falhar, a lista fica vazia em vez de continuar mostrando os chamados da visão anterior.
- Selos de status com as cores e os ícones do GLPI (círculo cheio, círculo vazado, calendário,
  interrogação para Aprovação). Solucionado e Fechado deixam de aparecer iguais.
- Status no painel Detalhes escolhido numa lista como a do GLPI web: cada opção com o ícone e o nome
  inteiro, então "Em atendimento (atribuído)" e "(planejado)" não ficam mais iguais.
- As cores escolhidas no texto são mantidas ao exibir; no tema escuro, uma cor que não lê (ex.: texto
  preto) é descartada só naquele trecho e o texto sobre realce é ajustado.

### Plugin `glpidesktop` 0.7.0

#### Adicionado
- Ação `filtro_buscar` em `front/chamado.php`: usuários, grupos e categorias para o filtro de
  chamados, com as regras de cada campo da pesquisa do GLPI (direito do técnico, condição do grupo).
- Ação `filtro_nomes`: nomes dos usuários, grupos e categorias usados numa pesquisa salva que o
  usuário pode ver (só os ids que estão nela), para o app mostrar o filtro na edição.
- Ação `observados`: chamados em que o usuário ou um grupo dele é observador, nas entidades ativas
  e com a mesma regra de leitura da tela do chamado (visão Observando nos perfis Self-Service).

#### Alterado
- O modelo de solução vem também em HTML, para entrar formatado no editor (o texto simples continua,
  para apps antigos).

#### Corrigido
- Perguntas de pessoa dos formulários (observador, requerente, técnico) sem nenhum tipo marcado na
  configuração não listavam ninguém. Agora seguem a regra do GLPI: nenhum tipo marcado = todos.
- Aba Detalhes e atores com as mesmas permissões da tela do GLPI. Na interface padrão, com o direito
  de atualizar chamados, todos os campos, o requerente e o observador ficam editáveis. Quem abriu o
  chamado (caso do Self-Service) só altera categoria e urgência, e só enquanto o chamado não tem
  acompanhamento nem tarefa. Antes o app deixava o Self-Service mexer em status, tipo, impacto,
  origem e atores, e o GLPI descartava a alteração.

## [0.2.0] — 2026-10-19

### App GLPI Desktop Client 0.2.0

#### Adicionado
- Nome do aplicativo definido na instalação: `/APP_NAME="<nome>"` no instalador, `appName` na GPO
  ou no `config.json`, `-AppName` no script PowerShell. Vale para o título da janela, o cabeçalho, a
  tela de entrada e a bandeja, e vence o nome do plugin. O instalador renomeia o atalho do Menu
  Iniciar. Nome inválido é ignorado e registrado no log.
- **Adicionar solução** ao lado de "Enviar resposta", como no GLPI web: o mesmo cartão troca para o
  modo solução, com modelo e tipo opcionais, e pede confirmação no próprio cartão. Aparece só para
  quem o GLPI deixa solucionar; recusas do servidor aparecem com a mensagem dele.
- **Aprovar ou recusar a solução** (requerente): aviso no topo do chamado com "Aprovar solução"
  (verde) e "Recusar solução" (vermelho, pede o motivo); prazo do fechamento automático, se houver.
- Estado de cada solução na linha do tempo (Aguardando aprovação, Aprovada, Recusada), selo
  "Aguarda sua aprovação" na lista e a visão "Aguardando minha aprovação" para todos os perfis.

#### Alterado
- Bloco Acompanhamento com fundo branco no tema claro, para se destacar do fundo da tela.

### Plugin `glpidesktop` 0.6.0

#### Adicionado
- No painel do chamado: se o usuário pode solucionar e aprovar (as mesmas regras da tela do GLPI) e o
  prazo do fechamento automático da entidade.
- Modelos e tipos de solução da entidade do chamado, e o texto do modelo já com os dados do chamado.
- Lista de chamados que esperam a aprovação do usuário, com a mesma condição da página inicial do GLPI.

## [0.1.0] — 2026-10-18

### App GLPI Desktop Client 0.1.0

#### Adicionado
- Chamados do usuário na bandeja do Windows, com as permissões do perfil no GLPI: "Abertos por mim" e,
  para perfis técnicos, "Atribuídos a mim" e "Dos meus grupos".
- Abertura de chamado pelos formulários do GLPI, com rascunho automático e captura de tela nos anexos;
  resposta e anexos; lateral do chamado editável conforme o perfil; troca de perfil.
- Notificações do Windows quando um chamado muda e número de novidades no ícone da barra de tarefas
  e da bandeja.
- Entrada com a conta do Windows (Kerberos) ou com usuário e senha, conforme o plugin; tela de login
  própria; espera de 30 s depois de 5 senhas erradas; login por cima da tela quando a sessão expira.
- Conexão a qualquer servidor: configuração da máquina (GPO, parâmetros `/GLPI_URL`, `/APP_TOKEN` e
  `/LOCK_SERVER` do instalador, `config.json`), escolha do usuário na tela "Conectar ao servidor",
  "Trocar servidor" e `lockServer`.
- Nome, título, logo, texto de suporte e ícone vindos do plugin.
- Tema claro e escuro, seguindo o Windows ou fixo, com as cores do GLPI.
- **Sair**: encerra a sessão e apaga o que é do usuário neste computador.

#### Segurança
- Electron 44 com fusíveis e integridade do `app.asar`; a janela não navega para fora do app; links
  externos com confirmação; canais internos só da janela do app; permissões do navegador negadas.
- Só HTTPS (http:// só com aviso explícito), com os certificados confiáveis do Windows e sem desligar a
  verificação.
- Senha nunca gravada nem registrada; token do login com senha só em memória; token do login do
  Windows cifrado pelo Windows (DPAPI).

### Plugin `glpidesktop` 0.5.0

#### Adicionado
- Página de configuração com as abas Identidade (nome, título, texto de suporte, logo), Conexão
  (cliente de API, domínios do SSO, intervalo, "Testar conexão"), Autenticação (conta do Windows,
  usuário e senha, mensagem da tela de login), Instalador (última release e comandos prontos) e Ícone
  (Timeline, Balão, Ticket ou personalizado).
- `front/publico.php`, sem sessão: opções da tela de login, identidade e versões; `?recurso=logo`.
- Entrega ao app do App-Token do cliente de API escolhido, depois do login.
- As páginas do app recusam com `403` (`sso_disabled` / `password_disabled`) a sessão aberta por um
  método desativado; cada mudança na aba Autenticação vai para o log de eventos do GLPI.

#### Requisitos
- GLPI 11.0.x e PHP 8.2 ou mais novo. Sem tabela própria: a configuração fica em `glpi_configs`.
