from sqlalchemy import Column, Integer, String, Date, Float, ForeignKey
from sqlalchemy.dialects.postgresql import ARRAY
from core.core import Base

class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(255))
    password = Column(String(60))
    gender = Column(String(1))
    date_of_birth = Column(Date)
    weight = Column(Integer)
    height = Column(Integer)
    nutrition_status = Column(String(10))

class Nutritions(Base):
    __tablename__ = 'nutritions'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255))

class Food(Base):
    __tablename__ = 'foods'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255))

class UserMinNutritions(Base):
    __tablename__ = 'user_minimum_nutritions'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    u_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    n_id = Column(Integer, ForeignKey('nutritions.id'), nullable=False)
    value = Column(Float)

class FoodHistories(Base):
    __tablename__ = 'food_histories'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    u_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    f_id = Column(Integer, ForeignKey('foods.id'), nullable=False)
    date = Column(Date)

class FoodBeverages(Base):
    __tablename__ = 'food_beverages'
    __table_args__ = {
        'info': {'is_view': True}
    }
    
    f_id = Column(Integer, primary_key=True)
    f_name = Column(String(255))
    i_ids = Column(ARRAY(Integer))
    i_names = Column(ARRAY(String))
    calcium = Column(Float)
    carbohydrate = Column(Float)
    energy = Column(Float)
    fat = Column(Float)
    iron = Column(Float)
    protein = Column(Float)

class Ingredients(Base):
    __tablename__ = 'ingredients'

    id = Column(Integer, primary_key=True)
    name = Column(String(255))


class UserGrowthRecords(Base):
    __tablename__ = 'user_growth_records'

    id = Column(Integer, primary_key=True)
    u_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    weight = Column(Integer)
    height = Column(Integer)
    nutrition_status = Column(String(10))
    date = Column(Date)

