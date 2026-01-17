from fastapi import FastAPI, UploadFile, File, HTTPException
from ai_service import get_ingredients
from recipe_service import get_recipes_from_ingredients
import shutil

app = FastAPI(
    title="Snap & Cook API",
    description="API untuk mendeteksi bahan makanan dari gambar dan mencari resepnya.",
    version="1.0.0"
)

@app.get("/")
def home():
    return {"message": "Server Snap & Cook aktif! 🚀"}

@app.post("/predict")
async def predict_and_cook(file: UploadFile = File(...)):
    """
    Endpoint utama:
    1. Terima upload file gambar.
    2. Deteksi bahan pakai AI.
    3. Cari resep berdasarkan bahan tersebut.
    """
    # 1. Validasi file (harus gambar)
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File harus berupa gambar!")

    try:
        # 2. Baca file gambar
        contents = await file.read()
        
        # 3. Panggil AI Service
        print("📸 Menerima gambar, memulai deteksi...")
        detected_ingredients = get_ingredients(contents)
        
        # Jika AI tidak menemukan apa-apa (atau cuma nemu 'dining table')
        if not detected_ingredients:
            return {
                "status": "success",
                "message": "Tidak ada bahan makanan yang terdeteksi.",
                "detected": [],
                "recipes": []
            }

        # 4. Panggil Recipe Service
        print(f"🥦 Bahan ditemukan: {detected_ingredients}. Mencari resep...")
        recipes = get_recipes_from_ingredients(detected_ingredients)
        
        # 5. Kirim balasan JSON
        return {
            "status": "success",
            "detected_ingredients": detected_ingredients,
            "recipes": recipes
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))