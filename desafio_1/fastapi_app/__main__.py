from fastapi import FastAPI
import uvicorn

app = FastAPI(title="Hello World - FastAPI")

@app.get("/")
def hello_world():
    return {"message": "Hello, World"}

def main():
    uvicorn.run("fastapi_app.__main__:app", host="0.0.0.0", port=8000, reload=True)

if __name__ == "__main__":
    main()
