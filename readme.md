# Nutrivana

Nutrivana adalah aplikasi yang dirancang untuk memudahkan pengelolaan data nutrisi dengan integrasi machine learning dan database modern.

---

## Prasyarat (Pre-requisite)

Sebelum menjalankan Nutrivana, pastikan Anda telah menginstal:

- **Docker**  
  Download dan install dari [https://www.docker.com/](https://www.docker.com/)

- **MLflow**  
  Download dan install dari [https://mlflow.org/](https://mlflow.org/)

---

## Cara Jalankan Aplikasi

### Jalankan 
```
docker compose up -d
```

---
## Cara Akses Aplikasi

### 1. Frontend
Akses aplikasi web Nutrivana pada:
- [http://localhost:5173](http://localhost:5173)

### 2. Backend (Dokumentasi API)
Akses dokumentasi API (Swagger UI) pada:
- [http://localhost:8000/docs](http://localhost:8000/docs)

### 3. Database (PostgreSQL)
- Host: `localhost`
- Port: `5432`
- Username: `nutrivana`
- Password: `nutrivana`

Akses database menggunakan aplikasi seperti **pgAdmin** atau **DBeaver**.

---

## Catatan Tambahan

- Pastikan container Docker untuk aplikasi backend, frontend, dan database sudah berjalan sebelum mengakses aplikasi.
- Jika mengalami kendala, periksa konfigurasi Docker dan pastikan port yang diperlukan tidak digunakan oleh aplikasi lain.

---

Selamat menggunakan Nutrivana!