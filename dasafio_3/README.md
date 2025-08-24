# Desafio 3 - Planejando um Media Player

Este documento detalha o planejamento completo para desenvolvimento de um media player que exibe playlists de arquivos MP4 e PNG sequencialmente na segunda tela do PC.

## 📋 Requisitos Funcionais

### Core Features
- ✅ Carregar playlist com arquivos MP4 e PNG
- ✅ Exibição sequencial na segunda tela (fullscreen)
- ✅ Controle de duração para imagens PNG
- ✅ Reordenação da playlist em tempo real
- ✅ Interface de controle separada da exibição

### Requisitos Técnicos
- **Formatos suportados**: MP4 (vídeo) e PNG (imagem)
- **Display**: Segunda tela em fullscreen
- **Controle**: Interface principal para configuração
- **Performance**: Transições suaves entre mídia
- **Usabilidade**: Controles intuitivos e responsivos

---

## 🏗️ Arquitetura do Sistema

### Componentes Principais

```
Media Player System
├── Control Interface (Tela Principal)
│   ├── Playlist Manager
│   ├── Duration Controls  
│   ├── File Browser
│   └── Playback Controls
├── Display Engine (Segunda Tela)
│   ├── Video Player
│   ├── Image Viewer
│   └── Transition Manager
└── Core Services
    ├── File Management
    ├── Playlist Engine
    └── Inter-screen Communication
```

### Tecnologias Recomendadas

**Opção 1: Electron + Web Technologies**
- **Frontend**: HTML5, CSS3, JavaScript/TypeScript
- **Media**: HTML5 Video API + Canvas
- **UI**: React/Vue.js + Electron
- **Styling**: Tailwind CSS ou Styled Components

**Opção 2: Desktop Nativo**
- **Python**: Tkinter/PyQt + VLC bindings
- **C#**: WPF + MediaElement
- **Java**: JavaFX + Media API
- **C++**: Qt + multimedia modules

**Opção 3: Web-based (Recomendada)**
- **Backend**: Node.js/Express ou Python/Flask
- **Frontend**: React/Vue.js
- **Media**: HTML5 APIs + WebRTC Screen Capture

---

## 🚀 Plano de Desenvolvimento

### Fase 1: Análise e Setup (Semana 1)
#### Pesquisa Técnica
- [ ] Estudar APIs de múltiplas telas
- [ ] Testar reprodução de MP4 e PNG
- [ ] Avaliar performance de transições
- [ ] Definir stack tecnológica final

#### Configuração Inicial
- [ ] Setup do ambiente de desenvolvimento
- [ ] Estrutura de pastas do projeto
- [ ] Configuração de build/deploy
- [ ] Documentação inicial

### Fase 2: MVP - Core Engine (Semana 2-3)
#### Funcionalidades Básicas
- [ ] **Display Engine**: Reprodução básica MP4/PNG
- [ ] **File Loading**: Carregar arquivos locais
- [ ] **Sequential Play**: Reprodução sequencial simples
- [ ] **Dual Screen**: Detecção e uso da segunda tela

#### Estrutura de Dados
```javascript
// Exemplo de estrutura da playlist
const playlist = [
  {
    id: '001',
    type: 'image',
    path: '/media/slide1.png',
    duration: 5000, // milissegundos
    order: 1
  },
  {
    id: '002', 
    type: 'video',
    path: '/media/video1.mp4',
    duration: null, // duração natural do vídeo
    order: 2
  }
];
```

### Fase 3: Interface de Controle (Semana 4-5)
#### Control Panel
- [ ] **Playlist View**: Lista drag-and-drop dos arquivos
- [ ] **Duration Controls**: Sliders para tempo das imagens
- [ ] **File Browser**: Adicionar/remover arquivos
- [ ] **Preview**: Miniatura dos arquivos
- [ ] **Playback Controls**: Play/Pause/Stop/Skip

#### UX/UI Design
- [ ] Wireframes das telas
- [ ] Design system (cores, tipografia, ícones)
- [ ] Protótipo interativo
- [ ] Testes de usabilidade

### Fase 4: Funcionalidades Avançadas (Semana 6-7)
#### Melhorias de Performance
- [ ] **Preloading**: Pré-carregamento da próxima mídia
- [ ] **Memory Management**: Limpeza de recursos não utilizados
- [ ] **Smooth Transitions**: Fade in/out entre mídias
- [ ] **Error Handling**: Tratamento de arquivos corrompidos

#### Recursos Extras
- [ ] **Hotkeys**: Atalhos de teclado
- [ ] **Auto-save**: Salvar configurações automaticamente
- [ ] **Import/Export**: Salvar/carregar playlists
- [ ] **Statistics**: Tempo total, quantidade de arquivos

### Fase 5: Testing & Polish (Semana 8)
#### Testes
- [ ] **Unit Tests**: Componentes individuais
- [ ] **Integration Tests**: Fluxo completo
- [ ] **Performance Tests**: Stress test com muitos arquivos
- [ ] **Device Tests**: Diferentes configurações de tela

#### Deploy & Documentação
- [ ] **Build Pipeline**: Automatização de builds
- [ ] **User Manual**: Documentação do usuário
- [ ] **Technical Docs**: Documentação técnica
- [ ] **Distribution**: Empacotamento final

---

## 🔧 Detalhes Técnicos

### Gerenciamento de Múltiplas Telas

**Electron Approach:**
```javascript
// Criar janela para segunda tela
const { screen } = require('electron');
const displays = screen.getAllDisplays();
const secondaryDisplay = displays.find(display => !display.primary);

if (secondaryDisplay) {
  playerWindow = new BrowserWindow({
    x: secondaryDisplay.bounds.x,
    y: secondaryDisplay.bounds.y,
    width: secondaryDisplay.bounds.width,
    height: secondaryDisplay.bounds.height,
    fullscreen: true,
    frame: false
  });
}
```

**Web API Approach:**
```javascript
// Usar Screen Capture API
async function openOnSecondScreen() {
  const mediaStream = await navigator.mediaDevices.getDisplayMedia({
    video: { mediaSource: 'screen' }
  });
  
  // Abrir popup na segunda tela
  const popup = window.open('', '', `
    left=${secondScreen.left},
    top=${secondScreen.top},
    width=${secondScreen.width},
    height=${secondScreen.height}
  `);
}
```

### Sistema de Playlist

**Estrutura de Estado:**
```javascript
class PlaylistManager {
  constructor() {
    this.playlist = [];
    this.currentIndex = 0;
    this.isPlaying = false;
    this.currentTimeout = null;
  }
  
  addFile(file) {
    const item = {
      id: generateId(),
      type: this.getFileType(file),
      path: file.path,
      duration: file.type === 'image' ? 5000 : null,
      order: this.playlist.length
    };
    this.playlist.push(item);
  }
  
  reorder(oldIndex, newIndex) {
    const item = this.playlist.splice(oldIndex, 1)[0];
    this.playlist.splice(newIndex, 0, item);
    this.updateOrder();
  }
  
  play() {
    this.isPlaying = true;
    this.playCurrentItem();
  }
  
  playCurrentItem() {
    const item = this.playlist[this.currentIndex];
    if (item.type === 'video') {
      this.playVideo(item);
    } else {
      this.playImage(item);
    }
  }
}
```

### Reprodução de Mídia

**Video Player:**
```javascript
function playVideo(videoItem) {
  const video = document.getElementById('player');
  video.src = videoItem.path;
  video.play();
  
  video.onended = () => {
    this.next();
  };
}
```

**Image Display:**
```javascript
function playImage(imageItem) {
  const img = document.getElementById('player');
  img.src = imageItem.path;
  img.style.display = 'block';
  
  this.currentTimeout = setTimeout(() => {
    this.next();
  }, imageItem.duration);
}
```

---

## 🎛️ Interface de Usuário

### Control Panel Layout

```
┌─────────────────────────────────────────────────┐
│ File Menu | Edit | View | Playback | Help       │
├─────────────────────────────────────────────────┤
│ [Add Files] [Remove] [Clear All] [Save Playlist]│
├─────────────────────────────────────────────────┤
│ Playlist (Drag & Drop)          │ File Preview  │
│ ┌─────────────────────────────┐ │ ┌───────────┐ │
│ │ 1. slide1.png    [5s] [↕]   │ │ │           │ │
│ │ 2. video1.mp4    [--] [↕]   │ │ │  Preview  │ │
│ │ 3. slide2.png    [3s] [↕]   │ │ │   Area    │ │
│ │ 4. video2.mp4    [--] [↕]   │ │ │           │ │
│ └─────────────────────────────┘ │ └───────────┘ │
├─────────────────────────────────────────────────┤
│ Duration Control: [====○====] 5.0s              │
├─────────────────────────────────────────────────┤
│ [⏮] [⏸] [▶] [⏭] [🔁] [🎯Second Screen]Status |
└─────────────────────────────────────────────────┘
```

### Display Screen (Segunda Tela)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│                                                 │
│                 CONTEÚDO                        │
│               (MP4 ou PNG)                      │
│                 FULLSCREEN                      │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ⚙️ Configurações e Persistência

### Arquivo de Configuração (JSON)
```json
{
  "settings": {
    "defaultImageDuration": 5000,
    "transitionType": "fade",
    "transitionDuration": 500,
    "autoPlay": true,
    "loop": false
  },
  "playlist": {
    "name": "Minha Playlist",
    "created": "2025-08-24T10:30:00Z",
    "items": [...]
  },
  "display": {
    "secondScreenIndex": 1,
    "fullscreen": true,
    "backgroundColor": "#000000"
  }
}
```

---

## 🚧 Desafios e Soluções

### Problema 1: Sincronização entre Telas
**Desafio**: Manter controle e exibição sincronizados
**Solução**: WebSocket local ou Electron IPC

### Problema 2: Performance com Arquivos Grandes
**Desafio**: Videos HD podem causar lag
**Solução**: Preloading inteligente e compressão

### Problema 3: Detecção de Segunda Tela
**Desafio**: Identificar automaticamente qual é a segunda tela
**Solução**: Interface para seleção manual + detecção automática

### Problema 4: Transições Suaves
**Desafio**: Evitar flicker entre mídias diferentes
**Solução**: Double buffering com divs sobrepostas

---

## 📊 Cronograma Resumido

| Semana | Foco | Entregáveis |
|--------|------|-------------|
| 1 | Análise & Setup | Arquitetura definida, ambiente configurado |
| 2-3 | Core Engine | Reprodução básica funcionando |
| 4-5 | Interface | Control panel completo |
| 6-7 | Features Avançadas | Funcionalidades extras |
| 8 | Testing & Deploy | Produto final testado |

**Estimativa total**: ~8 semanas para 1 desenvolvedor fullstack
**MVP funcional**: ~3 semanas

---

## 🎯 Critérios de Sucesso

### Funcionalidades Mínimas (MVP)
- [x] Carregar playlist MP4 + PNG
- [x] Exibir na segunda tela
- [x] Controlar duração das imagens
- [x] Reordenar playlist

### Qualidade Esperada
- **Performance**: <100ms para transições
- **Usabilidade**: Interface intuitiva sem treinamento
- **Confiabilidade**: 99.9% uptime durante reprodução
- **Compatibilidade**: Windows/Mac/Linux

### Métricas de Sucesso
- Tempo de setup < 5 minutos
- Curva de aprendizado < 10 minutos
- Feedback positivo de usuários beta
- Zero crashes durante uso normal

---

## 💡 Por onde começar?

### 1. **Prova de Conceito (2-3 dias)**
```javascript
// Teste simples: reproduzir MP4 e PNG alternadamente
// Verificar se consegue usar segunda tela
// Validar performance básica
```

### 2. **Definir Stack Tecnológica (1 dia)**
- Electron vs Web vs Desktop nativo
- Framework de UI (React/Vue vs nativo)
- Biblioteca de mídia

### 3. **Arquitetura de Dados (1 dia)**
- Estrutura da playlist
- Sistema de estado
- Persistência de configurações

### 4. **Interface Mockup (2 dias)**
- Wireframes das telas
- Fluxo de usuário
- Design system básico

### 5. **Desenvolvimento Iterativo**
- Começar com o core engine
- Adicionar interface gradualmente
- Testar constantemente

**Primeira tarefa prática**: Criar um HTML simples que alterne entre uma imagem e um vídeo a cada 5 segundos, testando se funciona na segunda tela.
