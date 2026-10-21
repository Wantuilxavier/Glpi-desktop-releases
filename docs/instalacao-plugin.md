# Instalação do plugin

O plugin `glpidesktop` fica no servidor GLPI e é obrigatório para o app funcionar.

## Requisitos

- GLPI **11.0.x** (o plugin recusa o 11.1 e o 12).
- PHP **8.2** ou mais novo. A extensão **GD** é opcional: serve para gerar o `.ico` quando o
  administrador envia um ícone personalizado em PNG.
- GLPI acessado por **HTTPS** pelas estações.
- **API REST do GLPI** ativada, em *Configurar → Geral → API*:
  - **Habilitar a API REST**: sim;
  - **Habilitar o login com token externo**: sim (o app entra na API com a chave do próprio usuário);
  - **Habilitar o login com credenciais**: não é usado pelo app (veja
    [Autenticação](configuracao-plugin.md#autenticação)).

## Instalar

1. Baixe `glpidesktop-x.y.z.tar.bz2` na página de
   [Releases](https://github.com/Wantuilxavier/Glpi-desktop-releases/releases) e confira o SHA-256.
2. Extraia em `<raiz-do-glpi>/plugins/` (ou `<raiz-do-glpi>/marketplace/`):

   ```bash
   cd /var/www/glpi/plugins            # ajuste para a raiz do seu GLPI
   tar -xjf /caminho/glpidesktop-0.14.0.tar.bz2
   ```

3. Confira:
   - a pasta se chama exatamente `glpidesktop` (com `setup.php` dentro);
   - o dono dos arquivos é o usuário do servidor web, por exemplo
     `chown -R www-data:www-data glpidesktop` no Debian/Ubuntu.
4. No GLPI: **Configurar → Plugins** → *GLPI Desktop Client* → **Instalar** e depois **Ativar**.

Pela linha de comando, na raiz do GLPI, o equivalente é:

```bash
php bin/console plugin:install --username=<login-de-um-administrador> glpidesktop
php bin/console plugin:activate glpidesktop
```

Em seguida, [configure o plugin](configuracao-plugin.md).

## Atualizar

1. Guarde uma cópia da pasta atual (`cp -a plugins/glpidesktop /root/glpidesktop-antigo`).
2. Apague a pasta antiga e extraia a nova no mesmo lugar, para não sobrar arquivo que saiu da versão.
   Acerte o dono dos arquivos.
3. Recarregue o PHP, para ele não continuar com os arquivos antigos em cache: por exemplo,
   `systemctl reload php8.2-fpm` (ou o serviço do PHP do seu servidor).
4. Em **Configurar → Plugins**, o plugin aparece como "a atualizar": clique em **Atualizar** e depois
   em **Ativar**. Pela linha de comando:

   ```bash
   php bin/console plugin:install --force --username=<login-de-um-administrador> glpidesktop
   php bin/console plugin:activate glpidesktop
   php bin/console cache:clear
   ```

Enquanto o plugin está "a atualizar", o app não consegue entrar. Se o plugin voltar a aparecer
desativado logo depois da atualização, recarregue o PHP de novo e repita o passo 4. A configuração
do plugin é mantida.

## Desinstalar

**Configurar → Plugins** → *GLPI Desktop Client* → **Desativar** e **Desinstalar**. A desinstalação apaga:

- toda a configuração do plugin (identidade, conexão, autenticação, ícone);
- a logo e o ícone personalizado enviados (em `files/_plugins/glpidesktop/`).

Não apaga nada dos usuários nem dos chamados. As chaves de API (`api_token`) que o GLPI gerou para os
usuários continuam neles e podem ser regeneradas em *Preferências*. Depois de desinstalar, apague a
pasta `plugins/glpidesktop`.
