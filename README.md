# 📸 Snap & Cook AI

**Snap your ingredients. Cook delicious meals.**

Snap & Cook is a mobile application that solves the "what should I cook?" dilemma. By leveraging Computer Vision, users can simply take a photo of ingredients on their table, and the app will instantly suggest relevant recipes.

![Project Demo](path/to/your/demo.gif) 
*(Note: Upload GIF/Screenshot here later)*

## 🚀 Key Features

* **AI Ingredient Detection:** Detects fruits, vegetables, and common food items from camera input using pre-trained Object Detection models.
* **Smart Recipe Search:** Suggests recipes based strictly on the detected ingredients.
* **Seamless Mobile Experience:** Native performance on Android/iOS built with Flutter.
* **Real-time Processing:** Fast inference using Python FastAPI backend.

## 🛠️ Tech Stack

This project demonstrates a full-stack implementation of AI integration:

**Mobile App (Frontend):**
* **Framework:** Flutter (Dart)
* **Packages:** `image_picker` (Camera), `dio` (API Networking)

**Backend & AI:**
* **Framework:** FastAPI (Python)
* **Computer Vision:** Hugging Face Transformers (`hustvl/yolos-tiny`)
* **External API:** Spoonacular API (Recipe Database)
* **Deployment:** Uvicorn / Ngrok (for local tunneling)

## 🏗️ System Architecture

1.  **Input:** User captures an image via Flutter App.
2.  **Process:** Image is sent to FastAPI Server.
3.  **Analysis:** Hugging Face model detects objects (e.g., `["tomato", "egg"]`).
4.  **Search:** Backend queries Spoonacular API with detected keywords.
5.  **Output:** List of recipes is returned to the app.

## 💻 How to Run Locally

### 1. Backend Setup (Python)
Navigate to the backend folder and create a virtual environment:

```bash
cd backend
python -m venv venv
# Activate venv (Windows: venv\Scripts\activate | Mac/Linux: source venv/bin/activate)
pip install -r requirements.txt
uvicorn main:app --reload
