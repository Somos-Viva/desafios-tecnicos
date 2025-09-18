# Desafio 1 - Projetos Flask e FastAPI

Este diretório contém dois projetos web em Python: um usando **Flask** e outro usando **FastAPI**.

---

## Pré-requisitos

Antes de rodar os projetos, você precisa ter instalado:

- **Python 3.8+**: [https://www.python.org/downloads/](https://www.python.org/downloads/)
- **pip** (gerenciador de pacotes do Python)
- **Git** (opcional, para clonar o repositório)

> Para todos os sistemas operacionais (Windows, Linux, MacOS e Raspberry Pi), os comandos abaixo são praticamente os mesmos.

---

## Configuração do ambiente

Para cada projeto, é recomendado criar um **ambiente virtual** Python:

```bash
# Linux / MacOS / Raspberry Pi
python3 -m venv .venv
source .venv/bin/activate

# Windows PowerShell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

---

## 1. Projeto Flask

### Instalação das dependências

Dentro da pasta `flask_app`:

```bash
pip install -r requirements.txt
```

### Executando o servidor

```bash
# Linux / MacOS / Raspberry Pi
python3 app.py

# Windows
python app.py
```

O servidor Flask rodará em:

```
http://127.0.0.1:5000/
```

### Verificando se está funcionando

- Abra o navegador e acesse: `http://127.0.0.1:5000/`
- Você deverá ver a mensagem JSON: `{"message": "Hello from Flask!"}`

---

## 2. Projeto FastAPI

### Instalação das dependências

Dentro da pasta `fastapi_app`:

```bash
pip install -r requirements.txt
```

### Executando o servidor

```bash
# Linux / MacOS / Raspberry Pi
uvicorn main:app --reload

# Windows
uvicorn main:app --reload
```

O servidor FastAPI rodará em:

```
http://127.0.0.1:8000/
```

### Verificando se está funcionando

- Abra o navegador e acesse: `http://127.0.0.1:8000/`
- Você deverá ver a mensagem JSON: `{"message": "Hello from FastAPI!"}`
- Para documentação interativa: acesse `http://127.0.0.1:8000/docs`

---

## Rodando os dois projetos ao mesmo tempo

Sim, é possível rodar **Flask e FastAPI simultaneamente**, pois cada um usa **uma porta diferente** (5000 para Flask e 8000 para FastAPI).

- Abra dois terminais, um em cada pasta, e execute cada servidor separadamente.

---

## Diferenças entre Flask e FastAPI

| Funcionalidade / Linha | Flask | FastAPI |
|------------------------|-------|---------|
| Estrutura | Minimalista, fácil de começar | Mais completa, inclui validação de dados automática |
| Definição do servidor | `app = Flask(__name__)` | `app = FastAPI()` |
| Rota simples | `@app.route("/")` | `@app.get("/")` |
| Função da rota | Retorna `dict` ou `string` | Retorna `dict`, com validação e tipagem |
| Porta padrão | 5000 | 8000 |
| Execução | `python app.py` | `uvicorn main:app --reload` |
| Documentação automática | Não possui nativa | Gerada automaticamente em `/docs` |
| Tipagem | Opcional | Recomendada, suporta Pydantic |
| Suporte a async | Limitado, precisa de extensões | Nativo, suporta `async def` |
| Velocidade | Boa para aplicações pequenas | Geralmente mais rápida, suporta async nativo |

---

> Este README serve como guia completo para rodar ambos os projetos e entender suas diferenças principais.
