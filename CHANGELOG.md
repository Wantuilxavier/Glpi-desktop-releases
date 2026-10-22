# Histórico de versões

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). App e plugin saem
juntos em cada release; use os dois da mesma release.

## [0.14.0] — 2026-10-22

### App GLPI Desktop Client 0.14.0

Usa o plugin **0.17.0**. Com um plugin mais antigo, funciona como a 0.13.1.

#### Alterado
- **Muito menos carga no servidor do GLPI** na verificação de novidades em segundo plano: o app pergunta
  ao GLPI só o que mudou nos chamados do usuário, numa consulta leve, e só lê os chamados que mudaram.
  Sem novidade, cada verificação é uma requisição só, sem a busca de chamados. Medido na homologação, por
  verificação: de 3 a 4 requisições e 167 a 255 consultas ao banco para 1 requisição e 41 a 71 consultas.
- A lista de aprovações pendentes e os avisos da TI só são buscados quando o GLPI avisa que mudaram.
- Respeita o **intervalo mínimo para todas as estações** da aba Conexão do plugin: nunca verifica mais
  rápido que ele, mesmo que a GPO diga outro valor.
- Quando o GLPI não consegue dizer o que mudou (plugin antigo, registro de novidades desligado, muito
  tempo sem verificar ou mudanças demais de uma vez), o app faz a verificação completa, como antes.

### Plugin glpidesktop 0.17.0

Funciona com o app 0.13.1. O app 0.14.0, que usa as novidades abaixo, sai na mesma release.

#### Adicionado
- **Registro das novidades dos chamados:** o GLPI passa a anotar cada mudança em chamado (chamado
  novo, status, acompanhamento, solução, tarefa, atribuição, ator incluído, aprovação) e para quem ela
  interessa (os atores do chamado). Só números ficam guardados (chamado, tipo, papel), nenhum texto do
  chamado. Com isso o app 0.14.0 pergunta só o que mudou, numa consulta leve, em vez de buscar os
  chamados a cada verificação.
- Tarefa automática **limpezaEventos** (diária): apaga as novidades com mais de 7 dias (o número de
  dias é o parâmetro da tarefa).
- Aba **Conexão**:
  - **Intervalo mínimo para todas as estações:** o app 0.14.0 ou mais novo nunca verifica mais rápido
    que isso, mesmo que a GPO diga outro valor. Vale na próxima verificação de cada estação, sem
    reiniciar. Padrão: 0 (sem trava).
  - **Registrar novidades dos chamados para o app:** padrão **Sim**. Em **Não**, o app volta a buscar
    os chamados a cada verificação.
  - As mudanças dessas duas opções ficam no log de eventos do GLPI.

#### Atualizar
- Cria a tabela `glpi_plugin_glpidesktop_eventos` e a tarefa automática `limpezaEventos`. Faça um
  backup do banco antes, como em toda atualização do plugin.

## [0.13.1] — 2026-10-22

### App GLPI Desktop Client 0.13.1

Usa o plugin **0.16.1** (sem mudança no plugin).

#### Alterado
- **Menos carga no servidor do GLPI** na verificação de novidades em segundo plano:
  - o app não pede mais os dados da sessão web antes de cada consulta ao plugin (agora só quando
    faltam ou quando a sessão é renovada);
  - com o computador **ocioso** (mais de 10 minutos sem uso) ou **bloqueado**, verifica 4 vezes mais
    devagar; ao voltar a usar, verifica na hora;
  - ao voltar para a janela do app, só verifica de novo se a última verificação tiver mais de 1 minuto.

#### Segurança
- Biblioteca que limpa o HTML dos chamados (DOMPurify) atualizada para a 3.4.17, com correções de
  segurança publicadas depois da versão anterior.

## [0.13.0] — 2026-10-22

### App GLPI Desktop Client 0.13.0

Usa o plugin **0.16.1** (funciona também com o 0.16.0).

#### Adicionado
- **Tamanho do texto:** Ctrl + aumenta, Ctrl − diminui e Ctrl 0 volta a 100%, de 80% a 150%. Também
  com Ctrl e a roda do mouse e na engrenagem, em **Tamanho do texto**. A escolha fica salva para o
  usuário do Windows e vale na próxima vez que o app abrir.
- Parâmetro **`--minimizado`**: o app abre direto na bandeja, sem mostrar a janela, com os avisos e a
  verificação de novidades ligados. Se já estiver aberto para o usuário, não abre outro.
- Parâmetro **`--fechar`**: encerra o app aberto do usuário, como **Fechar** na bandeja.
- Script **`Atualizar-GlpiDesktopClient.ps1`** (pasta `deploy/powershell`) para RMM: confere o SHA-256,
  fecha o app em todas as sessões, instala, confere a versão e reabre o app minimizado para quem
  estiver logado. Veja "Atualização por RMM com o app reaberto" na instalação das estações.

#### Corrigido
- **Clique na notificação** sempre abre o app no chamado: com a janela aberta, minimizada ou só na
  bandeja, pela Central de Notificações (mesmo horas depois) e com o app fechado. O instalador passa
  a registrar o protocolo `glpidesktop://`, usado só pelas notificações do app.

### Plugin glpidesktop 0.16.1

#### Corrigido
- Formulários com pergunta de **Urgência** ou de **Tipo de requisição** continuam abrindo no app
  se uma versão futura do GLPI mudar a forma de ler o valor padrão dessas perguntas: o plugin
  passa a ler o valor padrão gravado na pergunta. Na versão atual do GLPI nada muda.

## [0.12.0] — 2026-10-22

### App GLPI Desktop Client 0.12.0

Usa o plugin **0.16.0**. Com plugin mais antigo, a visão em colunas fica desativada e o resto do app
funciona normalmente.

#### Alterado
- A **visão em colunas** (botão **Lista | Colunas**) só aparece para os técnicos quando o
  administrador libera em **Permitir visualização em colunas** no plugin. Desativada, o app mostra
  só a lista, mesmo para quem tinha escolhido Colunas antes.

#### Corrigido
- O **cabeçalho fixo** do chamado (status, número e título, ao rolar) agora gruda no topo da área
  do chamado: o texto que rola não aparece mais acima dele nem ao lado dele em janelas largas.
  Título longo termina em reticências, com o título completo ao passar o mouse.

### Plugin glpidesktop 0.16.0

#### Adicionado
- Aba **Conexão**: **Permitir visualização em colunas** (padrão: **Não**). A atualização do plugin
  grava a opção desativada; quem quiser a visão em colunas precisa ligar.

## [0.11.0] — 2026-10-22

### App GLPI Desktop Client 0.11.0

Usa o plugin **0.15.0** (as respostas prontas precisam dele; com plugin mais antigo, elas ficam
indisponíveis e o resto do app funciona normalmente).

#### Adicionado
- **Respostas prontas com "/"** (perfis técnicos): no começo de uma linha da resposta, da solução
  ou da tarefa, "/" abre a lista com os modelos de acompanhamento do GLPI da entidade do chamado e
  as suas respostas pessoais. O texto depois da "/" filtra; setas e Enter inserem; Esc fecha.
  `{requerente}`, `{numero}`, `{titulo}` e `{tecnico}` são trocados pelos dados do chamado.
  "Salvar o texto atual como resposta pronta" e, na engrenagem, **Respostas prontas** para
  renomear e excluir. As pessoais ficam no servidor e valem em qualquer computador.
- **Cronômetro no chamado** (perfis técnicos): "Iniciar cronômetro" no cabeçalho, um ativo por
  vez, continua com a janela fechada e com o app reiniciado; Pausar / Parar. Parar abre a Nova
  tarefa com a duração arredondada para 5 minutos; ligado mais de 8 horas, pergunta a duração real.
- **Ações em lote** (perfis técnicos): selecione vários chamados com Ctrl+clique, Shift+clique ou a
  caixa no item e use **Atribuir…**, **Mudar status…**, **Adicionar observador…** ou **Adicionar
  acompanhamento…** Um chamado por vez, com progresso, sem travar a tela; confirmação acima de
  10 chamados; no fim, o resumo do que foi alterado e do que o GLPI recusou (e por quê).
- **Visão em colunas** (perfis técnicos): botão **Lista | Colunas** no topo da lista; uma coluna
  por status com a contagem. Arrastar um chamado muda o status, se o seu perfil permitir
  (Pendente pede o motivo, Solucionado abre a solução); o clique abre o chamado à direita. A
  escolha fica salva para o seu usuário.

#### Corrigido
- **Marcar tarefa como feita** na conversa do chamado: a caixinha da tarefa agora grava no GLPI
  (perfis técnicos), e clicar de novo volta para "a fazer".
- O **cabeçalho fixo** do chamado (ao rolar) não deixa mais o texto aparecer através dele.
- A **caixa de resposta** fica sempre expandida, com a barra de formatação e os botões à vista.

### Plugin glpidesktop 0.15.0

#### Adicionado
- Respostas prontas pessoais de cada usuário (tabela `glpi_plugin_glpidesktop_replies`, criada ao
  atualizar o plugin) e os modelos de acompanhamento do GLPI já com os dados do chamado.

## [0.10.1] — 2026-10-22

### App GLPI Desktop Client 0.10.1

Usa o plugin 0.14.0 (sem mudança no plugin).

#### Adicionado
- **Visão "Todos os chamados"** no seletor de filtros (grupo "Meus chamados"): lista todos os
  chamados que o perfil pode ver, sem restringir a quem abriu. Como nas demais visões sem status,
  o **"Só em aberto"** continua valendo por cima (vem marcado, mostrando só os não solucionados;
  desmarque para incluir solucionados e fechados).

## [0.10.0] — 2026-10-21

### App GLPI Desktop Client 0.10.0

Usa o plugin 0.14.0 (sem mudança no plugin).

#### Adicionado
- **Capturar tela por área, em qualquer monitor**, como a Ferramenta de Captura do Windows: uma
  camada sobre cada monitor com a tela congelada; arrastar seleciona a área, as alças e as setas
  ajustam (Alt+setas mudam o tamanho), Enter ou duplo clique anexa, **Tela inteira** pega o monitor
  todo e Esc cancela.
- **Gravar tela** (até 60 s, sem áudio, em MP4): escolhe uma área, a tela inteira ou uma
  **janela**; a barra "Gravando 00:12 · Parar" e a moldura da área não aparecem no vídeo; ao parar,
  prévia com **Anexar** e **Descartar**. A gravação usa uma sessão própria, que só libera o vídeo
  da tela para a página do gravador.
- **Capturar tela** e **Gravar tela** também na resposta e na solução do chamado, ao lado de
  "Anexar arquivo" (anexam direto ao chamado).

#### Corrigido
- Faixa de Avisos da TI no catálogo: fica no topo do catálogo, com a mesma largura e margens do
  conteúdo (antes virava uma coluna ao lado).
- Lista "Avisos da TI": abre também a partir do catálogo; rodapé no fim do painel e o mesmo espaço
  entre os cartões; o aviso amarelo voltou a ter ícone e fundo.
- Trocar de visão (Meus chamados / Novo chamado) fecha o painel lateral aberto.

## [0.9.0] — 2026-10-21

### App GLPI Desktop Client 0.9.0

Usa o plugin 0.14.0. Com o plugin 0.13.0 o app funciona sem os dados do computador, sem o
preenchimento automático e sem os cartões Equipamento e Chamados relacionados.

#### Adicionado
- **Dados deste computador no novo chamado**: ao abrir um formulário, o app lê (sem administrador)
  nome, usuário do Windows, versão do Windows, IPs, disco do sistema, memória, tempo ligado,
  fabricante, modelo e número de série. A caixa **"Incluir dados deste computador"** vem marcada, diz
  "Depois de enviado, só a equipe de TI vê" e mostra exatamente o que vai; desmarcada, nada é enviado.
- **Preenchimento automático**: as perguntas escolhidas no plugin já vêm preenchidas (nome do
  computador, série, modelo, tipo notebook/desktop, usuário; em pergunta de item do tipo Computador,
  o computador do inventário), com o selo "✓ preenchido". O usuário pode alterar, e o rascunho do
  formulário vence.
- **Equipamento** na lateral do chamado (perfis técnicos): itens vinculados com tipo, fabricante,
  modelo, usuário, IP e último inventário, "Abrir no GLPI ↗" e "+ Vincular".
- **Chamados relacionados** na lateral (perfis técnicos): Ligado, Duplicado, Pai e Filho, com status e
  número (abre no app) e "+ Vincular" (número ou título + tipo de vínculo). Em duplicado, **"Juntar
  neste chamado"** (mesclagem do GLPI, com confirmação e resumo do que será movido) ou, sem o direito
  de juntar, **"Marcar como duplicado e solucionar"** ("Tratado no chamado #X").

### Plugin glpidesktop 0.14.0

#### Adicionado
- Aba **Preenchimento automático**: oferecer ou não "Incluir dados deste computador", autor do
  acompanhamento privado (padrão: usuário de sistema do GLPI) e as regras formulário + pergunta +
  dado, com registro no log de eventos do GLPI.
- `app.php`: `acao=preenchimento`, `maquina` (computador no inventário pela série e pelo nome; só id,
  nome e se é do usuário) e `maquina_chamado` (vincula o computador e grava os dados num
  acompanhamento privado, sem notificação; só quem acabou de abrir o chamado, até 30 minutos, uma vez).
  O requerente não vê o acompanhamento: o autor nunca é ele nem "sem autor".
- `app.php`: `acao=vinculos`, `inventario_buscar`, `juntar_resumo`, `vincular_item`,
  `vincular_chamado`, `juntar` (Ticket::merge; a origem vai para a lixeira) e `solucionar_duplicado`.
  Os direitos são os do GLPI, com a sessão do usuário.
- Migração: tabelas `glpi_plugin_glpidesktop_autofills` e `glpi_plugin_glpidesktop_ticketmachines`.

## [0.8.0] — 2026-10-21 (publicada junto com a 0.9.0)

### App GLPI Desktop Client 0.8.0

Usa o plugin 0.13.0. Com o plugin 0.12.0 o app funciona sem avisos da TI, sem registrar a
estação e sem categoria no chamado de diagnóstico.

#### Adicionado
- **Avisos gerais da TI**: faixa no topo da lista e do catálogo com o aviso mais grave e "e mais N";
  Informação e Aviso podem ser dispensados, Incidente fica até o fim; notificação do Windows na
  primeira vez (Aviso e Incidente); no Incidente com chamado principal, "Também estou com esse
  problema" (vira observador) e "Acompanhar"; "Avisos da TI" na bandeja e na engrenagem. Buscados no
  mesmo ciclo da verificação de fundo.
- **Estação com o app**: a cada login e uma vez por dia, só o nome do computador, a versão do app e a
  do Windows.
- **Enviar diagnóstico** (engrenagem e bandeja): logs dos últimos 7 dias, versões, configuração da
  máquina e teste de conexão, sem senhas, tokens, cookies nem conteúdo de chamados; mostra o que vai
  antes de enviar e anexa a um chamado do usuário ou abre "Diagnóstico do aplicativo".

### Plugin glpidesktop 0.13.0

#### Adicionado
- Aba **Avisos**: cadastro (título, mensagem, gravidade, início/fim, ativo, chamado principal, público
  por entidade, localização, grupo e perfil), com registro no log de eventos do GLPI;
  `app.php?acao=avisos` (filtrado pelo público no servidor) e `acao=aviso_observar`.
- Aba **Estações**: computador, usuário, versão, Windows e último uso; filtros, exportar CSV,
  destaque para versões antigas e link para o computador do inventário; tarefa automática
  `limpezaEstacoes` (sem uso há mais de 180 dias, configurável).
- Aba Conexão: categoria do chamado de diagnóstico.
- Migração: tabelas `glpi_plugin_glpidesktop_announcements` e `glpi_plugin_glpidesktop_stations`.

## [0.7.1] — 2026-10-21

### App GLPI Desktop Client 0.7.1

Usa o plugin 0.12.0. Com o plugin 0.11.0 o app funciona; nas listas que o plugin monta
(Aguardando minha aprovação, Aprovações pendentes, Pesquisas pendentes e Observando no
Self-Service) a ordem fica sempre a da última atualização.

#### Adicionado
- **Ordenar por** na linha de "Só em aberto": última atualização (padrão), data de abertura (mais
  recente ou mais antiga primeiro), prioridade e número. Quem ordena é o GLPI. Cada visão guarda a
  sua ordenação neste computador, por usuário; o seletor só mostra o que o perfil pode usar.
- Filtro salvo abre na ordenação gravada nele; trocada no seletor, "Salvar alterações" grava a nova.
- A data de cada chamado acompanha a ordenação: "Aberto …" ao ordenar pela abertura.
- **Período** no painel "Filtrar chamados", logo abaixo de Status: Atualizado | Aberto e os atalhos
  Hoje, Últimos 7 dias, Últimos 30 dias, Este mês e Personalizado (de/até).
- Período aplicado como **chip removível acima da lista** ("Atualizados nos últimos 7 dias ×").
  Sozinho, sobre uma visão ou um filtro salvo, ele fica por cima dela; funciona com qualquer visão,
  filtro salvo e "Só em aberto".
- Filtro salvo com período relativo (Hoje, Este mês, últimos N dias) continua valendo nos dias
  seguintes.

#### Alterado
- A contagem de chamados fica no botão do seletor de visões, e "Atualizar" virou um ícone
  ("Verificar agora").

#### Corrigido
- O filtro salvo era listado sempre pela última atualização, e salvar um filtro pelo app perdia a
  ordenação feita no GLPI web.

### Plugin glpidesktop 0.12.0

#### Adicionado
- Listas do painel do chamado (`aguardando_aprovacao`, `aprovacoes_pendentes`,
  `pesquisas_pendentes`, `observados`) aceitam `sort` (19, 15, 3 ou 2) e `order` (ASC/DESC).

## [0.7.0] — 2026-10-21

### App GLPI Desktop Client 0.7.0

Usa o plugin 0.11.0. Com o plugin 0.10.0 o app funciona sem a pesquisa de satisfação e sem o aviso
de versão nova.

#### Adicionado
- **Busca rápida (Ctrl+K)** e lupa no cabeçalho: número (com ou sem #) abre o chamado; texto busca
  no título e na descrição (até 10, com status, requerente e quando atualizou); Ações: Novo chamado
  e Ir para cada visão. ↑ ↓, Enter e Esc.
- **Menu de contexto na lista** (botão direito, tecla de menu ou Shift+F10): Atribuir a mim, Marcar
  como lido / não lido, Copiar número (Ctrl+C), Copiar link do GLPI, Abrir no navegador.
- **Pesquisa de satisfação**: "Como foi o atendimento?" com estrelas e comentário no chamado fechado
  com a pesquisa pendente; pesquisa externa abre o link; visão "Pesquisas pendentes" só quando há.
- **Aviso de versão nova** informado pelo plugin.
- Caixa de resposta compacta (uma linha até receber o foco) e **lista compacta** na engrenagem.

#### Corrigido
- A opção "Usuários finais podem desativar avisos" do plugin não chegava ao app (o filtro da
  configuração pública descartava o campo).
- Trocar de perfil com um filtro salvo de técnico aberto mostrava "Este filtro usa campos que o perfil
  atual não pode pesquisar." antes de voltar para "Abertos por mim".

### Plugin glpidesktop 0.11.0

#### Adicionado
- Aba Conexão: **Versão do app disponível** (endpoint público `app_version_available`).
- Painel do chamado: pesquisa de satisfação pendente; ação `pesquisas_pendentes`.

## [0.6.0] — 2026-10-21 (publicada junto com a 0.7.0)

### App GLPI Desktop Client 0.6.0

Usa o plugin 0.10.0. Com o plugin 0.9.0 o app funciona sem as ações de técnico abaixo (os botões
não aparecem).

#### Adicionado
- **Acompanhamento privado**: chip Privado na caixa de resposta (com o direito de ver acompanhamentos
  privados); ligado, o cartão fica tracejado com o aviso "Resposta privada: o requerente não verá
  esta mensagem". Começa como a preferência do usuário no GLPI. Na linha do tempo, acompanhamentos e
  tarefas privados aparecem tracejados com o selo "Privado · só a equipe vê".
- **Nova tarefa**: modelo (preenche os campos), técnico ("Eu mesmo" por padrão), grupo, estado,
  duração, privada e o texto. A linha do tempo mostra o técnico e a duração de cada tarefa.
- **Solicitar aprovação** a uma pessoa ou a um grupo, com comentário; bloco Aprovação na linha do
  tempo (Aguardando / Aprovada / Recusada).
- **Aprovar**: visão "Aprovações pendentes" e, no chamado, o aviso "Sua aprovação foi solicitada"
  com Aprovar e Recusar (motivo obrigatório); aviso do Windows "Aprovação solicitada a você".
- **Motivo de pendência**: ao mudar para Pendente, diálogo com o motivo, acompanhamento opcional e a
  retomada automática quando o motivo tem; o motivo aparece ao lado do status.

#### Corrigido
- Lista na abertura do app com perfil técnico: "Sem requerente" sem prioridade (colunas lidas antes
  de saber o perfil).

### Plugin glpidesktop 0.10.0

#### Adicionado
- Painel do chamado: direitos de técnico (privado, tarefa, tarefa privada, solicitar aprovação),
  preferências do usuário (privado por padrão, estado da tarefa), aprovações do chamado, motivo de
  pendência atual e motivos disponíveis.
- Ações `tarefa`, `modelo_tarefa` e `aprovacoes_pendentes`.

## [0.5.0] — 2026-10-21 (publicada junto com a 0.7.0)

### App GLPI Desktop Client 0.5.0

Usa o plugin 0.9.0. Com o plugin 0.8.0 o app funciona; os usuários finais ficam sem a seção Avisos
(é o padrão) e a linha do tempo mostra o login de quem escreveu quando o perfil não pode ler usuários.

#### Adicionado
- **Avisos por tipo** no menu da engrenagem: Meus chamados (respostas, status e soluções) e, para
  perfis de atendimento, Atribuído a mim, Novo na fila dos meus grupos, Resposta do requerente,
  Solução recusada e Prazo perto de vencer (menos de 2 h; desligado por padrão). **Não perturbe** até
  o dia seguinte às 8h; o contador de não lidas continua.
- Usuários finais (perfis sem atendimento) sempre recebem os avisos dos próprios chamados e não veem
  a seção Avisos nem o Não perturbe, a não ser que o plugin permita.
- Notificações agrupadas: mais de 3 chamados com novidade no mesmo ciclo viram uma notificação só;
  o clique abre o chamado ou a visão.
- **Marcar todas como lidas** na bandeja e no seletor de visões.
- Faixa "Você tem N novidades nos seus chamados · Ver" ao abrir ou focar o app.
- Solução aguardando a aprovação do usuário: o botão na barra de tarefas pisca até ele abrir o
  chamado, e um lembrete diário aparece depois de 24 h sem resposta.
- **Chamado aberto sempre atualizado**: com a janela em foco, a cada 30 s o app confere a última
  alteração do chamado aberto e recarrega mantendo a rolagem. Com a resposta em digitação ou lendo
  mais acima, aparece "N novidades neste chamado · Mostrar", que recarrega sem perder o rascunho e
  rola até a primeira novidade.
- Cabeçalho do chamado fixo ao rolar (status, número e título).
- Linha do tempo com foto ou iniciais, nome completo, hora relativa ("há 2 h", com a data completa
  ao passar o mouse) e cores diferentes para o requerente e a equipe.
- Lista para técnicos: chamado não lido com ponto e título em negrito, e segunda linha com
  requerente, prioridade e prazo de solução ("Vence em 1 h" / "Atrasado 2 d").

#### Alterado
- **Verificação de fundo com uma busca só** para todos os papéis (requerente, técnico, grupo
  técnico, observador e grupo observador), só dos chamados alterados desde a última verificação.
  Ciclo sem mudanças: 1 chamada à API (antes, uma busca por papel e a leitura de cada chamado).
  Abrir o app: 8 chamadas. O log registra quantas chamadas cada ciclo fez e cada novidade.
- A lista da visão atual se atualiza em silêncio quando a verificação acha mudanças nela, mantendo
  a seleção e a rolagem.
- Falha na verificação: novas tentativas em 2, 4, 8 e 15 minutos; com login pedido, a verificação
  pausa e volta depois do login. Desbloquear a tela, voltar da suspensão ou focar a janela (no
  máximo a cada 10 s) verifica na hora.

### Plugin glpidesktop 0.9.0

#### Adicionado
- Aba Conexão: **Usuários finais podem desativar avisos** (padrão Não), informado ao app pelo
  endpoint público (`end_users_can_mute`).
- Painel do chamado: nome completo de quem escreveu na linha do tempo (`autores`, por login).

## [0.4.0] — 2026-10-21 (publicada junto com a 0.7.0)

### App GLPI Desktop Client 0.4.0

Usa o plugin 0.8.0. Com o plugin 0.7.0 o app funciona, sem a busca de pessoa com setor, sem o
filtro padrão em qualquer computador e com o catálogo montado pelo nome da categoria.

#### Adicionado
- **Catálogo agrupado por categoria**: tela inicial com Fixados, Usados recentemente (até 4) e
  blocos de categoria (ícone, nome, primeiros formulários e quantidade). Abrir uma categoria mostra
  "← Todas as categorias / Nome", a busca dentro dela, as subcategorias e os formulários; Esc volta
  mantendo a rolagem; categoria com um formulário só abre o formulário direto. A busca ignora as
  categorias. Ícones = ilustração do GLPI 11 da categoria e do formulário (ou um ícone neutro).
- **Busca de pessoa** (atores e filtro) em duas linhas: nome e, embaixo, login (quando o perfil pode
  ver usuários) e grupo principal; grupos com o número de pessoas; seções Dos seus grupos, Usados
  recentemente (os últimos 10 escolhidos, neste computador) e Todos.
- **Filtro padrão em qualquer computador**: gravado no plugin, por usuário. A cópia local fica de
  reserva e um padrão que só existia neste computador é levado ao plugin.
- Lista vazia com título e explicação de cada visão, no topo da lista, e a ação "Ver todos os meus
  chamados".
- Chamado sem requerente: "Sem requerente (aberto automaticamente)" no painel e aviso ao salvar a
  solução (ninguém poderá aprová-la; o chamado fecha pela regra de fechamento automático do GLPI).

#### Alterado
- Trocar de visão limpa o painel ("Selecione um chamado") quando o chamado aberto não está na lista
  nova; se está, ele continua aberto e selecionado.
- **Tela cheia da resposta** cobre a janela inteira, com o contexto ("Responder · #número — título" ou
  "Adicionar solução · …") e as mesmas ações da caixa normal; é o mesmo editor, sem perder texto,
  formatação ou imagens. Esc sai.
- Seletor de visões com 360 px; nomes de filtro em até 2 linhas (o completo no title) e a nota
  ("Público", "Padrão") na segunda linha.
- Status curto no painel Detalhes ("Em atendimento", "Planejado"); nome inteiro na lista e no title.
- Nome da paleta do GLPI no menu da engrenagem ("Auror", "Dark Auror"…); paleta personalizada:
  "Paleta do GLPI".
- A seção Anexos some quando o chamado não tem anexos.
- O seletor de Perfil some quando o usuário tem um perfil só.

### Plugin `glpidesktop` 0.8.0

#### Adicionado
- Tabela `glpi_plugin_glpidesktop_preferences` (uma linha por usuário), criada na instalação ou
  atualização e apagada na desinstalação.
- `front/app.php?acao=preferencias`: GET lê o filtro padrão do usuário; POST grava (token CSRF do
  GLPI no cabeçalho `X-Glpi-Csrf-Token`). Só aceita pesquisa salva de chamados que o usuário pode ver.
- `front/formularios.php?acao=ilustracao&id=…`: SVG de uma ilustração nativa do GLPI 11.

#### Alterado
- Busca de pessoa (`chamado.php`, ações `buscar` de ator e `filtro_buscar`): login (só com o direito
  de ler usuários), grupo principal, se a pessoa é de um grupo do usuário e o número de pessoas de
  cada grupo — só para os itens que o GLPI já devolveu para aquele perfil.
- Catálogo (`formularios.php?acao=catalogo`): manda as categorias (com pai e ilustração) e a
  ilustração de cada formulário.

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
