#!/bin/bash

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Study.com - Initialization Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Backend Setup
echo -e "${YELLOW}[1/4] Setting up Backend...${NC}"
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    python -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt > /dev/null 2>&1
echo -e "${GREEN}✓ Backend dependencies installed${NC}"

# Create .env file
if [ ! -f ".env" ]; then
    cp ../.env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
fi

cd ..

# Frontend Setup
echo -e "${YELLOW}[2/4] Setting up Frontend...${NC}"
cd frontend

# Install dependencies
npm install > /dev/null 2>&1
echo -e "${GREEN}✓ Frontend dependencies installed${NC}"

cd ..

# Create sample data script
echo -e "${YELLOW}[3/4] Creating sample data script...${NC}"

cat > create_sample_data.py << 'EOF'
import requests
import json

BASE_URL = "http://localhost:8000/api"

# Sample users to create
users = [
    {
        "username": "admin",
        "email": "admin@study.com",
        "password": "admin123",
        "full_name": "Administrator",
        "role": "superadmin"
    },
    {
        "username": "director1",
        "email": "director@study.com",
        "password": "director123",
        "full_name": "Mr. Director",
        "role": "director"
    },
    {
        "username": "teacher1",
        "email": "teacher1@study.com",
        "password": "teacher123",
        "full_name": "Mr. Smith (Math)",
        "role": "teacher"
    },
    {
        "username": "teacher2",
        "email": "teacher2@study.com",
        "password": "teacher123",
        "full_name": "Mrs. Johnson (English)",
        "role": "teacher"
    },
    {
        "username": "student1",
        "email": "student1@study.com",
        "password": "student123",
        "full_name": "John Doe",
        "role": "student"
    },
    {
        "username": "student2",
        "email": "student2@study.com",
        "password": "student123",
        "full_name": "Jane Smith",
        "role": "student"
    },
    {
        "username": "parent1",
        "email": "parent1@study.com",
        "password": "parent123",
        "full_name": "Robert Doe",
        "role": "parent"
    },
    {
        "username": "parent2",
        "email": "parent2@study.com",
        "password": "parent123",
        "full_name": "Maria Smith",
        "role": "parent"
    }
]

print("\n" + "="*50)
print("   Creating Sample Users")
print("="*50 + "\n")

for user in users:
    try:
        response = requests.post(f"{BASE_URL}/auth/register", json=user)
        if response.status_code == 200:
            print(f"✓ {user['role'].upper()}: {user['username']} created")
        else:
            print(f"✗ {user['role'].upper()}: {user['username']} failed")
    except Exception as e:
        print(f"✗ Error: {str(e)}")

print("\n" + "="*50)
print("   Sample Data Creation Complete!")
print("="*50)
print("\n📝 Login Credentials:\n")
for user in users:
    print(f"  {user['role'].upper()}: {user['username']} / {user['password']}")
print()
EOF

echo -e "${GREEN}✓ Sample data script created${NC}"

# Create Docker support files
echo -e "${YELLOW}[4/4] Creating Docker support files...${NC}"

cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=sqlite:///./study.db
    volumes:
      - ./backend:/app

  frontend:
    image: node:18-alpine
    working_dir: /app/frontend
    ports:
      - "5173:5173"
    volumes:
      - ./frontend:/app/frontend
    command: sh -c "npm install && npm run dev"
EOF

echo -e "${GREEN}✓ Docker files created${NC}"

# Create quick start guide
cat > QUICKSTART.md << 'EOF'
# Quick Start Guide - Study.com

## 🚀 Fast Setup (Recommended)

### Option 1: Using Docker
```bash
docker-compose up
```
- Backend: http://localhost:8000
- Frontend: http://localhost:5173
- API Docs: http://localhost:8000/docs

### Option 2: Manual Setup

#### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

#### Frontend (in new terminal)
```bash
cd frontend
npm install
npm run dev
```

## 📝 Create Sample Data

```bash
# Make sure backend is running on localhost:8000
python create_sample_data.py
```

## 🔑 Default Test Accounts

After running create_sample_data.py:

| Role | Username | Password | Email |
|------|----------|----------|-------|
| Superadmin | admin | admin123 | admin@study.com |
| Director | director1 | director123 | director@study.com |
| Teacher | teacher1 | teacher123 | teacher1@study.com |
| Teacher | teacher2 | teacher123 | teacher2@study.com |
| Student | student1 | student123 | student1@study.com |
| Student | student2 | student123 | student2@study.com |
| Parent | parent1 | parent123 | parent1@study.com |
| Parent | parent2 | parent123 | parent2@study.com |

## 🎯 Access Dashboards

1. Open http://localhost:5173
2. Login with any credential above
3. You'll be redirected to role-specific dashboard

## 📚 API Documentation

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 🛠️ Troubleshooting

### Port already in use
```bash
# Change port in main.py (backend) or vite.config.js (frontend)
```

### Database issues
```bash
# Delete study.db and restart backend
rm backend/study.db
```

### npm issues
```bash
rm -rf frontend/node_modules package-lock.json
npm install
```

## 📖 API Endpoints

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login`

### Teachers
- `GET /api/teachers/profile`
- `GET /api/teachers/classes`
- `POST /api/teachers/grades`

### Students
- `GET /api/students/profile`
- `GET /api/students/my-grades`
- `GET /api/students/my-assignments`

### Parents
- `GET /api/parents/profile`
- `GET /api/parents/my-children`
- `GET /api/parents/child-grades/{student_id}`

### Directors
- `GET /api/directors/profile`
- `GET /api/directors/statistics`
- `GET /api/directors/all-students`

### Superadmin
- `GET /api/superadmin/dashboard`
- `GET /api/superadmin/users`
- `DELETE /api/superadmin/users/{user_id}`

---

**Questions?** Check README.md for more details.
EOF

echo -e "${GREEN}✓ Quick start guide created${NC}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   ✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Next steps:${NC}\n"
echo -e "${YELLOW}1. Backend:${NC}"
echo -e "   cd backend && python main.py\n"
echo -e "${YELLOW}2. Frontend (new terminal):${NC}"
echo -e "   cd frontend && npm run dev\n"
echo -e "${YELLOW}3. Create sample data:${NC}"
echo -e "   python create_sample_data.py\n"
echo -e "${YELLOW}4. Open browser:${NC}"
echo -e "   http://localhost:5173\n"
