# Desafio 3 - Planejamento Profissional de Media Player

## Análise de Alternativas Tecnológicas

Para uma decisão clara e executiva, comparamos as principais abordagemns tecnológicas numa tabela, avaliando critérios essenciais para o projeto.

| Critério                  | Electron.js (JS/TS)                                | .NET MAUI (C#)                                     | Python + PyQt6                                                              |
| ------------------------- | -------------------------------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------- |
| **Performance** | Boa, mas com maior uso de RAM/CPU                  | Excelente (Nativa)                                 | Excelente (UI via C++/Qt)                                                   |
| **Controle do Sistema** | Bom, com APIs nativas                              | Excelente                                          | Excelente, com bindings diretos                                             |
| **Ecossistema de Mídia** | Bom (via wrappers FFmpeg)                          | Bom (via bibliotecas .NET)                         | **Excecional** (PyAV, OpenCV, etc.)                                         |
| **Velocidade de Dev. UI** | Muito Alta (React, CSS)                            | Média (XAML)                                       | Média (Qt Designer, QSS)                                                    |
| **Velocidade de Dev. Lógica** | Alta                                               | Média                                              | **Muito Alta** (Python)                                                     |
| **Curva de Aprendizado** | Baixa (para devs web)                              | Média-Alta                                         | Média                                                                       |

### 1. Electron.js + Node.js

**Prós:**

* Desenvolvimento com JavaScript/TypeScript familiar
* Ótima documentação e comunidade ativa
* Fácil criação de UI moderna
* Suporte nativo a multi-janelas
* Integração natural com APIs do sistema
* NPM para gerenciamento de pacotes

**Contras:**

* Uso de memória maior que aplicações nativas
* Tamanho do executável final

### 2. Abordagem Nativa Compilada: .NET MAUI (C#)

**Prós:**

* Performance nativa e baixo consumo de recursos
* Ecossistema robusto e linguagem C# fortemente tipada
* Renderiza controles de UI nativos de cada SO

**Contras:**

* Curva de aprendizado do ecossistema .NET e XAML
* Menos agilidade para scripting e automação de arquivos

### 3. Python + PyQt6

**Prós:**

* Controle granular e de alta performance da UI (via Qt/C++)
* Acesso direto ao vasto ecossistema Python para mídia e dados
* Agilidade do Python para a lógica de negócio
* Excelente para integração com sistemas e automação

**Contras:**

* UI programática pode ser mais verbosa que a declarativa (HTML/XAML)
* Requer empacotamento para distribuição (PyInstaller)

### Decisão: Python + PyQt6

**Justificativa:**

1.  **Performance e Controle:** Para um media player que exige manipulação de janelas em múltiplas telas e renderização de vídeo, a performance nativa do backend Qt do PyQt6 é superior a abordagens baseadas em webviews. Benchmarks internos na fase de POC validarão o consumo de CPU/GPU em tarefas de renderização 4K, comparando com um protótipo simples em Electron para quantificar esta vantagem.
2.  **Ecossistema de Mídia:** Python oferece as bibliotecas mais poderosas e maduras para processamento de mídia (PyAV, OpenCV, Pillow), simplificando a implementação do motor de playback.
3.  **Sinergia Ideal:** Combina a agilidade do Python para a lógica de alto nível (playlists, configurações) com a performance do C++ (via Qt) para as tarefas intensivas de UI.
4.  **Ferramenta Certa para o Trabalho:** É a solução que oferece o melhor balanço entre controle do sistema, performance de renderização e velocidade de desenvolvimento da lógica de negócio.

---

## Análise Detalhada de Requisitos

### 1. Interface do Usuário (UI/UX)

* A abordagem de controlos e gestão de playlist será inspirada nas melhores práticas de players de referência como VLC e IINA, focando na simplicidade e eficiência.
* Design responsivo e adaptável
* Temas claro/escuro (via QSS)
* Controles intuitivos e acessíveis
* Suporte a gestos e atalhos de teclado
* Layout customizável pelo usuário

### 2. Core Features

#### Playback Control

* Play/Pause/Stop
* Seek/Fast Forward/Rewind
* Volume/Equalização
* Playlists dinâmicas

#### Format Support

* Vídeo: MP4, MKV, AVI, MOV
* Imagens: PNG, JPEG, GIF
* Streaming: HLS, DASH
* Configurações por tipo de mídia

### 3. Performance & Otimização

* Buffering inteligente
* Aceleração de decodificação por hardware
* Gerenciamento de memória eficiente
* Cache de metadados e thumbnails
* Startup rápido da aplicação

#### KPIs de Sucesso e Metas de Performance

* **Tempo de Inicialização:** < 2 segundos do clique ao estado pronto.
    * **Medição:** Cronometrado programaticamente desde a inicialização do `main.py` até a emissão do sinal `ui_ready`.
* **Consumo de Memória (Idle):** < 150 MB com uma playlist de 20 itens carregada.
    * **Medição:** Aferido com a biblioteca `psutil` em snapshots periódicos após a carga inicial.
* **Uso de CPU (Playback 1080p):** < 15% numa máquina de especificações médias.
    * **Medição:** Monitoramento contínuo do uso de CPU do processo com `psutil` durante o playback de um vídeo de referência.
* **Taxa de Frames:** Manter 99% dos frames sem quedas durante o playback.
    * **Medição:** Análise interna dos timestamps de apresentação (PTS) dos frames de vídeo para detetar atrasos ou saltos.

### 4. Requisitos Específicos

1.  **Suporte Multi-tela**
    * Detectar monitores conectados (`QScreen`)
    * Configurar a tela de saída para o player
    * Layouts independentes para a janela de controle e a de exibição
2.  **Gestão de Playlist**
    * Carregar/Salvar playlists (JSON/XML)
    * Reordenação com Drag & drop (`QDrag`)
    * Tempo de exibição customizável para imagens
    * Preview de mídia na interface

---

## Arquitetura do Sistema

### 1. Camada de Apresentação

* **UI Manager**
    * Renderização de interface com Widgets PyQt6.
    * Gestão de eventos do usuário através do mecanismo de **Signals & Slots**.
    * Gerenciamento de temas e estilos com **QSS (Qt Style Sheets)**.
* **Media View**
    * Output de vídeo na tela secundária usando `QVideoWidget`.
    * Display de imagens com `QLabel` e `QPixmap`.
    * Gerenciamento de monitores via `QScreen`.
* **Control Panel**
    * Editor de Playlist com `QListView` e o padrão **Model/View Programming**.
    * Controles de mídia (botões, sliders).
    * Interface de configurações.

### 2. Camada de Lógica

* **Media Engine**
    * Decodificação de mídia e extração de frames. A sincronização de áudio e vídeo será gerenciada por um relógio mestre (geralmente o áudio), comparando os timestamps de apresentação (PTS) de cada frame de vídeo contra o relógio para decidir se um frame deve ser exibido, atrasado ou descartado.
    * Para streams HLS/DASH, o PyAV abrirá o URL do manifesto. Uma lógica de buffering dedicada em uma thread separada gerenciará o download dos segmentos de mídia para garantir um playback contínuo.
    * Gerenciamento de buffering para playback suave.
    * Controle de tempo de exibição e sincronização.
* **Playlist Manager**
    * Gerenciamento da fila de execução e estado da playlist.
    * Validação de arquivos (formato, existência).
    * Manipulação de metadados (duração, resolução).
* **Settings Manager**
    * Gerenciamento das preferências do usuário.
    * Configurações de tela e áudio.
    * Ajustes de performance (ex: uso de aceleração por hardware).

### 3. Camada de Dados

* **File System**
    * Armazenamento local de playlists e configurações em formato JSON.
    * Gerenciamento de cache para thumbnails e metadados.
    * Persistência de estado da aplicação entre sessões.
* **State Manager**
    * Modelo de dados centralizado para o estado da aplicação.
    * Comunicação entre a camada de lógica e a UI.
    * Tratamento de erros e logging.

---

## Stack Tecnológica

### 1. Framework Base

* **Python 3.11+**
* **PyQt6:** Para toda a interface gráfica, gerenciamento de janelas e eventos.

### 2. Frontend (UI)

* **Qt Widgets:** Para componentes de UI reutilizáveis.
* **Model/View/Controller (Qt):** Para separação de dados e apresentação.
* **Signals & Slots:** Para gerenciamento de estado e comunicação entre componentes.
* **QSS:** Para estilização avançada da UI.

### 3. Bibliotecas Core

* **tinydb / sqlite3:** Para persistência de dados, configurações e cache.
* **PyAV:** Wrapper FFmpeg para processamento de vídeo e extração de metadados.
* **Pillow:** Para processamento e otimização de imagens.

### 4. Developer Tools

* **Poetry:** Para gerenciamento de dependências, ambientes e build.
* **MyPy:** Para checagem estática de tipos, garantindo type safety.
* **Ruff:** Para linting e formatação de código de alta performance.
* **Black:** Para formatação de código opinativa.
* **PyTest:** Para testes unitários, de integração e de UI (com `pytest-qt`).

---

## Estrutura do Projeto

```
mediaplayer/
├── src/
│   ├── main.py           # Ponto de entrada da aplicação
│   ├── core/             # Lógica de negócio agnóstica de UI
│   │   ├── media/        # Controle de mídia, playback engine
│   │   ├── playlist/     # Gerenciamento de playlists
│   │   └── settings/     # Configurações do usuário
│   ├── ui/               # Componentes da interface gráfica (PyQt)
│   │   ├── widgets/      # Widgets customizados reutilizáveis (ex: TimelineSlider)
│   │   ├── views/        # Views principais (MainWindow, PlayerWindow)
│   │   └── models/       # Modelos de dados para as views (ex: PlaylistModel)
│   ├── services/         # Lógica de acesso a dados e sistema
│   └── common/           # Tipos, constantes e utilitários compartilhados
├── tests/                # Suíte de testes
│   ├── unit/             # Testes unitários para core e services
│   └── integration/      # Testes de integração e de UI
├── resources/            # Recursos estáticos (ícones, arquivos .ui, QSS)
└── docs/                 # Documentação do projeto
```

---

## Plano de Implementação

### Fase 1: Fundação (2-3 semanas)

*Prioridade: Estabelecer a base técnica e a arquitetura.*
1.  **Setup Inicial**
    * Ambiente de desenvolvimento com Poetry.
    * Estrutura do projeto e boilerplate.
    * Pipeline de CI/CD com GitHub Actions (lint, types, tests).
2.  **Core Features**
    * Media engine básico (carregar e obter metadados).
    * UI framework com janela principal e secundária.
    * Lógica de seleção e carregamento de arquivos.

### Fase 2: Features Core (3-4 semanas)

*Prioridade: Implementar a funcionalidade principal de playback.*
*Dependência Crítica: Conclusão da Fase 1.*
1.  **Media Playback**
    * Decodificação e renderização de vídeo/imagem.
    * Controles de playback básicos.
    * Gerenciamento de display entre monitores.
2.  **Playlist System**
    * Lógica de fila de execução.
    * Validação de arquivos.
    * Controle de tempo para imagens.

### Fase 3: Polish (2-3 semanas)

*Prioridade: Refinar a experiência do usuário e garantir a estabilidade.*
*Dependência Crítica: Conclusão da Fase 2.*
1.  **UI/UX**
    * Refinamento visual com QSS.
    * Responsividade e layout.
    * Atalhos de teclado.
2.  **Performance**
    * Otimizações de memória e CPU.
    * Tratamento de erros robusto.
    * Cobertura de testes.

---

## Recursos e Esforço Estimado

* **Equipa:** 1 Engenheiro de Software Pleno (foco principal), 1 Designer UX/UI (part-time nas fases 1 e 3).
* **Esforço Total Estimado:** Aproximadamente 8-10 semanas-pessoa para a Versão Completa.
* **Timeline Total:** Cerca de 2 a 3 meses.

---

## Considerações Técnicas

### 1. Performance

* **Memory Management:** Buffering inteligente e descarregamento de recursos da memória.
* **Threading:** Uso de `QThread` para tarefas pesadas (decodificação de vídeo, I/O) para manter a UI 100% responsiva.
* **Processamento:** Delegação de tarefas de processamento de mídia para o backend FFmpeg via PyAV para máxima eficiência.

### 2. Qualidade

* **Testing:**
    * Testes unitários (`PyTest`) para a lógica de negócio.
    * Testes de integração (`PyTest`) para as interações entre serviços.
    * Testes de UI (`pytest-qt`) para simular interações do usuário.
    * Testes de componentes visuais isolados.
* **Code Quality:**
    * `Ruff` e `Black` para linting e formatação.
    * `MyPy` em modo estrito para garantir type safety.
    * `pre-commit hooks` para automação de checagens de qualidade.
    * Análise de código estática com SonarQube/CodeClimate no CI.

### 3. Segurança

* **Input Validation:** Verificação de arquivos e limites de tamanho.
* **Resource Control:** Limites de memória e CPU para evitar sobrecarga do sistema.
* **Error Recovery:** Mecanismos para recuperação de falhas durante o playback.

### 4. Estratégia de Distribuição e Testes Multiplataforma
O empacotamento será um ponto de foco, com testes automatizados para garantir a estabilidade:
* **CI/CD:** O pipeline no GitHub Actions incluirá jobs para Windows, macOS e Ubuntu LTS.
* **Testes de Empacotamento:** Cada job irá gerar um instalador (usando PyInstaller) e executará um teste de fumo (smoke test) para garantir que a aplicação inicia corretamente.
* **Desafios do Linux:** Para Linux, o pipeline irá testar contra diferentes ambientes gráficos (X11 e Wayland) e verificará a presença de dependências críticas (`libxkbcommon`, etc.) para mitigar problemas comuns de compatibilidade do PyQt6.

---

## Análise de Riscos e Mitigação

| Risco Potencial | Impacto | Estratégia de Mitigação |
| :--- | :--- | :--- |
| **Complexidade do Empacotamento Multiplataforma** | Médio | Dificuldade em gerar instaladores estáveis para Windows, macOS e Linux. | Utilizar GitHub Actions para criar pipelines de build e teste automatizados para cada SO, conforme detalhado na Estratégia de Distribuição. Focar inicialmente nas plataformas prioritárias e documentar o processo de build de forma rigorosa. |
| **Gargalos de Performance em Hardware Antigo** | Alto | Experiência do usuário degradada (vídeo travando, UI lenta) em máquinas com menos recursos. | Definir requisitos mínimos de sistema. Focar em otimizações críticas, como o uso de aceleração de decodificação por hardware via FFmpeg. Realizar testes em máquinas virtuais de baixa especificação. |
| **Dependência de Bibliotecas Externas (ex: PyAV)** | Baixo | O projeto PyAV pode ser descontinuado ou apresentar bugs críticos sem correção rápida. | Monitorar ativamente o repositório do projeto. Manter uma versão estável e testada, atualizando com cautela. Em caso de problemas graves, explorar alternativas como wrappers diretos para a `libmpv`. |
| **Manutenção da UI com QSS/Widgets** | Baixo | A estilização com QSS e a criação de widgets complexos podem se tornar difíceis de manter em comparação com frameworks web modernos. | Adotar uma arquitetura de componentes de UI bem definida, com widgets reutilizáveis e com escopo claro. Manter uma biblioteca de estilos (QSS) organizada e documentada. |

---

## Entregáveis

### 1. MVP Core

* Gerenciamento de display.
* Playback básico.
* Suporte a arquivos.
* Playlist simples.

### 2. Feature Complete

* UI/UX completa.
* Playback avançado.
* Sistema de configurações.
* Tratamento de erros.

### 3. Release

* Otimização de performance.
* Documentação do usuário.
* Instalador para Windows/macOS/Linux (com `PyInstaller` ou `cx_Freeze`).
* Guia do usuário.

---

## Próximos Passos

1.  Criar protótipo de interface no Qt Designer.
2.  Desenvolver POC de múltiplas telas.
3.  Testar bibliotecas de mídia.
4.  Implementar MVP.
5.  Coletar feedback e iterar.
