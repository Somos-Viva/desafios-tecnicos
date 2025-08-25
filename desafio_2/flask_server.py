from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello, World"

if __name__ == "__main__":
    print("Iniciando servidor Flask na porta 5000...")
    try:
        app.run(host="localhost", port=5000, debug=True)
    except Exception as e:
        print(f"Erro ao iniciar o servidor: {e}")
