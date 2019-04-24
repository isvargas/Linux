#!/bin/bash
#Exemplo de como enviar arquivos para o DropBox atraves da linha de comando.
#Para isso funcionar voce deve:
#1. Ter uma conta no DropBox (obviamente)
#2. Acessar o https://www.dropbox.com/developers/apps e criar um app que recebera os dados
#3. Nas configuracoes do app criado, gere um token para o mesmo clicando em "Generated access token".
#4. Neste script, troque o <SEU_TOKEN> para o token gerado.
#5. De permissoes de execucao (chmod +x) e rode o script. Exemplo:
#   $ ./upload_dropbox.sh seuarquivoaqui.zip
#
#Observacoes:
#1. Os dados serao enviados para o diretorio do seu aplicativo. Na raiz do seu dropbox sera criado
#   um diretorio chamado "Aplicativos", e dentro dele um dir para cada app.
#2. Neste exemplo envio o arquivo para uma pasta chamada backup. Se ela nao existe, sera criada automaticamente.
#3. O retorno do comando envio para out.txt. O dropbox retorna um JSON com as informacoes do upload.
#---
#Author: Ivan S. Vargas | ivan@is5.com.br
if [ $# -lt 1 ];
then
  echo "Especifique o nome do arquivo a ser enviado."
else
  echo "ENVIANDO ARQUIVO $1 PARA DROPBOX..."
  curl -X POST https://content.dropboxapi.com/2/files/upload \
               --header "Authorization: Bearer <SEU_TOKEN>" \
               --header "Dropbox-API-Arg: {\"path\": \"/backups/$1\"}" \
               --header "Content-Type: application/octet-stream" \
               --data-binary @$1 > out.txt

  echo "CONCLUIDO!"
fi
