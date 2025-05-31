from decouple import config
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from fastapi import FastAPI
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from passlib.context import CryptContext


SECRET_KEY = config("SECRET_KEY")
ALGORITHM = config("ALGORITHM")
ACCESS_TOKEN_EXPIRE_MINUTES = config("ACCESS_TOKEN_EXPIRE_MINUTES", cast=int)
DATABASE_URL = config("DATABASE_URL")

Base = declarative_base()
if DATABASE_URL:
    engine = create_engine(DATABASE_URL)
else:
    engine = create_engine("postgresql://nutrivana:nutrivana@localhost:5432/nutrivana")

Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)

app = FastAPI()

origins = [config("FRONTEND_URL")]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

db = Session()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
