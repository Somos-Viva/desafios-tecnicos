from flask import Flask, render_template
import pandas as pd
import requests

app = Flask(__name__)

# Página inicial
@app.route("/")
def home():
    return """
    <h1>Desafio 2</h1>
    <ul>
        <li><a href='/editorias'>Ver Editorias (CSV)</a></li>
        <li><a href='/catfact'>Fato aleatório de gato</a></li>
        <li><a href='/hora'>Hora Local</a></li>
        <li><a href='/camera'>Câmera</a></li>
    </ul>
    """

# Página Editorias (CSV)
@app.route("/editorias")
def editorias():
    df = pd.read_csv("editorias.csv")
    tabela_html = df.to_html(classes="table table-striped", index=False)
    return render_template("editorias.html", tabela=tabela_html)

# Página com API catfact.ninja
@app.route("/catfact")
def catfact():
    response = requests.get("https://catfact.ninja/fact")
    fact = response.json().get("fact", "Não foi possível obter um fato de gato.")
    return render_template("catfact.html", fact=fact)

# Página da hora local
@app.route("/hora")
def hora():
    return render_template("hora.html")

# Página da câmera
@app.route("/camera")
def camera():
    return render_template("camera.html")


if __name__ == "__main__":
    app.run(debug=True)
