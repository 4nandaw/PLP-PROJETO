# SICODI - Haskell

## Funcionalidades

- Conheça todas as funcionalidades disponíveis acessando a [documentação oficial do projeto](https://docs.google.com/document/d/1-fbfaGj1wzGZkykMTlaCoOr7ITP9GOQND91S7UgrVJs/edit). 

- Vídeo de apresentação do SICODI em Haskell: https://youtu.be/xdK59hDmNZ8.


## Rodando localmente

### Cuidado!
É preciso que você tenha o Stack instalado e atualizado em sua máquina. Saiba mais acessando o [Haskell Tool Stack](https://docs.haskellstack.org/en/stable/).

Tudo pronto? Vamos em frente!

Clone o projeto em sua IDE

```bash
  git clone https://github.com/4nandaw/PLP-PROJETO.git
```

Entre no diretório do projeto

```bash
  cd SICODI
```

Instale as dependências

```bash
  stack build
```

Execute o programa com

```bash
  stack exec SICODI-exe
```
Caso tudo tenha dado certo, agora você pode executar sempre com
```bash
  stack run
```

Ainda é possível que o programa apresente erros porque você não está com o stack devidamente atualizado. Atualize-o com o comando abaixo e tente novamente.
```bash
  stack upgrade
```
