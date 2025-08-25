from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    """Esta função retorna um JSON com a mensagem 'Hello, World'."""
    return {"message": "Hello, World"}
