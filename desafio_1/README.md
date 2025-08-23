# Desafio 1 - Flask e FastAPI

Este projeto contém duas aplicações de servidor web, cada uma expondo um endpoint (`GET`) que retorna "Hello, World":

- `flask_app` → servidor Flask
- `fastapi_app` → servidor FastAPI

## Requisitos

- Python 3.12 ou superior (https://www.python.org/downloads/)
- Poetry para gerenciamento de dependências do projeto (https://python-poetry.org/docs/#installation)

## Configuração do Ambiente

- Instale as dependências utilizando Poetry
    ```bash
    poetry install
## Rodando o Projeto Flask
- Acesse a pasta 'desafio_1'
    ```bash
    cd desafio_1
- No terminal, insira:
    ```bash
    poetry run python -m flask_app.app
    ```
 - O servidor irá rodar em http://localhost:5000/ (ou http://127.0.0.1:5000/)  
   Acesse o *localhost* pelo navegador ou digite no terminal para validar:
   ```bash
   curl http://localhost:5000/
   # Saída esperada: Hello, World
## Rodando o Projeto FastAPI
- Acesse a pasta 'desafio_1'
    ```bash
    cd desafio_1
- No terminal, insira:
    ```bash
    poetry run python -m fastapi_app
    ```
- O servidor irá rodar em http://localhost:8000/ (ou http://127.0.0.1:8000/)  
   Acesse o *localhost* pelo navegador ou digite no terminal para validar:
   ```bash
   curl http://localhost:8000/
   # Saída esperada: {"message":"Hello, World"}
- A documentação da API pode ser acessada em http://localhost:8000/docs (ou http://127.0.0.1:8000/docs).

## Rodando ambos projetos simultaneamente

Sim, é possível rodar os dois ao mesmo tempo visto que atuam em portas diferentes:

Flask → porta 5000   
FastAPI → porta 8000  

Abra dois terminais diferentes e execute os comandos de cada projeto.

## Diferença entre os projetos
Conceito                     | Flask (`flask_app/app.py`)                     | FastAPI (`fastapi_app/__main__.py`)                     | Observações / Diferenças
------------------------------|-----------------------------------------------|--------------------------------------------------------|---------------------------------------------
Import                        | from flask import Flask                        | from fastapi import FastAPI<br>import uvicorn          | FastAPI precisa de Uvicorn para rodar servidor ASGI
Inicialização da aplicação          | app = Flask(\_\_name\_\_)                          | app = FastAPI(title="Hello World - FastAPI")           | Semelhantes, em Fast defini o título, mas também funciona sem o argumento enquanto o Flask não.
Definição de rota             | @app.get("/")                                  | @app.get("/")                                         | Mesma forma de criar rota GET
Função de handler             | def hello_world():                             | def hello_world():                                    | Mesma lógica, apenas sintaxe do retorno muda
Retorno                       | "Hello, World"                                 | {"message": "Hello, World"}                            | Flask retorna texto puro, FastAPI retorna JSON
Função main / execução         | def main(): app.run(host="0.0.0.0", port=5000)<br>if __name__ == "__main__": main() | def main(): uvicorn.run("fastapi_app.__main__:app", host="0.0.0.0", port=8000, reload=True)<br>if __name__ == "__main__": main() | Flask usa WSGI, FastAPI usa ASGI (uvicorn).
Hot reload / dev mode          | debug=True                                     | reload=True                                           | Ambos permitem recarregamento automático em modo desenvolvimento; Flask via debug, FastAPI via reload do Uvicorn.
Documentação automática        | Não possui                                    | Automática via Swagger UI e Redoc                      | FastAPI gera documentação interativa
Escalabilidade assíncrona      | Limitada                                      | Nativa (async)                                        | FastAPI é melhor para APIs modernas e escaláveis

