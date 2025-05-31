from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, Field
from datetime import datetime, timedelta, timezone, date
from dateutil.relativedelta import relativedelta
from typing import Annotated, Literal, List
from sqlalchemy import desc, func
import numpy as np
from sklearn.metrics.pairwise import linear_kernel

# Local imports
from core.core import ACCESS_TOKEN_EXPIRE_MINUTES, db, app
from Model import User, UserMinNutritions, Food, Nutritions, FoodHistories, FoodBeverages
from helper import (
    get_password_hash, create_access_token, calculate_nutrition_status,
    calculate_minimum_nutrition, INGREDIENT_VECTORIZED, NUTRITION_FEATURES, id_to_index, nutrition_mapping
)
from auth import authenticate_user, get_current_user

# ======================
# Models
# ======================

class Token(BaseModel):
    access_token: str
    token_type: str

class RegisterForm(BaseModel):
    username: str
    password: str
    confirm_password: str
    weight: float
    height: float
    gender: Literal["l", "p"]
    date_of_birth: str = Field(..., pattern=r"^\d{4}-\d{2}-\d{2}$")

class NutritionUpdateForm(BaseModel):
    height: float
    weight: float

class FoodHistoriesForm(BaseModel):
    f_id: int

class FoodHistoriesBulkForm(BaseModel):
    items: List[FoodHistoriesForm]

# ======================
# API Endpoints
# ======================

@app.post("/login", response_model=Token)
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]) -> Token:
    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(
        data={"id": user.id, "username": user.username},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    return Token(access_token=access_token, token_type="bearer")

@app.post("/register", response_model=Token)
def register(form_data: RegisterForm):
    if form_data.password != form_data.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password and confirm password do not match"
        )

    date_of_birth = datetime.strptime(form_data.date_of_birth, "%Y-%m-%d")
    age_months = relativedelta(datetime.now(), date_of_birth).years * 12 + \
                 relativedelta(datetime.now(), date_of_birth).months

    user_id = (db.query(User).order_by(desc(User.id)).first().id + 1) if db.query(User).count() else 1

    new_user = User(
        id=user_id,
        username=form_data.username,
        password=get_password_hash(form_data.password),
        weight=form_data.weight,
        height=form_data.height,
        gender=form_data.gender,
        date_of_birth=date_of_birth,
        nutrition_status=calculate_nutrition_status(age_months, form_data.gender, form_data.height, form_data.weight),
    )
    db.add(new_user)
    db.commit()

    nutrition_data = calculate_minimum_nutrition(age_months, new_user.nutrition_status)

    next_id = lambda: (db.query(UserMinNutritions).order_by(desc(UserMinNutritions.id)).first().id + 1) if db.query(UserMinNutritions).count() else 1

    nutrition_objects = [
        UserMinNutritions(
            id=next_id() + i,
            u_id=new_user.id,
            n_id=nutrition_mapping[key],
            value=value
        ) for i, (key, value) in enumerate(nutrition_data.items())
    ]
    db.add_all(nutrition_objects)
    db.commit()

    return Token(
        access_token=create_access_token(
            data={"id": new_user.id, "username": new_user.username},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        ),
        token_type="bearer"
    )

@app.get("/foods")
def get_all_foods():
    result = db.query(
        FoodBeverages.f_id,
        FoodBeverages.f_name,
        FoodBeverages.calcium,
        FoodBeverages.carbohydrate,
        FoodBeverages.energy,
        FoodBeverages.fat,
        FoodBeverages.iron,
        FoodBeverages.protein
    ).all()
    # Ubah hasil query menjadi list of dict
    foods = [
        {
            "id": r.f_id,
            "name": r.f_name,
            "calcium": r.calcium,
            "carbohydrate": r.carbohydrate,
            "energy": r.energy,
            "fat": r.fat,
            "iron": r.iron,
            "protein": r.protein
        }
        for r in result
    ]
    return foods

@app.get("/foods/{f_id}")
def get_detail_foods(f_id: int):
    result = db.query(
        FoodBeverages.f_id,
        FoodBeverages.f_name,
        FoodBeverages.calcium,
        FoodBeverages.carbohydrate,
        FoodBeverages.energy,
        FoodBeverages.fat,
        FoodBeverages.iron,
        FoodBeverages.protein
    ).filter(FoodBeverages.f_id == f_id).first()
    
    if result is None:
        return {"error": "Food not found"}
    
    food = {
        "id": result.f_id,
        "name": result.f_name,
        "calcium": result.calcium,
        "carbohydrate": result.carbohydrate,
        "energy": result.energy,
        "fat": result.fat,
        "iron": result.iron,
        "protein": result.protein
    }
    return food

@app.get("/get_status_nutritions")
def get_status_nutritions(current_user: Annotated[User, Depends(get_current_user)]):
    return current_user.nutrition_status

@app.get("/get_minimum_nutrition")
def get_minimum_nutrition(current_user: Annotated[User, Depends(get_current_user)]):
    id_to_nutrition = {v: k for k, v in nutrition_mapping.items()}
    results = db.query(UserMinNutritions).filter(UserMinNutritions.u_id == current_user.id).all()
    output = []
    for row in results:
        output.append({
            "name": id_to_nutrition.get(row.id, "unknown"),
            "value": row.value
        })
    return output

@app.put("/update_user_nutritions")
def update_user_nutritions(form_data: NutritionUpdateForm, current_user: Annotated[User, Depends(get_current_user)]):
    age_months = relativedelta(datetime.now(), current_user.date_of_birth).years * 12 + \
                 relativedelta(datetime.now(), current_user.date_of_birth).months

    current_user.weight = form_data.weight
    current_user.height = form_data.height
    current_user.nutrition_status = calculate_nutrition_status(age_months, current_user.gender, form_data.height, form_data.weight)
    db.commit()

    nutrition_data = calculate_minimum_nutrition(age_months, current_user.nutrition_status)

    db.query(UserMinNutritions).filter(UserMinNutritions.u_id == current_user.id).delete()

    next_id = lambda: (db.query(UserMinNutritions).order_by(desc(UserMinNutritions.id)).first().id + 1) if db.query(UserMinNutritions).count() else 1

    nutrition_objects = [
        UserMinNutritions(
            id=next_id() + i,
            u_id=current_user.id,
            n_id=nutrition_mapping[key],
            value=value
        ) for i, (key, value) in enumerate(nutrition_data.items())
    ]
    db.add_all(nutrition_objects)
    db.commit()

    return {"status": "success"}

@app.post("/post_food_histories")
def post_food_histories(
    form_data: FoodHistoriesBulkForm,
    current_user: Annotated[User, Depends(get_current_user)]
):
    current_date = date.today()
    last_record = db.query(FoodHistories).order_by(desc(FoodHistories.id)).first()
    next_id = last_record.id + 1 if last_record else 1

    new_records = []
    for i, item in enumerate(form_data.items):
        new_food = FoodHistories(
            id=next_id + i,
            f_id=item.f_id,
            u_id=current_user.id,
            date=current_date
        )
        new_records.append(new_food)

    db.add_all(new_records)
    db.commit()

    return {"status": "success", "inserted": len(new_records)}

def get_food_histories_for_user(user_id: int) -> List[FoodHistories]:
    return db.query(FoodHistories).filter(
        FoodHistories.u_id == user_id,
        FoodHistories.date == date.today()
    ).all()

@app.get("/get_food_histories")
def get_food_histories(
    current_user: Annotated[User, Depends(get_current_user)]
):
    food_histories = db.query(FoodHistories).filter(
        FoodHistories.u_id == current_user.id,
        FoodHistories.date == date.today()
    ).all()
    food_histories_id = [food.f_id for food in food_histories]

    result = db.query(
        FoodBeverages.f_name,
        FoodBeverages.i_names,
        FoodBeverages.calcium,
        FoodBeverages.carbohydrate,
        FoodBeverages.energy,
        FoodBeverages.fat,
        FoodBeverages.iron,
        FoodBeverages.protein
    ).filter(FoodBeverages.f_id.in_(food_histories_id)).all()

    data = [
        {
            "food_name": r.f_name,
            "ingredient_names": r.i_names,
            "calcium": r.calcium,
            "carbohydrate": r.carbohydrate,
            "energy": r.energy,
            "fat": r.fat,
            "iron": r.iron,
            "protein": r.protein
        }
        for r in result
    ]
    return data

def get_current_nutrient_residue(current_user: User):
    food_histories = get_food_histories_for_user(current_user.id)
    total_nutrition_consumed = []

    for food_nutrition in food_histories:
        food_histories_nutrition = db.query(FoodBeverages).filter(
            FoodBeverages.f_id == food_nutrition.f_id
        ).first()
        food_histories_nutrition = {
            nutrisi: getattr(food_histories_nutrition, nutrisi, 0) or 0
            for nutrisi in NUTRITION_FEATURES
        }
        total_nutrition_consumed.append(food_histories_nutrition)

    aggregated_nutrition = {nutrisi: 0 for nutrisi in NUTRITION_FEATURES}
    for nutrition in total_nutrition_consumed:
        for nutrisi, value in nutrition.items():
            aggregated_nutrition[nutrisi] += value

    rows = (
        db.query(UserMinNutritions.value, Nutritions.name)
        .join(Nutritions, UserMinNutritions.n_id == Nutritions.id)
        .filter(UserMinNutritions.u_id == current_user.id)
        .all()
    )
    min_nutrition_needs = {name.lower(): value for value, name in rows}

    nutrient_residue = {}
    for nutrisi in NUTRITION_FEATURES:
        need = min_nutrition_needs.get(nutrisi, 0)
        consumed = aggregated_nutrition.get(nutrisi, 0)
        residue = max(0, need - consumed)
        nutrient_residue[nutrisi] = residue

    return nutrient_residue

@app.get("/get_nutrient_current")
def get_nutrient_current(
    current_user: User = Depends(get_current_user)
):
    food_histories = get_food_histories_for_user(current_user.id)
    total_nutrition_consumed = []

    for food_nutrition in food_histories:
        food_histories_nutrition = db.query(FoodBeverages).filter(
            FoodBeverages.f_id == food_nutrition.f_id
        ).first()
        food_histories_nutrition = {
            nutrisi: getattr(food_histories_nutrition, nutrisi, 0) or 0
            for nutrisi in NUTRITION_FEATURES
        }
        total_nutrition_consumed.append(food_histories_nutrition)

    aggregated_nutrition = {nutrisi: 0 for nutrisi in NUTRITION_FEATURES}
    for nutrition in total_nutrition_consumed:
        for nutrisi, value in nutrition.items():
            aggregated_nutrition[nutrisi] += value

    return aggregated_nutrition

def get_current_nutrient_deficiency_percent(current_user: User):
    food_histories = get_food_histories_for_user(current_user.id)
    total_nutrition_consumed = []

    for food_nutrition in food_histories:
        food_histories_nutrition = db.query(FoodBeverages).filter(
            FoodBeverages.f_id == food_nutrition.f_id
        ).first()
        food_histories_nutrition = {
            nutrisi: getattr(food_histories_nutrition, nutrisi, 0) or 0
            for nutrisi in NUTRITION_FEATURES
        }
        total_nutrition_consumed.append(food_histories_nutrition)

    aggregated_nutrition = {nutrisi: 0 for nutrisi in NUTRITION_FEATURES}
    for nutrition in total_nutrition_consumed:
        for nutrisi, value in nutrition.items():
            aggregated_nutrition[nutrisi] += value

    rows = (
        db.query(UserMinNutritions.value, Nutritions.name)
        .join(Nutritions, UserMinNutritions.n_id == Nutritions.id)
        .filter(UserMinNutritions.u_id == current_user.id)
        .all()
    )
    min_nutrition_needs = {name.lower(): value for value, name in rows}

    nutrient_deficiency_percent = {}
    for nutrisi in NUTRITION_FEATURES:
        need = min_nutrition_needs.get(nutrisi, 0)
        consumed = aggregated_nutrition.get(nutrisi, 0)
        if need > 0:
            residue = max(0, need - consumed)
            deficiency_percent = (residue / need) * 100
            nutrient_deficiency_percent[nutrisi] = round(deficiency_percent, 2)
        else:
            nutrient_deficiency_percent[nutrisi] = 0.0

    return nutrient_deficiency_percent

@app.get("/food_recommendations")
def get_recommendations(
    current_user: Annotated[User, Depends(get_current_user)]
):
    remaining_percent = get_current_nutrient_deficiency_percent(current_user)
    remaining = get_current_nutrient_residue(current_user)

    food_histories = get_food_histories_for_user(current_user.id)
    if not food_histories:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Belum ada histori makanan untuk user ini."
        )

    food_histories_id = [i.f_id for i in food_histories]
    food_beverages = db.query(FoodBeverages).all()
    food_beverages_id = [i.f_id for i in food_beverages]
    filter_foods_id = [f_id for f_id in food_beverages_id if f_id not in food_histories_id]

    if all(val == 0 for val in remaining.values()):
        return {
            "message": "Tidak ada kekurangan nutrisi berarti, rekomendasi tidak diperlukan.",
            "recommendations": []
        }

    valid_history_idx = [id_to_index[i] for i in food_histories_id if i in id_to_index]
    valid_beverage_idx = [id_to_index[i] for i in filter_foods_id if i in id_to_index]

    if not valid_history_idx or not valid_beverage_idx:
        avg_ingredient_similarity = np.zeros(len(valid_beverage_idx))
    else:
        avg_ingredient_similarity = np.mean([
            linear_kernel(INGREDIENT_VECTORIZED[i:i+1], INGREDIENT_VECTORIZED[valid_beverage_idx])[0]
            for i in valid_history_idx
        ], axis=0)
        avg_ingredient_similarity = avg_ingredient_similarity.tolist()

    sorted_remaining = sorted(remaining_percent.items(), key=lambda x: x[1], reverse=True)
    top_nutrients = [nutrient for nutrient, amount in sorted_remaining[:3] if amount > 0]
    if not top_nutrients:
        top_nutrients = list(remaining_percent.keys())

    food_nutrition_matrix = []
    for idx in valid_beverage_idx:
        food = db.query(FoodBeverages).filter(FoodBeverages.f_id == filter_foods_id[valid_beverage_idx.index(idx)]).first()
        if not food:
            food_nutrition_matrix.append([0.0 for _ in top_nutrients])
        else:
            food_nutrition_matrix.append([
                getattr(food, nutrient, 0) or 0 for nutrient in top_nutrients
            ])
    food_nutrition_matrix = np.array(food_nutrition_matrix)

    max_residue = np.array([remaining[nutrient] for nutrient in top_nutrients]) + 1e-8
    nutrition_score = np.sum(np.clip(food_nutrition_matrix, 0, max_residue) / max_residue, axis=1) / len(top_nutrients)

    if len(avg_ingredient_similarity) > 0 and np.max(avg_ingredient_similarity) > 0:
        ingredient_sim_norm = avg_ingredient_similarity / np.max(avg_ingredient_similarity)
    else:
        ingredient_sim_norm = np.zeros_like(nutrition_score)

    hybrid_score = 0.8 * nutrition_score + 0.2 * ingredient_sim_norm

    top_indices = np.argsort(-hybrid_score)
    top_food_ids = [filter_foods_id[i] for i in top_indices]

    n_recommend = min(3, len(top_food_ids))
    recommended_food_ids = top_food_ids[:n_recommend]

    recomendation_food = (
        db.query(FoodBeverages)
        .filter(FoodBeverages.f_id.in_(recommended_food_ids))
        .all()
    )

    return recomendation_food