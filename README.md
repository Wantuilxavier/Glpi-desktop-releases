# GLPI Desktop Client

Central de chamados do GLPI na bandeja do Windows, para qualquer organização que use o GLPI 11.

![Tela principal do GLPI Desktop Client com uma lista de chamados de exemplo](docs/imagens/tela-principal.png)

## O que faz

- Mostra os chamados do usuário com as mesmas permissões do perfil dele no GLPI.
- Abre chamados pelos formulários do próprio GLPI, com rascunho automático e captura de tela nos anexos.
- Avisa com notificações do Windows quando um chamado muda, com o número de novidades no ícone.
- Entra sozinho com a conta do Windows (opcional, com Active Directory) ou com usuário e senha.
- Tem tema claro e escuro e usa as cores do GLPI.
- Usa o nome, a logo, o ícone e o texto de suporte que o administrador definir no plugin.
- Conecta a qualquer servidor GLPI: o administrador define na instalação, ou o usuário informa na primeira abertura.

## Como funciona

```mermaid
flowchart LR
    subgraph Estações Windows
      A[GLPI Desktop Client]
    end
    subgraph Servidor GLPI 11
      P[plugin glpidesktop]
      G[GLPI e API REST]
    end
    A -- "HTTPS: login, identidade, ícone" --> P
    A -- "HTTPS: chamados e formulários" --> G
    P --- G
```

O plugin `glpidesktop` é **obrigatório**: é por ele que o app descobre como entrar (conta do Windows ou
senha), recebe a configuração do administrador e abre a sessão do usuário na API do GLPI.

## Downloads

Página de **[Releases](https://github.com/Wantuilxavier/Glpi-desktop-releases/releases)**:

| Arquivo | O que é |
|---|---|
| `glpidesktop-x.y.z.tar.bz2` | o plugin (a pasta raiz do pacote é `glpidesktop`, padrão do GLPI) |
| `GLPI-Desktop-Client-Setup-x.y.z.exe` | o instalador das estações |
| `SHA256SUMS.txt` | o SHA-256 dos dois arquivos |

Conferir o arquivo baixado:

```powershell
# Windows: compare o resultado com a linha do arquivo em SHA256SUMS.txt
Get-FileHash .\GLPI-Desktop-Client-Setup-0.1.0.exe -Algorithm SHA256
```

```bash
# Linux, na pasta com os arquivos e o SHA256SUMS.txt
sha256sum -c SHA256SUMS.txt --ignore-missing
```

## Compatibilidade

| Plugin | App | GLPI | PHP |
|---|---|---|---|
| 0.5.0 | 0.1.0 | 11.0.x | 8.2 ou mais novo |

App e plugin vêm juntos em cada release: use os dois da mesma release.

## Início rápido

1. [Instalar o plugin](docs/instalacao-plugin.md) no servidor GLPI.
2. [Configurar o plugin](docs/configuracao-plugin.md): cliente de API, autenticação, identidade e ícone.
3. [Instalar o app](docs/instalacao-estacoes.md) nas estações, manualmente ou em massa.
4. [Primeiro acesso](docs/primeiro-acesso.md) do usuário.

## Mais informações

- [Solução de problemas](docs/solucao-de-problemas.md)
- [CHANGELOG.md](CHANGELOG.md) — histórico de versões
- [SECURITY.md](SECURITY.md) — como relatar uma vulnerabilidade
- Licença: ainda não definida.
