# app/utils/i18n.py
import json
import os
from fastapi import Request

LOCALES_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "locales")

def get_translation(lang: str, key: str) -> str:
    # Agar til qo'llab-quvvatlanmasa, standart o'zbek tili olinadi
    if lang not in ["uz", "en", "ru"]:
        lang = "uz"
    
    file_path = os.path.join(LOCALES_DIR, f"{lang}.json")
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            translations = json.load(f)
            return translations.get(key, key)
    except FileNotFoundError:
        return key
