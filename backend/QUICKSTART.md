# Quick Start Guide - RW Tools Backend

## Step-by-Step Setup

### 1. Install Prerequisites

#### Java 17
```bash
# macOS
brew install openjdk@17

# Verify installation
java -version
```

#### PostgreSQL
```bash
# macOS
brew install postgresql@14
brew services start postgresql@14

# Verify installation
psql --version
```

#### Maven (Optional - project includes Maven wrapper)
```bash
# macOS
brew install maven

# Verify installation
mvn -version
```

### 2. Setup Database

```bash
# Start PostgreSQL (if not already running)
brew services start postgresql@14

# Create database
psql -U postgres -c "CREATE DATABASE rwtools_db;"

# Or run the setup script
psql -U postgres -f database/setup.sql
```

**Set PostgreSQL password (if needed):**
```bash
psql -U postgres
ALTER USER postgres PASSWORD 'postgres';
\q
```

### 3. Configure Application

Edit `src/main/resources/application.properties`:

```properties
# Update these if your PostgreSQL credentials are different
spring.datasource.username=postgres
spring.datasource.password=postgres
```

### 4. Build and Run

```bash
# Navigate to backend directory
cd backend

# Build the project (first time)
./mvnw clean install

# Run the application
./mvnw spring-boot:run
```

**Alternative (if Maven is installed globally):**
```bash
mvn clean install
mvn spring-boot:run
```

### 5. Verify Backend is Running

Open browser or use curl:
```bash
curl http://localhost:8080/api/auth/health
```

Expected response: `Auth service is running`

### 6. Test Signup API

```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test User",
    "email": "test@example.com",
    "phoneNumber": "1234567890",
    "domain": "IT",
    "password": "password123",
    "role": "USER"
  }'
```

### 7. Test Login API

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## Connect Frontend to Backend

Your React frontend is already configured to use `http://localhost:8080`.

Check these files:
- `vasu/src/Pages/HomePage/SignupPage.js` (line 72)
- `vasu/src/Pages/HomePage/LoginPage.js` (should have similar axios call)

### Start Both Services

**Terminal 1 - Backend:**
```bash
cd backend
./mvnw spring-boot:run
```

**Terminal 2 - Frontend:**
```bash
cd vasu
npm start
```

Now visit: `http://localhost:3000`

## Common Issues

### Issue: Port 8080 already in use
```bash
# Find and kill process
lsof -i :8080
kill -9 <PID>
```

### Issue: Database connection error
```bash
# Check if PostgreSQL is running
brew services list

# Restart PostgreSQL
brew services restart postgresql@14
```

### Issue: Maven build fails
```bash
# Clean and rebuild
./mvnw clean
./mvnw install -DskipTests
```

### Issue: Java version mismatch
```bash
# Check Java version
java -version

# Set JAVA_HOME (macOS)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

## Database Management with pgAdmin

1. **Install pgAdmin**: Download from [pgAdmin.org](https://www.pgadmin.org/download/)

2. **Create Server Connection:**
   - Right-click "Servers" → "Create" → "Server"
   - **General Tab:**
     - Name: `RW Tools Local`
   - **Connection Tab:**
     - Host: `localhost`
     - Port: `5432`
     - Database: `rwtools_db`
     - Username: `postgres`
     - Password: `postgres`

3. **View Tables:**
   - Navigate: Servers → RW Tools Local → Databases → rwtools_db → Schemas → public → Tables
   - Right-click `users` → View/Edit Data → All Rows

## Testing Workflow

1. **Start Backend** (Terminal 1)
2. **Start Frontend** (Terminal 2)
3. **Open Browser**: http://localhost:3000
4. **Test Signup**: Create a new account
5. **Test Login**: Login with created account
6. **Verify in pgAdmin**: Check if user is created in database

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/auth/health` | Health check |
| POST | `/api/auth/signup` | Create new user |
| POST | `/api/auth/login` | Authenticate user |

## Project Structure Overview

```
backend/
├── src/main/java/com/rwtools/auth/
│   ├── config/          → Security & JWT
│   ├── controller/      → REST endpoints
│   ├── dto/            → Request/Response objects
│   ├── exception/      → Error handling
│   ├── model/          → Database entities
│   ├── repository/     → Database access
│   └── service/        → Business logic
├── src/main/resources/
│   └── application.properties  → Configuration
├── database/
│   └── setup.sql       → Database setup
└── pom.xml            → Dependencies
```

## Next Steps

1. ✅ Backend is running on port 8080
2. ✅ Frontend is running on port 3000
3. ✅ Database is configured
4. 🎯 Test signup and login from React UI
5. 🎯 Verify JWT token is returned
6. 🎯 Check user data in pgAdmin

## Support Resources

- **Spring Boot Docs**: https://spring.io/projects/spring-boot
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **JWT.io**: https://jwt.io/ (decode tokens)

## Team Collaboration

- Your part: **Home, Login, Signup** ✅
- Backend: **Authentication API** ✅
- Database: **PostgreSQL with User table** ✅

Share this backend with your team members for integration with their features (Admin, Ops, Subscriber dashboards).
