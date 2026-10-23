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
  O rascunho é salvo sozinho até o envio, e dá para anexar arquivos, capturas e gravações de tela
  (veja [Capturar, gravar e ver anexos](#capturar-gravar-e-ver-anexos)).
- **Responder:** no chamado aberto, com texto formatado, imagens coladas e anexos. Na lateral, cada
  perfil altera só o que pode alterar na tela do GLPI (direitos do perfil e modelo de chamado).
- **Colocar em pendência** (perfis técnicos): ao mudar o status para Pendente, escolha o motivo de
  pendência cadastrado no GLPI (ou "Sem motivo") e, se quiser, escreva um acompanhamento para o
  requerente. Se o motivo tiver lembretes automáticos, o app mostra como eles vão funcionar. O motivo
  aparece ao lado do status, também para o requerente.
- **Novidades:** notificação do Windows e número no ícone da barra de tarefas e da bandeja.
- **Tema:** na engrenagem (canto superior direito) — seguir o Windows, claro ou escuro, com ou sem as
  cores do GLPI.
- **Tamanho do texto:** Ctrl + aumenta, Ctrl − diminui e Ctrl 0 volta a 100% (também com Ctrl e a
  roda do mouse, ou na engrenagem, em **Tamanho do texto**). De 80% a 150%; a escolha fica salva para
  o usuário do Windows neste computador.

## Capturar, gravar e ver anexos

Na resposta do chamado e nos campos de anexo do formulário há **Anexar arquivo**, **Capturar tela** e
**Gravar tela**.

- **Capturar tela** e **Gravar tela** escondem o app e abrem uma barra no alto do monitor. Escolha o
  que entra:
  - **Área:** arraste na tela; ajuste pelas bordas ou com as setas;
  - **Tela inteira:** com mais de um monitor, a barra pergunta qual;
  - **Janela:** escolha a janela pela miniatura (clique duplo já captura).

  Depois, **Capturar** (ou **Gravar**) ou Enter; **Cancelar** ou Esc desiste. A barra não aparece no
  print nem no vídeo. Para tirá-la do caminho, arraste pela alça (os pontinhos à esquerda), até para
  outro monitor; o app lembra o lugar. Clique duplo na alça volta ao alto.
- **Áudio da gravação:** em **Áudio** na barra, escolha **Sem áudio**, **Microfone**, **Som do
  computador** ou os dois. Com microfone, o painel mostra o nível (fale para testar) e, se houver mais
  de um, qual usar. O app lembra a escolha. O som do computador inclui tudo o que tocar nele durante a
  gravação. O app só usa o microfone enquanto a gravação com áudio está aberta.
- **Gravando:** a barra mostra o tempo, o tempo máximo (definido pela TI; normalmente 5 minutos), o
  tamanho e um ícone quando há áudio. **Parar** ou Enter termina; **Cancelar** ou Esc descarta o
  vídeo. Perto do tamanho máximo que o servidor aceita aparece "Perto do limite", e a gravação para
  sozinha antes de passar dele.
- **Antes de enviar:** os anexos ficam numa lista com miniatura (o vídeo mostra a duração e se tem
  áudio). Clique num deles para ver em tamanho grande: imagem com zoom (roda do mouse, + e −) e
  arrastar; vídeo com o player. As setas passam de um anexo para outro, **Remover** tira da lista e Esc
  fecha. Na resposta, os anexos vão junto com **Enviar resposta** (ou **Salvar solução**); trocar de
  chamado e voltar não os perde.
- **Depois de enviados:** os anexos aparecem na linha do tempo, dentro do acompanhamento, da tarefa ou
  da solução em que foram enviados; os do próprio chamado aparecem como "Anexo". Clique para ver no
  app ou em **Baixar**.
- Arquivo maior que o limite do servidor é recusado na hora, com o tamanho dele e o limite.

## Sair e trocar de servidor

- **Sair** (engrenagem ou menu da bandeja): encerra a sessão neste computador e apaga o que é do
  usuário. O app continua na bandeja e não entra sozinho até o usuário pedir. **Fechar o GLPI Desktop
  Client**, no menu da bandeja, encerra o app.
- **Trocar servidor** (engrenagem): sai da sessão, esquece o servidor escolhido e volta para "Conectar
  ao servidor". Não aparece quando o administrador travou o servidor (`lockServer`).
