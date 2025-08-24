# Desafio 1 - Flask e FastHTTP

Este diretório contém dois projetos web simples que retornam "Hello, World" através de uma rota GET.

## Estrutura dos Projetos

```
desafio_1/
├── flask_project/
│   ├── app.py
│   └── requirements.txt
├── fasthttp_project/
│   ├── main.go
│   └── go.mod
└── README.md
```

## Pré-requisitos

### Para o projeto Flask (Python)
- Python 3.7 ou superior instalado no sistema
- pip (gerenciador de pacotes do Python)

### Para o projeto FastHTTP (Go)
- Go 1.19 ou superior instalado no sistema

### Verificando as instalações

**Python:**
```bash
python --version
# ou
python3 --version
```

**Go:**
```bash
go version
```

## Instalação e Execução

### Projeto Flask (Python)

1. **Navegue até o diretório do projeto Flask:**
   ```bash
   cd flask_project
   ```

2. **Crie um ambiente virtual (recomendado):**
   ```bash
   # Windows
   python -m venv venv
   venv\Scripts\activate
   
   # Linux/MacOS/Raspberry Pi
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Instale as dependências:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Execute o servidor:**
   ```bash
   python app.py
   ```

O servidor Flask estará disponível em: `http://localhost:5000`

### Projeto FastHTTP (Go)

1. **Navegue até o diretório do projeto FastHTTP:**
   ```bash
   cd fasthttp_project
   ```

2. **Inicialize o módulo Go e instale as dependências:**
   ```bash
   # Inicializar o módulo (obrigatório)
   go mod init fasthttp-hello
   
   # Baixar a dependência específica
   go mod download github.com/valyala/fasthttp
   
   # Organizar todas as dependências
   go mod tidy
   ```

4. **Execute o servidor:**
   ```bash
   # Opção 1: Executar diretamente
   go run main.go
   
   # Opção 2: Compilar e executar
   go build -o server main.go
   ./server  # Linux/MacOS
   server.exe  # Windows
   ```

O servidor FastHTTP estará disponível em: `http://localhost:8080`

## Compatibilidade entre Sistemas Operacionais

### Python (Flask)
| Sistema | Python Command | Ativação do Venv | Pip Command |
|---------|---------------|------------------|-------------|
| Windows | `python` | `venv\Scripts\activate` | `pip` |
| Linux | `python3` | `source venv/bin/activate` | `pip` ou `pip3` |
| MacOS | `python3` | `source venv/bin/activate` | `pip` ou `pip3` |
| Raspberry Pi | `python3` | `source venv/bin/activate` | `pip` ou `pip3` |

### Go (FastHTTP)
| Sistema | Go Command | Executável Compilado |
|---------|------------|---------------------|
| Windows | `go run main.go` | `server.exe` |
| Linux | `go run main.go` | `./server` |
| MacOS | `go run main.go` | `./server` |
| Raspberry Pi | `go run main.go` | `./server` |

**Nota:** Os comandos Go são idênticos em todos os sistemas, apenas o executável final varia.

## Verificação dos Servidores

### Testando via Navegador
- **Flask:** Acesse `http://localhost:5000` no seu navegador
- **FastHTTP:** Acesse `http://localhost:8080` no seu navegador

### Testando via Terminal (curl)
```bash
# Flask
curl http://localhost:5000

# FastHTTP
curl http://localhost:8080
```

### Testando com outros métodos HTTP
```bash
# Testando POST (deve retornar erro)
curl -X POST http://localhost:5000  # Flask
curl -X POST http://localhost:8080  # FastHTTP
```

## Troubleshooting

### Erro: "missing go.sum entry for module"

Se você receber o erro:
```
main.go:6:2: missing go.sum entry for module providing package github.com/valyala/fasthttp
```

**Solução:**
```bash
cd fasthttp_project
go mod init fasthttp-hello
go mod download github.com/valyala/fasthttp
go mod tidy
go run main.go
```

### Erro: "go: cannot find main module"

Se você receber este erro, significa que você não está na pasta correta ou não inicializou o módulo Go:

**Solução:**
```bash
# Certifique-se de estar na pasta correta
cd fasthttp_project

# Inicialize o módulo
go mod init fasthttp-hello
```

### Problemas com Proxy do Go

Se você estiver em uma rede corporativa e tiver problemas para baixar dependências:

```bash
# Desabilitar o proxy temporariamente
go env -w GOPROXY=direct
go env -w GOSUMDB=off

# Depois executar
go mod download github.com/valyala/fasthttp
go mod tidy
```

## Executando os Dois Projetos Simultaneamente

**Sim, é possível rodar os dois projetos ao mesmo tempo!**

Eles usam portas diferentes:
- Flask (Python): porta 5000
- FastHTTP (Go): porta 8080

Para executar ambos:

1. **Terminal 1 - Flask:**
   ```bash
   cd flask_project
   source venv/bin/activate  # ou venv\Scripts\activate no Windows
   python app.py
   ```

2. **Terminal 2 - FastHTTP:**
   ```bash
   cd fasthttp_project
   go run main.go
   ```

## Parando os Servidores

Para parar qualquer servidor, use `Ctrl + C` no terminal onde ele está executando.

## Performance e Recursos

### Flask (Python)
- Processo single-threaded por padrão
- Uso de memória: ~15-30MB
- Tempo de startup: ~1-2 segundos

### FastHTTP (Go)
- Multi-threaded/goroutines nativo
- Uso de memória: ~5-15MB
- Tempo de startup: ~100-500ms
- Performance superior em requisições concorrentes

## Diferenças entre os Projetos

| Aspecto | Flask (Python) | FastHTTP (Go) |
|---------|---------------|---------------|
| **Linguagem** | Python | Go |
| **Arquivo principal** | `app.py` | `main.go` |
| **Gerenciamento de dependências** | `requirements.txt` + pip | `go.mod` + go modules |
| **Importações** | `from flask import Flask` | `import "github.com/valyala/fasthttp"` |
| **Criação da aplicação** | `app = Flask(__name__)` | `server := &fasthttp.Server{}` |
| **Definição de rota** | `@app.route('/', methods=['GET'])` | `func helloWorldHandler(ctx *fasthttp.RequestCtx)` |
| **Verificação de método** | Automática via decorator | Manual: `ctx.IsGet()` |
| **Verificação de path** | Automática via decorator | Manual: `string(ctx.Path()) != "/"` |
| **Resposta** | `return "Hello, World"` | `ctx.WriteString("Hello, World")` |
| **Content-Type** | Automático | Manual: `ctx.SetContentType("text/plain")` |
| **Servidor** | Built-in (`app.run()`) | `server.ListenAndServe(":8080")` |
| **Porta padrão** | 5000 | 8080 |
| **Host binding** | `app.run(host='0.0.0.0', port=5000)` | `server.ListenAndServe(":8080")` |
| **Logging** | Built-in | Manual: `log.Println()` |
| **Tratamento de erros** | Automático | Manual: `ctx.Error()` |
| **Performance** | Moderada | Muito alta |
| **Uso de memória** | Maior (~20-30MB) | Menor (~5-15MB) |
| **Tempo de startup** | ~1-2s | ~100-500ms |
| **Concorrência** | Limitada (GIL) | Nativa (goroutines) |
| **Compilação** | Interpretado | Compilado |
| **Deploy** | Requer Python runtime | Binário standalone |
| **Tipagem** | Dinâmica | Estática |
| **Curva de aprendizado** | Mais simples | Intermediária |

### Principais Diferenças no Código:

1. **Estrutura:** Flask usa decorators, FastHTTP usa handlers com verificações manuais
2. **Roteamento:** Flask automático vs FastHTTP manual 
3. **Resposta:** Flask com `return`, FastHTTP com `ctx.WriteString()`
4. **Configuração:** Flask com métodos da instância, FastHTTP com struct Server
5. **Dependências:** Python usa pip/virtualenv, Go usa módulos nativos
6. **Execução:** Python interpretado vs Go compilado
7. **Performance:** Go significativamente mais rápido e eficiente em recursos