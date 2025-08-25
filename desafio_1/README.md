# Desafio 1 - Servidores Web

Este projeto contém três servidores web simples:

  - Um servidor Flask (Python)
  - Um servidor FastHTTP (Go)
  - Um servidor FastAPI (Python)

> **Nota sobre o FastAPI**: O FastAPI foi incluído nesta comparação por ter um nome similar ao FastHTTP. Considerando que o FastHTTP é uma biblioteca de alta performance em Go, foi levantada a hipótese de que poderia haver uma confusão de nomenclatura, sendo o FastAPI o equivalente de alta performance no ecossistema Python.

> **Nota sobre Linguagens**: Embora os projetos Flask e FastAPI usem Python, o FastHTTP é implementado em Go por ser a implementação oficial e mais eficiente dessa biblioteca.

## Requisitos

Para rodar os projetos, você precisará:

### Para o servidor Flask (Python)

1.  Python 3.7 ou superior instalado
2.  Instalar Flask:
    ```bash
    pip install flask
    ```

### Para o servidor FastAPI (Python)

1.  Python 3.7 ou superior instalado
2.  Instalar FastAPI e o servidor Uvicorn:
    ```bash
    pip install "fastapi[all]"
    ```

### Para o servidor FastHTTP (Go)

1.  Go 1.16 ou superior instalado
      - Windows: Baixe do [site oficial Go](https://golang.org/dl/)
      - Linux: `sudo apt-get install golang-go`
      - MacOS: `brew install go`
2.  Instalar FastHTTP:
    ```bash
    go mod init fasthttp-server
    go get github.com/valyala/fasthttp
    ```

## Como executar

### Servidor Flask

```bash
# Windows
python flask_server.py

# Linux/MacOS/Raspberry Pi
python3 flask_server.py
```

O servidor Flask estará disponível em: http://localhost:5000

### Servidor FastAPI

```bash
# Em todos os sistemas operacionais
uvicorn fastapi_server:app --reload
```

O servidor FastAPI estará disponível em: http://localhost:8000

### Servidor FastHTTP

```bash
# Em todos os sistemas operacionais
go run fasthttp_server.go
```

O servidor FastHTTP estará disponível em: http://localhost:5002

> **Nota**: O Go e os servidores Python modernos são multiplataforma, então os comandos funcionam de forma consistente em Windows, Linux, MacOS e Raspberry Pi.

## Verificando o funcionamento

Para verificar se os servidores estão funcionando:

1.  Abra seu navegador e acesse:

      - Flask: http://localhost:5000
      - FastAPI: http://localhost:8000
      - FastHTTP: http://localhost:5002

2.  Você também pode usar o curl no terminal:

    ```bash
    curl http://localhost:5000
    curl http://localhost:8000
    curl http://localhost:5002
    ```

## Executando simultaneamente

Sim, é possível rodar os três servidores ao mesmo tempo pois eles estão configurados para usar portas diferentes:

  - Flask usa a porta **5000**
  - FastAPI usa a porta **8000**
  - FastHTTP usa a porta **5002**

## Comparação entre os projetos

| Aspecto | Flask (Python) | FastAPI (Python) | FastHTTP (Go) |
|---|---|---|---|
| **Linguagem** | Python | Python | Go |
| **Importações** | `from flask import Flask` | `from fastapi import FastAPI` | `github.com/valyala/fasthttp` |
| **Criação da aplicação** | `app = Flask(__name__)` | `app = FastAPI()` | Define uma função `handler` |
| **Definição da rota**| Decoradores (`@app.route("/")`)| Decoradores (`@app.get("/")`)| Handler verifica `ctx.Path()` |
| **Função da rota** | Retorna string/response | Retorna JSON/response | Manipula o `RequestCtx` diretamente |
| **Execução** | Servidor WSGI integrado | Servidor ASGI (Uvicorn) | Servidor HTTP otimizado |
| **Performance** | Framework Python, mais overhead | Alta performance (assíncrono) | Performance extrema em Go (compilado)|
| **Uso de memória** | \~20MB | \~25MB | \~5MB |
| **Concorrência** | Thread por request | Event loop (Asyncio) | Goroutines eficientes |