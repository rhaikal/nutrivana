from core.core import pwd_context, SECRET_KEY, ALGORITHM
from datetime import datetime, timedelta, timezone
import jwt
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from Model import Ingredients
from core.core import db


# ======================
# Helper Functions
# ======================

def get_password_hash(password: str) -> str:
    """Hash the password using bcrypt"""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password against hashed password"""
    if plain_password == hashed_password:
        hashed_password = get_password_hash(plain_password)
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    """Create JWT token with expiration"""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

NUTRITION_RULES = {
        "severely low": {
            "prioritas": ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"],
            "faktor": {
                "Energy": 1.4,  # 40% more energy
                "Protein": 1.5,  # 50% more protein
                "Iron": 1.5,  # 50% more iron
                "default": 1.0  # No adjustment for others
            }
        },
        "low": {
            "prioritas": ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"],
            "faktor": {
                "Energy": 1.2,  # 20% more energy
                "Protein": 1.3,  # 30% more protein
                "default": 1.0  # No adjustment for others
            }
        },
        "good": {
            "prioritas": ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"],
            "faktor": {
                "Protein": 1.0,  # 10% more protein
                "Calcium": 1.0,  # 10% more calcium
                "default": 1.0  # No adjustment for others
            }
        },
        "possible risk of excessive": {
            "prioritas": ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"],
            "faktor": {
                "Total Fat": 0.85,  # 15% less fat
                "Carbohydrate": 0.9,  # 10% less carbs
                "default": 1.0  # No adjustment for others
            }
        },
        "excessive": {
            "prioritas": ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"],
            "faktor": {
                "Total Fat": 0.8,  # 20% less fat
                "Carbohydrate": 0.85,  # 15% less carbs
                "default": 1.0  # No adjustment for others
            }
        },
        "obese": {
            "prioritas": ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"],
            "faktor": {
                "Total Fat": 0.7,  # 30% less fat
                "Carbohydrate": 0.8,  # 20% less carbs
                "default": 1.0  # No adjustment for others
            }
        }
    }

def load_who_zscores(age_months: int, gender: str, height_cm: float) -> dict:
    """Load WHO z-scores based on age and gender"""
    if age_months <= 24:
        file_path = "data/wfl_boys_0-to-2-years_zscores.xlsx" if gender.lower() == 'l' else 'data/wfl_girls_0-to-2-years_zscores.xlsx'
        height_col = 'Length'
    else:
        file_path = 'data/wfh_boys_2-to-5-years_zscores.xlsx' if gender.lower() == 'l' else 'data/wfh_girls_2-to-5-years_zscores.xlsx'
        height_col = 'Height'

    try:
        df = pd.read_excel(file_path)
        df['diff'] = abs(df[height_col] - height_cm)
        closest_row = df.loc[df['diff'].idxmin()]
        
        return {
            'SD-3': closest_row['SD2neg'],
            'SD-2': closest_row['SD2neg'],
            'SD-1': closest_row['SD1neg'],
            'Median': closest_row['SD0'],
            'SD+1': closest_row['SD1'],
            'SD+2': closest_row['SD2'],
            'SD+3': closest_row['SD3']
        }
    except Exception as e:
        raise ValueError(f"Error processing WHO data: {str(e)}")

def calculate_nutrition_status(age_months: int, gender: str, height_cm: float, weight_kg: float) -> str:
    """Calculate nutrition status based on WHO standards"""
    z_scores = load_who_zscores(age_months, gender, height_cm)
    
    if weight_kg < z_scores['SD-3']:
        return "severely low"
    elif weight_kg < z_scores['SD-2']:
        return "low"
    elif weight_kg <= z_scores['SD+1']:
        return "good"
    elif weight_kg <= z_scores['SD+2']:
        return "possible risk of excessive"
    elif weight_kg <= z_scores['SD+3']:
        return "excessive"
    return "obese"

def calculate_minimum_nutrition(age_months: int, status: str) -> dict:
    """Calculate daily nutritional needs based on age and status"""
    base_needs = {
        "0-5": {
            "calcium": 200,  # mg
            "carbohydrate": 59,  # g
            "energy": 550,  # kcal
            "iron": 0.3,  # mg
            "protein": 9,  # g
            "fat": 31  # g
        },
        "6-11": {
            "calcium": 270,
            "carbohydrate": 105,
            "energy": 800,
            "iron": 11,
            "protein": 15,
            "fat": 35
        },
        "12-36": {
            "calcium": 650,
            "carbohydrate": 215,
            "energy": 1350,
            "iron": 7,
            "protein": 20,
            "fat": 45
        },
        "37-60": {
            "calcium": 1000,
            "carbohydrate": 220,
            "energy": 1400,
            "iron": 10,
            "protein": 25,
            "fat": 50
        }
    }
    
    # Select age group
    if age_months < 6:
        needs = base_needs["0-5"].copy()
    elif age_months < 12:
        needs = base_needs["6-11"].copy()
    elif age_months < 37:
        needs = base_needs["12-36"].copy()
    else:
        needs = base_needs["37-60"].copy()
    
    # Apply status adjustments
    status_rules = NUTRITION_RULES[status]
    for nutrient in needs:
        adjustment = status_rules["faktor"].get(nutrient, status_rules["faktor"]["default"])
        needs[nutrient] *= adjustment
    
    return needs

NUTRITION_FEATURES = ["calcium", "carbohydrate", "energy", "iron", "protein", "fat"]

vectorizer = TfidfVectorizer()
ingredients = db.query(Ingredients).all()
ingredients = [ingredient.name for ingredient in ingredients]

INGREDIENT_VECTORIZED = vectorizer.fit_transform(ingredients)