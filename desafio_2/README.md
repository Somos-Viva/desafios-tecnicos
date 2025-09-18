# Desafio 2 - Produzindo código Python com prompts para IA generativa

Este diretório contém um guia de prompts para gerar código Python usando **Flask** e HTML5/JS para atender às novas necessidades do desafio. **Não contém código pronto**, apenas prompts detalhados para IA.

---

## 1. Página para exibir o conteúdo da planilha `editorias.csv`

**Prompt sugerido:**

```
Crie uma rota Flask chamada /editorias que lê o arquivo 'editorias.csv' (colocado na mesma pasta do projeto)
e exibe seu conteúdo em uma tabela HTML.
Use pandas para leitura da planilha.
O HTML deve ter cabeçalho e linhas formatadas de forma clara.
Inclua importações necessárias e render_template do Flask.
```

**Dificuldades:**
- Esquecer de importar pandas ou Flask.
- Não usar Jinja2 para templates.

**Refinamento:**
- Solicitar explicitamente “usar Flask + Jinja2”.

---

## 2. Página que acessa `https://catfact.ninja/fact`

**Prompt sugerido:**

```
Crie uma rota Flask chamada /catfact que faz uma requisição GET para a API https://catfact.ninja/fact,
pega o campo 'fact' do JSON retornado e exibe em uma página HTML simples.
Inclua tratamento de erros caso a API não responda.
```

**Dificuldades:**
- Esquecer de usar requests.
- Falta de tratamento de exceções.

**Refinamento:**
- Solicitar “incluir try/except para requisições HTTP”.

---

## 3. Página em HTML5 que lê o horário do computador do usuário

**Prompt sugerido:**

```
Crie uma rota Flask chamada /horario que exibe uma página HTML5.
A página deve mostrar a hora atual do computador do usuário usando JavaScript.
Quando o usuário passa o mouse sobre a hora, a cor do texto deve mudar.
Atualize a hora em tempo real a cada segundo.
```

**Dificuldades:**
- IA pode gerar apenas o horário do servidor, não do navegador.
- Mudança de cor precisa de :hover ou evento JS.
- Atualização dinâmica precisa de setInterval.

**Refinamento:**
- Especificar “usar apenas JS no frontend, não recarregar a página”.

---

## 4. Página que liga a câmera e tira foto do usuário

**Prompt sugerido:**

```
Crie uma rota Flask chamada /camera que exibe uma página HTML5.
A página deve acessar a câmera do usuário (usando getUserMedia), mostrar o vídeo ao vivo e incluir um botão 'Tirar foto'.
Quando o botão for clicado, a foto deve ser capturada e exibida abaixo do vídeo.
Não é necessário enviar a imagem para o servidor, apenas exibir no navegador.
Inclua tratamento para caso o usuário negue o acesso à câmera.
```

**Dificuldades:**
- Lidar com permissões do navegador.
- Captura da imagem precisa de <canvas> e JS.
- Compatibilidade com navegadores.

**Refinamento:**
- Especificar “compatível com todos os navegadores modernos”.
- Incluir “usar canvas para capturar e exibir a foto”.

---

## Dicas gerais para prompts de IA generativa

1. Seja específico sobre a tecnologia:
   - Ex.: Flask + Jinja2 + pandas + requests + HTML5 + JavaScript
2. Defina claramente a funcionalidade:
   - O que o usuário deve ver.
   - Qual dado usar e de onde.
   - Interação desejada.
3. Incluir tratamentos de erro:
   - Permissões negadas.
   - Falha de API.
4. Solicitar código completo pronto para rodar:
   - Inclua imports, inicialização do Flask, rotas e templates.
5. Se necessário, peça explicações linha a linha para entender como o código funciona.

