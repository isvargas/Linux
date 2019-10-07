#!/bin/bash
#Script para realizar o backup de varios banco de dados PostgreSQL e gravar em um arquivo ZIP.
#O backup sera gerado no formato de scripts (create, insert) e em .tar.
#Observacoes
#1.O pg_dump, por padrao, vai pedir a senha do usuario para realizar a operacao, o que poderia
#  quebrar a funcao desse script. Para resolver isso podemos configurar um arquivo na home do usuario
#  com as devidas configuracoes para cada banco. O pg_dump ira buscar neste arquivo a senha do usuario,
#  por exemplo. 
#  O arquivo segue o seguinte padrao:
#     host:porta:banco:user:pass
#  Podendo ter varias linhas no mesmo.
#  O arquivo deve se chamar .pgpass, e estar no diretorio home do usuario.
#  Detalhe: este arquivo deve ser configurado com chmod 0600, impedindo assim que outros
#  usuarios, alem de vc, tenham permissao de ler o conteudo e descobrir suas senhas :).
#
#2.Neste exemplo tenho dois arrays: um especificando os servidores, e o outro especificando
#o nome do banco de dados. Como nas revendas por ai o nome do usuario eh o mesmo nome do banco
#utilizo o mesmo array para referenciar ambos. Se seu caso for diferente, basta criar outro array
#com o nome de usuario.
#---
#Author: Ivan S. Vargas | ivan@is5.com.br
data=$(date +%d-%m-%Y)

#servidores
SERVIDORES=("pgsql.server1.com" "pgsql.server2.com" "pgsql.server3.com")

#bancos de dados
DATABASES=("server1" "server2" "server3")

#realiza o backup (metadata e inserts)
#para ignorar algum schema: --exclude-schema='esquema'
#para ignorar dados de uma tabela: --exclude-table-data='tabela'
#Obs: utilize uma declaracao para cada tabela ou esquema que for ignorar.
for ((i=0; i < ${#SERVIDORES[*]}; i++)); do
  echo "[+]Backupeando ${DATABASES[i]}"
  dest="${DATABASES[$i]}-$data.sql"
  destraw="${DATABASES[$i]}-$data.bkp"
  #copia em formato de texto
  pg_dump -h ${SERVIDORES[$i]} -p 5432 -U ${DATABASES[$i]} -F plain --create --inserts --column-inserts --exclude-schema='comum'  --exclude-schema='fiscal' --exclude-table-data='public.ci_sessions' --exclude-table-data='public.municipios'  -f $dest ${DATABASES[$i]}
  #copia em formato binario
  pg_dump -h ${SERVIDORES[$i]} -p 5432 -U ${DATABASES[$i]} -d ${DATABASES[$i]} --exclude-schema='comum' --exclude-schema='fiscal' --exclude-table-data='public.ci_sessions' --exclude-table-data='public.municipios' --format tar --file $destraw
done

#compacta arquivos
echo "[+]Compactando arquivos"
destzip="databases-$data.zip"
zip $destzip *$data.sql *$data.bkp


#concluido
echo "[!]Concluido. Arquivo de backup: $destzip."
