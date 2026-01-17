from transformers import pipeline
from PIL import Image
import io

print("⏳ Sedang memuat model AI... (Hanya lama di awal)")
detector = pipeline("object-detection", model="hustvl/yolos-tiny")
print("✅ Model siap digunakan!")

def get_ingredients(image_bytes):
    """
    Fungsi ini menerima raw bytes dari gambar, 
    dan mengembalikan list nama bahan makanan yang terdeteksi.
    """
    try:
        # Ubah bytes menjadi Gambar yang bisa dibaca Python (PIL Image)
        image = Image.open(io.BytesIO(image_bytes))
        
        # Lakukan deteksi
        results = detector(image)
        
        # Filter hasil:
        # 1. Ambil labelnya saja (misal: 'banana')
        # 2. Buang duplikat (pakai set)
        # 3. Opsional: Anda bisa memfilter objek non-makanan di sini nanti
        detected_objects = set()
        
        print("\n🔍 Hasil Deteksi Mentah:")
        for r in results:
            label = r['label']
            score = r['score']
            print(f"- {label} (Yakin: {score:.2f})")
            
            # Kita anggap valid jika keyakinan AI > 50%
            if score > 0.5:
                detected_objects.add(label)
                
        return list(detected_objects)

    except Exception as e:
        print(f"Error: {e}")
        return []
