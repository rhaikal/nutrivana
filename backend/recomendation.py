from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, Field
from datetime import datetime, timedelta, timezone
from dateutil.relativedelta import relativedelta
from typing import Annotated, Literal
from datetime import date
from sqlalchemy import desc, func

# Local imports
from core.core import ACCESS_TOKEN_EXPIRE_MINUTES, db, app
from Model import User, UserMinNutritions, Food, Nutritions, FoodHistories, FoodBeverages
from helper import get_password_hash, create_access_token, calculate_nutrition_status, calculate_minimum_nutrition 
from auth import authenticate_user, get_current_user

# ======================
# Models
# ======================

class Token(BaseModel):
    """Token response model"""
    access_token: str
    token_type: str

class RegisterForm(BaseModel):
    """User registration form model"""
    username: str
    password: str
    confirm_password: str
    weight: float
    height: float
    gender: Literal["l", "p"]
    date_of_birth: str = Field(..., pattern=r"^\d{4}-\d{2}-\d{2}$")

class NutritionUpdateForm(BaseModel):
    """Nutrition update form model"""
    height: float
    weight: float

class FoodHistoriesForm(BaseModel):
    """Food histories form model"""
    f_id: int

# ======================
# API Endpoints
# ======================

@app.post("/login", response_model=Token)
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]) -> Token:
    """User login endpoint"""
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

@app.post("/register")
async def register(form_data: RegisterForm):
    """User registration endpoint"""
    if form_data.password != form_data.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password and confirm password do not match"
        )

    # Create new user
    date_of_birth = datetime.strptime(form_data.date_of_birth, "%Y-%m-%d")
    age_months = relativedelta(datetime.now(), date_of_birth).years * 12 + relativedelta(datetime.now(), date_of_birth).months
    
    new_user = User(
        id=(db.query(User).order_by(desc(User.id)).first().id + 1 if db.query(User).count() else 1),
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

    # Create nutrition records
    nutrition_data = calculate_minimum_nutrition(age_months, new_user.nutrition_status)
    nutrition_mapping = {
        "Calcium": 1, "Carbohydrate": 2, "Energy": 3, 
        "Iron": 4, "Protein": 5, "Total Fat": 6
    }
    
    nutrition_objects = [
        UserMinNutritions(
            id=(db.query(UserMinNutritions).order_by(desc(UserMinNutritions.id)).first().id + i + 1 
            if db.query(UserMinNutritions).count() else i + 1),
            u_id=new_user.id,
            n_id=nutrition_mapping[key],
            value=value
        )
        for i, (key, value) in enumerate(nutrition_data.items())
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
    """Get all foods endpoint"""
    try:
        return db.query(Food).all()
    finally:
        db.close()

@app.get("/foods/{f_id}")
async def get_detail_foods(f_id: int):
    food = db.query(FoodBeverages).filter(FoodBeverages.f_id == f_id).all()
    return food

@app.get("/get_minimum_nutrition")
async def get_minimum_nutrition(current_user: Annotated[User, Depends(get_current_user)]):
    """Get user's minimum nutrition requirements"""
    return db.query(UserMinNutritions).filter(UserMinNutritions.u_id == current_user.id).all()

@app.put("/users/update_nutritions")
async def update_nutritions(
    form_data: NutritionUpdateForm,
    current_user: Annotated[User, Depends(get_current_user)]
):
    """Update user's nutrition data"""
    # Calculate age in months
    age_months = relativedelta(datetime.now(), current_user.date_of_birth).years * 12 + \
                 relativedelta(datetime.now(), current_user.date_of_birth).months
    
    # Update user data
    current_user.weight = form_data.weight
    current_user.height = form_data.height
    current_user.nutrition_status = calculate_nutrition_status(
        age_months, current_user.gender, form_data.height, form_data.weight
    )
    db.commit()
    
    # Update nutrition records
    nutrition_data = calculate_minimum_nutrition(age_months, current_user.nutrition_status)
    nutrition_mapping = {
        "Calcium": 1, "Carbohydrate": 2, "Energy": 3, 
        "Iron": 4, "Protein": 5, "Total Fat": 6
    }
    
    # Delete old records
    db.query(UserMinNutritions).filter(UserMinNutritions.u_id == current_user.id).delete()
    
    # Create new records
    nutrition_objects = [
        UserMinNutritions(
            id=(db.query(UserMinNutritions).order_by(desc(UserMinNutritions.id)).first().id + i + 1 
                if db.query(UserMinNutritions).count() else i + 1),
            u_id=current_user.id,
            n_id=nutrition_mapping[key],
            value=value
        )
        for i, (key, value) in enumerate(nutrition_data.items())
    ]
    
    db.add_all(nutrition_objects)
    db.commit()
    
    return {"status": "success"}

@app.post("/post_food_histories")
async def post_food_histories(
        form_data: FoodHistoriesForm, 
        current_user: Annotated[User, Depends(get_current_user)]
    ):
    current_date = date.today()
    last_record = db.query(FoodHistories).order_by(FoodHistories.id.desc()).first()
    next_id = last_record.id + 1 if last_record else 1
    new_foods = FoodHistories(
        id=next_id,
        f_id=form_data.f_id,
        u_id=current_user.id,
        date=current_date
    )
    db.add(new_foods)
    db.commit()

    return {"status": "success"}

# def get_remaining_needs(current_user):
#     current_user_id = current_user.id
#     min_nutrition = db.query(UserMinNutritions).filter_by(u_id=current_user_id).all()
#     food_histories = db.query(FoodHistories).filter_by(u_id=current_user_id).filter(func.date(FoodHistories.date) == func.current_date()).all()
#     return food_histories

# @app.get("/get_recomendations")
# def get_recommendations(current_user: Annotated[User, Depends(get_current_user)]):
#     remaining = get_remaining_needs(current_user)
#     return remaining
    
#     # 1. Filter out already consumed foods
#     filtered_food = food_db[~food_db['id'].isin(consumed_foods)].copy()
    
#     # 2. Calculate ingredient similarity if there's consumption history
#     if consumed_foods:
#         consumed_indices = food_db[food_db['id'].isin(consumed_foods)].index
#         avg_ingredient_similarity = np.mean([
#             linear_kernel(ingredient_vectors[idx:idx+1], 
#                         ingredient_vectors[filtered_food.index])[0] 
#             for idx in consumed_indices
#         ], axis=0)
#         filtered_food['ingredient_similarity'] = avg_ingredient_similarity
#     else:
#         filtered_food['ingredient_similarity'] = 0
    
#     # 3. Find top 3 nutrients with highest remaining needs
#     sorted_remaining = sorted(remaining.items(), key=lambda x: x[1], reverse=True)
#     top_nutrients = [nutrient for nutrient, amount in sorted_remaining[:3] if amount > 0]
    
#     # 4. Calculate nutrition score based on top needed nutrients
#     if top_nutrients:
#         # Calculate weighted sum where weights are the remaining amounts
#         filtered_food['nutrition_score'] = sum(
#             filtered_food[nutrient] * remaining[nutrient] 
#             for nutrient in top_nutrients
#         )
        
#         # Normalize scores to 0-1 range
#         max_score = filtered_food['nutrition_score'].max()
#         if max_score > 0:
#             filtered_food['nutrition_score'] /= max_score
#     else:
#         filtered_food['nutrition_score'] = 0
    
#     # 5. Calculate hybrid score (80% nutrition needs, 20% ingredient similarity)
#     filtered_food['hybrid_score'] = (
#         filtered_food['nutrition_score'] * 0.8 + 
#         filtered_food['ingredient_similarity'] * 0.2
#     )
    
#     # 6. Return top recommendations
#     return filtered_food.sort_values('hybrid_score', ascending=False).head(3)
