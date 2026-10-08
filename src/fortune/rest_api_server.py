from fastapi import FastAPI
from fastapi.responses import PlainTextResponse
from .fortune import Fortune

app = FastAPI(title="Fortune RestApi Service")
#fortune_searcher = Fortune()

@app.get("/health")
def health():
    return {"status": "ok"}

#@app.get("/print")
#def print():
#    return Fortune()._print_all_fortunes()

@app.get("/fortune", response_class=PlainTextResponse)
def get_fortune():
    rand_fortune = Fortune().get_random_fortune()
    return rand_fortune.text

@app.get("/fortune/{id}", response_class=PlainTextResponse)
def get_fortune_by_id(id: int):
    fortune = Fortune().get_fortune_by_id(id)
    if fortune:
        return fortune.text
    return f"fortune with id {id} not found"
