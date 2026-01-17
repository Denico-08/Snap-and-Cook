import requests
from dotenv import load_dotenv
import os

load_dotenv()

# ⚠️ GANTI INI DENGAN API KEY ANDA DARI WEBSITE SPOONACULAR
API_KEY = os.getenv("SPOONACULAR_API_KEY")

if not API_KEY:
    raise ValueError("Gawat! API Key tidak ditemukan di file .env")

def get_recipes_from_ingredients(ingredients_list):
    """
    Mencari resep berdasarkan list bahan makanan.
    Contoh Input: ['tomato', 'egg']
    """
    if not ingredients_list:
        return []

    # Spoonacular butuh format: "tomato,egg" (koma tanpa spasi)
    ingredients_str = ",".join(ingredients_list)
    
    url = "https://api.spoonacular.com/recipes/findByIngredients"
    
    params = {
        "apiKey": API_KEY,
        "ingredients": ingredients_str,
        "number": 5,          # Kita minta 5 resep saja
        "ranking": 1,         # 1 = Prioritaskan bahan yang kita punya
        "ignorePantry": True  # Abaikan bahan umum (garam, gula, air)
    }

    try:
        print(f"🌍 Sedang mencari resep untuk: {ingredients_str}...")
        response = requests.get(url, params=params)
        
        # Cek apakah request sukses (Kode 200)
        if response.status_code == 200:
            data = response.json()
            
            # Kita rapikan datanya supaya enak dibaca Frontend nanti
            clean_recipes = []
            for item in data:
                clean_recipes.append({
                    "id": item['id'],
                    "title": item['title'],
                    "image": item['image'],
                    "usedIngredientCount": item['usedIngredientCount'],
                    "missedIngredientCount": item['missedIngredientCount']
                })
            return clean_recipes
        else:
            print(f"❌ Error API: {response.status_code} - {response.text}")
            return []

    except Exception as e:
        print(f"❌ Error Koneksi: {e}")
        return []
