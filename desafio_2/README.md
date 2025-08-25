# Desafio 2 - Processo de Desenvolvimento com IA Generativa

## Introdução

# Desafio 2 - Usando IA Generativa

Este documento explica o processo de como eu usaria IA generativa para implementar as funcionalidades solicitadas, focando nas dificuldades e no processo, não no código em si.

## Como Abordar o Desenvolvimento com IA

### Processo Geral

1. **Entendimento do Problema**
   - Ler e compreender completamente o requisito
   - Identificar possíveis desafios técnicos
   - Pensar nas bibliotecas/ferramentas necessárias

2. **Criação do Prompt**
   - Ser específico e detalhado
   - Incluir contexto relevante
   - Pedir exemplos e explicações

3. **Análise e Adaptação**
   - Revisar o código gerado
   - Entender cada parte
   - Identificar possíveis melhorias

4. **Refinamento**
   - Solicitar ajustes específicos
   - Pedir otimizações
   - Garantir boas práticas

## Prompts para Cada Funcionalidade

### 1. Página do CSV

#### Primeira Iteração
```
"Preciso ajuda para criar uma rota no Flask que:
1. Leia um arquivo CSV chamado 'editorias.csv'
2. O arquivo tem colunas: Editoria, Tom, Paleta e Texto de Exemplo
3. O conteúdo deve ser exibido em uma página HTML
4. Os caracteres especiais em português precisam funcionar

Me mostre:
1. Como ler o arquivo CSV com encoding correto
2. Como criar uma rota Flask para isso
3. Como fazer um template HTML simples
4. Como tratar possíveis erros"
```

**Por que este prompt é bom:**
- Especifica exatamente o que queremos
- Menciona o problema dos caracteres especiais
- Pede tratamento de erros
- Divide em partes claras

#### Segunda Iteração
```
"O código está funcionando, mas preciso melhorar:
1. Adicionar Bootstrap para deixar bonito
2. Fazer a tabela ser responsiva
3. Adicionar ordenação por coluna
4. Permitir filtrar o conteúdo

Pode me ajudar a implementar essas melhorias?"
```

### 2. Página de Fatos sobre Gatos

#### Primeira Iteração
```
"Estou criando uma página que consome a API catfact.ninja/fact. Preciso:
1. Fazer a requisição GET
2. Mostrar o resultado em uma página bonita
3. Ter um botão para carregar novo fato
4. Não recarregar a página inteira

Me ajude com:
1. A rota Flask necessária
2. O código JavaScript para a requisição
3. Um template HTML básico
4. Tratamento de erros da API"
```

#### Segunda Iteração
```
"Quero melhorar a experiência do usuário:
1. Mostrar loading enquanto carrega
2. Animar a transição entre fatos
3. Salvar o último fato caso a API falhe
4. Melhorar o visual com Bootstrap

Como posso implementar essas melhorias?"
```

### 3. Página do Relógio

#### Primeira Iteração
```
"Preciso criar uma página com um relógio digital que:
1. Mostra a hora atual do navegador
2. Atualiza a cada segundo
3. Muda de cor quando passa o mouse
4. Usa JavaScript puro

Me ajude com:
1. O HTML necessário
2. O JavaScript para atualizar o relógio
3. O CSS para a mudança de cor
4. A rota Flask para servir a página"
```

#### Segunda Iteração
```
"Para melhorar o relógio, quero:
1. Adicionar transição suave de cores
2. Permitir escolher formato 12h/24h
3. Adicionar data junto ao horário
4. Melhorar o design geral

Como implementar estas melhorias?"
```

### 4. Página da Câmera

#### Primeira Iteração
```
"Preciso criar uma página que:
1. Acesse a câmera do usuário
2. Mostre o preview da câmera
3. Permita tirar foto
4. Funcione em navegadores modernos

Me ajude com:
1. O HTML para câmera e botões
2. O JavaScript para acessar a câmera
3. O código para capturar a foto
4. O tratamento de permissões"
```

#### Segunda Iteração
```
"Quero adicionar recursos:
1. Escolher entre câmeras disponíveis
2. Mostrar flash visual ao tirar foto
3. Permitir baixar a foto
4. Melhorar feedback ao usuário

Como implementar estas funcionalidades?"
```

## Dificuldades e Soluções

### Página do CSV
- **Dificuldade**: Encoding de caracteres especiais
- **Solução**: Especificar UTF-8 no prompt e pedir exemplo de tratamento

### Página de Fatos
- **Dificuldade**: Atualizações assíncronas
- **Solução**: Pedir exemplos específicos de AJAX/Fetch

### Página do Relógio
- **Dificuldade**: Atualizações suaves
- **Solução**: Solicitar exemplos de transições CSS

### Página da Câmera
- **Dificuldade**: Compatibilidade entre navegadores
- **Solução**: Pedir código com verificações de suporte

## Dicas para Prompts Efetivos

1. **Seja Específico**
   - Descreva exatamente o que você quer
   - Liste todos os requisitos
   - Mencione limitações importantes

2. **Peça Exemplos**
   - Solicite casos de uso
   - Peça explicações do código
   - Requeira comentários

3. **Itere Gradualmente**
   - Comece com versão básica
   - Adicione recursos aos poucos
   - Refine com feedback

4. **Foque na Compreensão**
   - Peça explicações
   - Questione decisões
   - Entenda o código gerado

## Conclusão

O uso efetivo de IA generativa para desenvolvimento requer:
- Prompts bem estruturados
- Processo iterativo
- Compreensão do código gerado
- Foco na qualidade e manutenibilidade
