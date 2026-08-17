from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

MODEL_NAME = "Parth136/isl-text2gloss-mt5"
PREFIX = "translate to ISL gloss: "

model = None
tokenizer = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global model, tokenizer
    print("Loading model, this may take a minute...")
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForSeq2SeqLM.from_pretrained(
        MODEL_NAME,
        low_cpu_mem_usage=True
    )
    print("Model loaded. Ready to serve requests.")
    yield
    model = None
    tokenizer = None

app = FastAPI(
    title="ISL Gloss Server",
    description="Local FastAPI translation server for Text to Indian Sign Language (ISL) Gloss using mT5",
    lifespan=lifespan
)

class TranslationRequest(BaseModel):
    sentence: str = Field(..., description="English sentence to translate into ISL gloss")

class TranslationResponse(BaseModel):
    gloss: str = Field(..., description="Translated ISL gloss string")

@app.get("/")
def health_check():
    return {"status": "running"}

@app.post("/translate", response_model=TranslationResponse)
def translate_text(request: TranslationRequest):
    if not request.sentence or not request.sentence.strip():
        raise HTTPException(
            status_code=400,
            detail="The 'sentence' field must not be empty."
        )

    if model is None or tokenizer is None:
        raise HTTPException(
            status_code=500,
            detail="Model is not initialized or ready."
        )

    try:
        input_text = f"{PREFIX}{request.sentence.strip()}"
        inputs = tokenizer(input_text, return_tensors="pt")
        
        outputs = model.generate(
            **inputs,
            max_length=64,
            num_beams=4
        )
        
        gloss = tokenizer.decode(outputs[0], skip_special_tokens=True).strip()
        return TranslationResponse(gloss=gloss)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error during gloss translation: {str(e)}"
        )
