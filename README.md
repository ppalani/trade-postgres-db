# 🚀 PostgreSQL with Docker Compose

This project sets up a **production-grade PostgreSQL database** using Docker Compose. It leverages environment variables from a `.env` file for flexibility and security.

---

## 📂 Project Structure

```
.
├── docker-compose.yml   # Docker Compose configuration
├── .env                 # Environment variables
└── initdb/              # (Optional) SQL scripts to auto-run at startup
```

---

## ⚙️ Prerequisites

* 🐳 [Docker](https://docs.docker.com/get-docker/)
* 📦 [Docker Compose](https://docs.docker.com/compose/install/)

---

## 📝 Environment Variables (`.env`)

Your `.env` file should look like this:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=admin123
POSTGRES_DB=postgres
POSTGRES_CONTAINER_NAME=postgres_db
POSTGRES_VOLUME_NAME=postgres_data
```

> ⚠️ **Tip**: Never commit your real credentials to GitHub. Use `.gitignore`.

---

## 🐘 Docker Compose File (`docker-compose.yml`)

```yaml
version: "3.8"

services:
  db:
    image: postgres:16
    container_name: ${POSTGRES_CONTAINER_NAME}
    restart: unless-stopped
    env_file:
      - .env
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
    volumes:
      - ${POSTGRES_VOLUME_NAME}:/var/lib/postgresql/data
      # Optional: mount SQL scripts to initialize DB
      # - ./initdb/:/docker-entrypoint-initdb.d/
    ports:
      - "5432:5432"

volumes:
  ${POSTGRES_VOLUME_NAME}:
    driver: local
```

---

## ▶️ Usage

### 1️⃣ Start the Database

```bash
docker compose up -d
```

### 2️⃣ Check Container Status

```bash
docker ps
```

✅ You should see your container running with the name from `.env`.

### 3️⃣ Connect to PostgreSQL

```bash
docker exec -it ${POSTGRES_CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

### 4️⃣ Stop Services

```bash
docker compose down
```

---

## 🗄️ Data Persistence

Data is stored in a Docker **named volume** (`postgres_data` by default). Even if the container restarts or is removed, your database files are safe.

> 🛑 If you run `docker compose down -v`, the volume will also be deleted.

---

## 🛠️ Healthcheck

This setup uses `pg_isready` to ensure the database is up before dependent services connect.

📊 Example check:

```bash
docker inspect --format='{{json .State.Health}}' ${POSTGRES_CONTAINER_NAME} | jq
```

---

## ✨ Optional: Init Scripts

If you place `.sql` or `.sh` scripts inside the `initdb/` directory, they will run **automatically** when the container is first created.

Example:

```sql
-- initdb/create_tables.sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);
```

---

## 📸 Visual Overview

### Container Lifecycle ⚡

```
┌─────────────┐    docker compose up   ┌───────────────┐
│   .env      │  ------------------->  │  Postgres DB  │
└─────────────┘                        └───────────────┘
       │                                    │
       │    volumes                         │
       ▼                                    ▼
┌──────────────┐                       ┌──────────────┐
│   Host Disk  │ <--- persists data -->│   Container  │
└──────────────┘                       └──────────────┘
```

---

## ✅ Best Practices

* Pin to a **specific Postgres version** (e.g. `postgres:16`) to avoid surprises.
* Use `.env` (or **Docker secrets**) instead of hardcoding credentials.
* Add backups (e.g. `pg_dump`) for production setups.
* Monitor health statu
