from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, Field
from datetime import datetime, timedelta, timezone, date
from dateutil.relativedelta import relativedelta
from typing import Annotated, Literal
from sqlalchemy import desc, func
import numpy as np
from sklearn.metrics.pairwise import linear_kernel

# Local imports
from core.core import ACCESS_TOKEN_EXPIRE_MINUTES, db, app
from Model import User, UserMinNutritions, Food, Nutritions, FoodHistories, FoodBeverages
from helper import (
    get_password_hash, create_access_token, calculate_nutrition_status,
    calculate_minimum_nutrition, INGREDIENT_VECTORIZED, NUTRITION_FEATURES, id_to_index
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
async def register(form_data: RegisterForm):
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
    nutrition_mapping = {"calcium": 1, "carbohydrate": 2, "energy": 3, "iron": 4, "protein": 5, "fat": 6}

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
async def get_all_foods():
    return db.query(Food).all()

@app.get("/foods/{f_id}")
async def get_detail_foods(f_id: int):
    return db.query(FoodBeverages).filter(FoodBeverages.f_id == f_id).all()

@app.get("/get_status_nutritions")
async def get_status_nutritions(current_user: Annotated[User, Depends(get_current_user)]):
    return current_user.nutrition_status

@app.get("/get_minimum_nutrition")
async def get_minimum_nutrition(current_user: Annotated[User, Depends(get_current_user)]):
    return db.query(UserMinNutritions).filter(UserMinNutritions.u_id == current_user.id).all()

@app.put("/users/update_nutritions")
async def update_nutritions(form_data: NutritionUpdateForm, current_user: Annotated[User, Depends(get_current_user)]):
    age_months = relativedelta(datetime.now(), current_user.date_of_birth).years * 12 + \
                 relativedelta(datetime.now(), current_user.date_of_birth).months

    current_user.weight = form_data.weight
    current_user.height = form_data.height
    current_user.nutrition_status = calculate_nutrition_status(age_months, current_user.gender, form_data.height, form_data.weight)
    db.commit()

    nutrition_data = calculate_minimum_nutrition(age_months, current_user.nutrition_status)
    nutrition_mapping = {"calcium": 1, "carbohydrate": 2, "energy": 3, "iron": 4, "protein": 5, "fat": 6}

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
async def post_food_histories(form_data: FoodHistoriesForm, current_user: Annotated[User, Depends(get_current_user)]):
    current_date = date.today()
    last_record = db.query(FoodHistories).order_by(desc(FoodHistories.id)).first()
    next_id = last_record.id + 1 if last_record else 1

    new_food = FoodHistories(id=next_id, f_id=form_data.f_id, u_id=current_user.id, date=current_date)
    db.add(new_food)
    db.commit()

    return {"status": "success"}

@app.get("/get_food_histories")
async def get_food_histories(current_user: Annotated[User, Depends(get_current_user)]):
    return db.query(FoodHistories).filter(FoodHistories.u_id == current_user.id, FoodHistories.date == date.today()).all()

@app.get("/food_recommendations")
async def get_recommendations(current_user: Annotated[User, Depends(get_current_user)]):
    food_histories = await get_food_histories(current_user)
    food_histories_id = [i.f_id for i in food_histories]
    food_beverages = db.query(FoodBeverages).all()
    food_beverages_id = [i.f_id for i in food_beverages]
    filter_foods_id = [f_id for f_id in food_beverages_id if f_id not in food_histories_id]

    valid_history_idx = [id_to_index[i] for i in food_histories_id if i in id_to_index]
    valid_beverage_idx = [id_to_index[i] for i in filter_foods_id if i in id_to_index]

    if not valid_history_idx or not valid_beverage_idx:
        avg_ingredient_similarity = np.zeros(len(valid_beverage_idx))
    else:
        avg_ingredient_similarity = np.mean([
            linear_kernel(INGREDIENT_VECTORIZED[i:i+1], INGREDIENT_VECTORIZED[valid_beverage_idx])[0]
            for i in valid_history_idx
        ], axis=0).tolist()

    return {"recommended_ids": filter_foods_id, "ingredient_similarity": avg_ingredient_similarity}
