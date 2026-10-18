# Solução de problemas

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| "Não foi possível conectar. Verifique o endereço." / "Não foi possível falar com o servidor." | endereço errado, sem rede, firewall ou proxy no caminho | abra o mesmo endereço no navegador da estação; confira a configuração da máquina (`glpiUrl`) |
| Erro ao conectar só em algumas máquinas, com o endereço certo | certificado inválido: vencido, de outro nome, ou de uma autoridade interna que a estação não conhece | o app usa os certificados confiáveis do Windows e nunca aceita certificado inválido; instale a autoridade interna como confiável nas estações (GPO) ou corrija o certificado do servidor |
| "Não encontrei o plugin neste servidor" | plugin não instalado, desativado ou em outra pasta | [instale e ative](instalacao-plugin.md) o plugin na pasta `glpidesktop` |
| "O plugin do GLPI está desatualizado" | plugin mais antigo que o app | atualize o plugin para a versão da mesma release do app |
| "Esta versão do aplicativo está desatualizada" | app mais antigo que o mínimo do plugin | instale o app da release mais recente |
| "O plugin do GLPI ainda não tem o cliente de API configurado" | aba Conexão sem cliente de API e estação sem App-Token | escolha o cliente de API na [aba Conexão](configuracao-plugin.md#conexão) |
| Entra, mas nada carrega | App-Token recusado ou IP da estação fora da faixa do cliente de API | *Configurar → Geral → API*: cliente ativo, App-Token e faixa de IP das redes das estações |
| O login com a conta do Windows não entra | estação fora do domínio ou da rede, servidor web sem Kerberos, ou endereço fora dos domínios do SSO | teste se o navegador entra no GLPI sem senha; confira os [requisitos do SSO](configuracao-plugin.md#login-com-a-conta-do-windows-sso-com-active-directory) e o campo "Domínios do SSO" |
| "Usuário ou senha incorretos." | senha errada, ou usuário que não existe no GLPI | confira se o usuário entra no GLPI pelo navegador com a mesma senha |
| "Sua conta está bloqueada ou expirada." | conta desativada no GLPI ou bloqueada no AD | procure o administrador do GLPI/AD |
| Não vejo os chamados do meu grupo | o perfil ativo não tem permissão para ver chamados do grupo, ou o usuário não está no grupo | troque de perfil no cabeçalho do app (se tiver mais de um) ou ajuste o perfil no GLPI |
| O ícone ou a logo não mudou | o app confere na próxima conexão; o atalho do Menu Iniciar de todos os usuários não muda | feche e abra o app; ícone do instalador e de "Aplicativos instalados" não mudam por natureza |
| "Trocar servidor" não aparece | o administrador travou o servidor (`lockServer`) | esperado; quem define o servidor é a configuração da máquina |

## Logs na estação

- Log do app, por usuário: `%APPDATA%\GLPI Desktop Client\logs\glpi-desktop-client.log` (sem senhas
  nem tokens). Ao pedir ajuda, envie só as linhas do erro.
- Configuração da máquina: `reg query HKLM\SOFTWARE\GlpiDesktopClient`,
  `reg query HKLM\SOFTWARE\Policies\GlpiDesktopClient` e
  `C:\ProgramData\GlpiDesktopClient\config.json`.
- No servidor: o log de eventos do GLPI (*Administração → Logs*) mostra os logins e as mudanças na
  aba Autenticação; erros do PHP ficam em `files/_log/php-errors.log`.
