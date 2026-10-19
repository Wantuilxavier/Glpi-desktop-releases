# Histórico de versões

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). App e plugin saem
juntos em cada release; use os dois da mesma release.

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
