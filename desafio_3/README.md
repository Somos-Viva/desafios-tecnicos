# Desafio 3 - Media Player com Playlist Dinâmica

## Objetivo
Desenvolver um **media player** que carrega uma playlist contendo arquivos **MP4 (vídeos)** e **PNG (imagens)**, exibindo-os **sequencialmente na segunda tela do PC**. O usuário deve poder:

- Modificar **quanto tempo cada imagem (PNG) é exibida**.
- Alterar a **ordem dos arquivos** a qualquer momento.

---

## Requisitos Funcionais

1. Carregar uma playlist com vídeos e imagens.
2. Exibir os arquivos sequencialmente na **segunda tela**.
3. Permitir que o usuário:
   - Altere a duração de exibição das imagens.
   - Reordene arquivos na playlist.
4. Atualizar a reprodução **em tempo real** quando o usuário fizer alterações.

---

## Funcionalidades Principais

### 1. Playlist
- Estrutura de dados para armazenar arquivos:
  - Tipo (`video` ou `image`)
  - Caminho do arquivo
  - Duração (apenas para imagens)
- Funções:
  - Adicionar/remover arquivos
  - Alterar ordem
  - Modificar duração das imagens

### 2. Player
- Detecta tipo de arquivo:
  - **MP4** → reproduz vídeo
  - **PNG** → exibe por tempo definido
- Controla transição entre arquivos
- Exibe conteúdo na **segunda tela**

### 3. Interface do Usuário
- Permite:
  - Visualizar playlist
  - Alterar duração das imagens
  - Reordenar arquivos
  - Iniciar/pausar reprodução
- Sugestões de implementação:
  - **Python Desktop GUI:** PyQt ou Tkinter
  - **Web app local:** HTML/JS + Electron

### 4. Configurações da Tela
- Detectar múltiplos monitores
- Abrir a janela do media player na segunda tela

---

## Tecnologias Sugeridas

| Parte                  | Sugestão Python                  | Sugestão Web/Outros      |
|------------------------|---------------------------------|-------------------------|
| GUI                    | PyQt, Tkinter                   | Electron, React         |
| Player de vídeo/imagem | OpenCV, Pygame, VLC Python bindings | HTML5 `<video>` + `<img>` |
| Multitela              | PyQt/QDesktopWidget, screeninfo | Electron + Screen API   |
| Gerenciamento playlist | Lista/Array + JSON para salvar  | JSON ou LocalStorage    |

---

## Estrutura de Dados (Exemplo)

```python
playlist = [
    {"file": "video1.mp4", "type": "video"},
    {"file": "image1.png", "type": "image", "duration": 5},
    {"file": "video2.mp4", "type": "video"},
    {"file": "image2.png", "type": "image", "duration": 10},
]
