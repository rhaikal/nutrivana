from core.core import pwd_context, SECRET_KEY, ALGORITHM
from datetime import datetime, timedelta, timezone
import jwt
import pandas as pd

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
        "Gizi buruk (severely wasted)": {
            "prioritas": ["Calcium", "Carbohydrate", "Energy", "Iron", "Protein", "Total Fat"],
            "faktor": {
                "Energy": 1.4,  # 40% more energy
                "Protein": 1.5,  # 50% more protein
                "Iron": 1.5,  # 50% more iron
                "default": 1.0  # No adjustment for others
            }
        },
        "Gizi kurang (wasted)": {
            "prioritas": ["Calcium", "Carbohydrate", "Energy", "Iron", "Protein", "Total Fat"],
            "faktor": {
                "Energy": 1.2,  # 20% more energy
                "Protein": 1.3,  # 30% more protein
                "default": 1.0  # No adjustment for others
            }
        },
        "Gizi baik (normal)": {
            "prioritas": ["Calcium", "Carbohydrate", "Energy", "Iron", "Protein", "Total Fat"],
            "faktor": {
                "Protein": 1.0,  # 10% more protein
                "Calcium": 1.0,  # 10% more calcium
                "default": 1.0  # No adjustment for others
            }
        },
        "Berisiko gizi lebih (possible risk of overweight)": {
            "prioritas": ["Calcium", "Carbohydrate", "Energy", "Iron", "Protein", "Total Fat"],
            "faktor": {
                "Total Fat": 0.85,  # 15% less fat
                "Carbohydrate": 0.9,  # 10% less carbs
                "default": 1.0  # No adjustment for others
            }
        },
        "Gizi lebih (overweight)": {
            "prioritas": ["Calcium", "Carbohydrate", "Energy", "Iron", "Protein", "Total Fat"],
            "faktor": {
                "Total Fat": 0.8,  # 20% less fat
                "Carbohydrate": 0.85,  # 15% less carbs
                "default": 1.0  # No adjustment for others
            }
        },
        "Obesitas (obese)": {
            "prioritas": ["Calcium", "Carbohydrate", "Energy", "Iron", "Protein", "Total Fat"],
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
        return "Gizi buruk (severely wasted)"
    elif weight_kg < z_scores['SD-2']:
        return "Gizi kurang (wasted)"
    elif weight_kg <= z_scores['SD+1']:
        return "Gizi baik (normal)"
    elif weight_kg <= z_scores['SD+2']:
        return "Berisiko gizi lebih (possible risk of overweight)"
    elif weight_kg <= z_scores['SD+3']:
        return "Gizi lebih (overweight)"
    return "Obesitas (obese)"

def calculate_minimum_nutrition(age_months: int, status: str) -> dict:
    """Calculate daily nutritional needs based on age and status"""
    base_needs = {
        "0-5": {
            "Calcium": 200,  # mg
            "Carbohydrate": 59,  # g
            "Energy": 550,  # kcal
            "Iron": 0.3,  # mg
            "Protein": 9,  # g
            "Total Fat": 31  # g
        },
        "6-11": {
            "Calcium": 270,
            "Carbohydrate": 105,
            "Energy": 800,
            "Iron": 11,
            "Protein": 15,
            "Total Fat": 35
        },
        "12-36": {
            "Calcium": 650,
            "Carbohydrate": 215,
            "Energy": 1350,
            "Iron": 7,
            "Protein": 20,
            "Total Fat": 45
        },
        "37-60": {
            "Calcium": 1000,
            "Carbohydrate": 220,
            "Energy": 1400,
            "Iron": 10,
            "Protein": 25,
            "Total Fat": 50
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
