# Prompts para IA Generativa - Desafio 2

Este documento detalha os prompts que seriam utilizados para instruir uma IA generativa a desenvolver as novas funcionalidades para o servidor Flask, conforme solicitado no Desafio 2. Serão abordadas as dificuldades esperadas e o processo de desenvolvimento para cada funcionalidade.

## 1. Página para Exibir Conteúdo da Planilha "editorias.csv"

### Dificuldades Esperadas:

*   **Leitura e Parsing do CSV**: A IA precisaria entender como ler um arquivo CSV no ambiente Flask, considerando diferentes codificações e delimitadores.
*   **Estruturação dos Dados**: Converter os dados do CSV para uma estrutura Python (e.g., lista de dicionários) que seja fácil de manipular e passar para um template HTML.
*   **Renderização HTML**: Gerar uma tabela HTML ou outra estrutura visualmente agradável para exibir os dados, garantindo responsividade e acessibilidade.
*   **Tratamento de Erros**: Lidar com a ausência do arquivo, erros de leitura ou CSVs mal formatados.

### Processo Sugerido para a IA:

1.  **Criação da Rota Flask**: Definir uma nova rota no `app.py` que será responsável por esta funcionalidade.
2.  **Leitura do Arquivo**: Utilizar bibliotecas Python (e.g., `csv` ou `pandas` se disponível) para ler o `editorias.csv`.
3.  **Processamento dos Dados**: Organizar os dados lidos em um formato adequado para exibição.
4.  **Criação do Template HTML**: Gerar um arquivo HTML (e.g., `editorias.html`) com uma tabela para exibir os dados, utilizando Jinja2 para renderização.
5.  **Passagem de Dados**: Passar os dados processados para o template HTML.
6.  **Tratamento de Exceções**: Implementar blocos `try-except` para lidar com possíveis erros de arquivo.

### Prompt para IA Generativa:

"""
Crie uma nova rota Flask em `app.py` chamada `/editorias`. Esta rota deve ler o conteúdo do arquivo `editorias.csv` (assuma que ele estará na mesma pasta do `app.py`). O arquivo CSV possui cabeçalho. Parse o CSV e exiba os dados em uma tabela HTML. Crie um novo arquivo HTML chamado `editorias.html` para o template, que deve estar na pasta `templates`. A tabela HTML deve ter um cabeçalho com os nomes das colunas do CSV e cada linha da tabela deve representar uma linha do CSV. Certifique-se de que a página seja responsiva. Adicione tratamento de erro caso o arquivo `editorias.csv` não seja encontrado ou esteja mal formatado, exibindo uma mensagem amigável ao usuário.
"""

## 2. Página que Acessa `https://catfact.ninja/fact` e Exibe a Resposta Formatada

### Dificuldades Esperadas:

*   **Requisição HTTP**: A IA precisaria saber como fazer uma requisição GET para uma API externa usando Python (e.g., `requests`).
*   **Parsing JSON**: Entender como lidar com a resposta JSON da API e extrair o dado relevante (`fact`).
*   **Exibição Dinâmica**: Inserir o fato obtido da API no HTML de forma dinâmica.
*   **Tratamento de Erros da API**: Lidar com falhas na requisição, respostas inesperadas ou indisponibilidade da API.

### Processo Sugerido para a IA:

1.  **Criação da Rota Flask**: Definir uma nova rota no `app.py` para esta funcionalidade.
2.  **Requisição à API**: Fazer a requisição HTTP para `https://catfact.ninja/fact`.
3.  **Processamento da Resposta**: Verificar o status da resposta e extrair o campo `fact` do JSON.
4.  **Criação do Template HTML**: Gerar um arquivo HTML (e.g., `catfact.html`) para exibir o fato.
5.  **Passagem de Dados**: Passar o fato extraído para o template HTML.
6.  **Tratamento de Exceções**: Implementar tratamento de erros para falhas na requisição ou no parsing JSON.

### Prompt para IA Generativa:

"""
Crie uma nova rota Flask em `app.py` chamada `/catfact`. Esta rota deve fazer uma requisição GET para a API `https://catfact.ninja/fact`. Após receber a resposta, extraia o campo `fact` do JSON. Exiba este fato em uma página HTML. Crie um novo arquivo HTML chamado `catfact.html` para o template, que deve estar na pasta `templates`. O fato deve ser exibido em um parágrafo centralizado na página. Adicione tratamento de erro para casos em que a requisição à API falhe ou a resposta JSON seja inválida, exibindo uma mensagem apropriada ao usuário.
"""

## 3. Página em HTML5 que Lê o Horário do Computador de Quem Está Navegando no Site e Exibe o Horário - Quando o Mouse Passa por Cima do Horário, a Hora Muda de Cor

### Dificuldades Esperadas:

*   **JavaScript para Horário Local**: A IA precisaria gerar código JavaScript para obter o horário do cliente, não do servidor.
*   **Atualização Dinâmica**: Manter o horário atualizado em tempo real sem recarregar a página.
*   **Manipulação de DOM e Eventos**: Adicionar e remover classes CSS ou alterar estilos diretamente via JavaScript para a mudança de cor ao passar o mouse.
*   **CSS para Estilização**: Criar o CSS necessário para a aparência inicial e a mudança de cor.

### Processo Sugerido para a IA:

1.  **Criação da Rota Flask**: Definir uma nova rota no `app.py` que servirá a página HTML.
2.  **Criação do Template HTML**: Gerar um arquivo HTML (e.g., `horario.html`) que incluirá:
    *   Um elemento `<span>` ou `<div>` para exibir o horário.
    *   Um bloco `<script>` com JavaScript para:
        *   Obter o horário atual do cliente.
        *   Atualizar o elemento HTML a cada segundo (usando `setInterval`).
        *   Adicionar e remover event listeners para `mouseover` e `mouseout` para mudar a cor do texto.
    *   Um bloco `<style>` com CSS para estilizar o horário e definir a cor inicial e a cor ao passar o mouse.

### Prompt para IA Generativa:

"""
Crie uma nova rota Flask em `app.py` chamada `/horario`. Esta rota deve renderizar uma página HTML que exibe o horário atual do computador do usuário (cliente). O horário deve ser atualizado a cada segundo. Quando o mouse passar por cima do horário, a cor do texto deve mudar para azul. Quando o mouse sair, a cor deve voltar para preto. Crie um novo arquivo HTML chamado `horario.html` para o template, que deve estar na pasta `templates`. O HTML deve incluir o JavaScript e o CSS necessários diretamente no arquivo.
"""

## 4. Nova Página que Ligue a Câmera do Usuário e Tire uma Foto do Usuário Quando Ele Clicar em um Botão

### Dificuldades Esperadas:

*   **Acesso à Câmera (WebRTC)**: A IA precisaria gerar código JavaScript que utiliza a API `getUserMedia` para acessar a câmera do usuário, o que envolve permissões do navegador.
*   **Exibição do Stream**: Mostrar o feed da câmera em um elemento `<video>`.
*   **Captura da Imagem**: Tirar uma "foto" do stream de vídeo e desenhá-la em um elemento `<canvas>`.
*   **Download da Imagem**: Converter o conteúdo do canvas para uma imagem (e.g., PNG) e permitir que o usuário a baixe.
*   **Compatibilidade e Permissões**: Lidar com a compatibilidade do navegador e as solicitações de permissão do usuário.

### Processo Sugerido para a IA:

1.  **Criação da Rota Flask**: Definir uma nova rota no `app.py` que servirá a página HTML.
2.  **Criação do Template HTML**: Gerar um arquivo HTML (e.g., `camera.html`) que incluirá:
    *   Um elemento `<video>` para exibir o stream da câmera.
    *   Um botão para tirar a foto.
    *   Um elemento `<canvas>` para desenhar a foto capturada.
    *   Um link `<a>` para download da imagem.
    *   Um bloco `<script>` com JavaScript para:
        *   Solicitar acesso à câmera (`navigator.mediaDevices.getUserMedia`).
        *   Reproduzir o stream no elemento `<video>`.
        *   Adicionar um event listener ao botão para:
            *   Desenhar o frame atual do vídeo no canvas.
            *   Converter o canvas para uma URL de dados (base64).
            *   Definir esta URL como `href` do link de download e o atributo `download`.

### Prompt para IA Generativa:

"""
Crie uma nova rota Flask em `app.py` chamada `/camera`. Esta rota deve renderizar uma página HTML que permite ao usuário acessar sua câmera, visualizar o feed e tirar uma foto ao clicar em um botão. A foto deve ser exibida na página e o usuário deve ter a opção de baixá-la. Crie um novo arquivo HTML chamado `camera.html` para o template, que deve estar na pasta `templates`. O HTML deve incluir o JavaScript necessário para interagir com a câmera (WebRTC), exibir o stream em um elemento de vídeo, capturar um frame em um canvas e permitir o download da imagem. Adicione um botão para "Tirar Foto".
"""
