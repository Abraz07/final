# Setup Guide for New Machine

## Prerequisites Installation

### 1. Install Java 17
**macOS:**
```bash
brew install openjdk@17
```

**Windows:**
- Download from: https://adoptium.net/
- Install and set JAVA_HOME environment variable

**Linux:**
```bash
sudo apt install openjdk-17-jdk
```

Verify:
```bash
java -version
```

### 2. Install Maven
**macOS:**
```bash
brew install maven
```

**Windows:**
- Download from: https://maven.apache.org/download.cgi
- Extract and add to PATH

**Linux:**
```bash
sudo apt install maven
```

Verify:
```bash
mvn -version
```

### 3. Install PostgreSQL
**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Windows:**
- Download from: https://www.postgresql.org/download/windows/
- Run installer (includes pgAdmin4)
- Set postgres user password during installation

**Linux:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 4. Install pgAdmin4
**macOS:**
```bash
brew install --cask pgadmin4
```

**Windows:**
- Included with PostgreSQL installer

**Linux:**
```bash
sudo apt install pgadmin4
```

---

## Database Setup

### Step 1: Set PostgreSQL Password
```bash
psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"
```

**If psql command not found:**
- **macOS:** `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"`
- **Windows:** Open "SQL Shell (psql)" from Start Menu
- **Linux:** `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"`

### Step 2: Create Database
```bash
psql -U postgres -c "CREATE DATABASE rwtool_db;"
```

### Step 3: Run Setup Script
```bash
cd /path/to/backend
psql -U postgres -d rwtool_db -f database/setup.sql
```

### Step 4: Verify Database
Open pgAdmin4:
1. Connect to PostgreSQL server (localhost)
2. Expand Databases → rwtool_db
3. Check that `users` table exists under Schemas → public → Tables

---

## Backend Configuration

### Step 1: Update application.properties
File: `src/main/resources/application.properties`

```properties
# Server Configuration
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/rwtool_db
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true

# JWT Configuration
jwt.secret=YourVerySecureSecretKeyThatIsAtLeast256BitsLongForHS256Algorithm
jwt.expiration=86400000

# Logging
logging.level.org.springframework.security=DEBUG
logging.level.rwtool.homepage=DEBUG
```

### Step 2: Build the Project
```bash
cd backend
mvn clean install
```

### Step 3: Run the Backend
```bash
mvn spring-boot:run
```

Or run from IntelliJ IDEA:
1. Open `backend` folder in IntelliJ
2. Wait for Maven to import dependencies
3. Right-click on `RwToolsAuthApplication.java`
4. Select "Run 'RwToolsAuthApplication'"

### Step 4: Verify Backend is Running
```bash
curl http://localhost:8080/api/auth/health
```

Expected response: `Auth service is running`

---

## Frontend Setup

### Step 1: Install Node.js
**macOS:**
```bash
brew install node
```

**Windows:**
- Download from: https://nodejs.org/

**Linux:**
```bash
sudo apt install nodejs npm
```

### Step 2: Install Dependencies
```bash
cd vasu
npm install
```

### Step 3: Start Frontend
```bash
npm start
```

Frontend will run on: http://localhost:3000

---

## Testing the Application

### 1. Test Signup
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test User",
    "email": "test@example.com",
    "phoneNumber": "1234567890",
    "domain": "test.com",
    "password": "password123",
    "role": "USER"
  }'
```

### 2. Test Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. Open Frontend
Navigate to: http://localhost:3000

---

## Common Issues & Solutions

### Issue 1: Port 8080 already in use
**Solution:**
```bash
# macOS/Linux
lsof -ti:8080 | xargs kill -9

# Windows
netstat -ano | findstr :8080
taskkill /PID <PID_NUMBER> /F
```

### Issue 2: PostgreSQL connection refused
**Solution:**
- Check if PostgreSQL is running:
  ```bash
  # macOS
  brew services list
  
  # Linux
  sudo systemctl status postgresql
  
  # Windows
  Check Services app for postgresql service
  ```

### Issue 3: Maven build fails
**Solution:**
```bash
mvn clean
rm -rf ~/.m2/repository
mvn install
```

### Issue 4: Database authentication failed
**Solution:**
- Reset postgres password:
  ```bash
  psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"
  ```
- Update `application.properties` with correct password

### Issue 5: Table doesn't exist
**Solution:**
- Drop and recreate database:
  ```bash
  psql -U postgres -c "DROP DATABASE rwtool_db;"
  psql -U postgres -c "CREATE DATABASE rwtool_db;"
  psql -U postgres -d rwtool_db -f database/setup.sql
  ```

---

## Quick Start Commands

```bash
# Start PostgreSQL
brew services start postgresql@15  # macOS
sudo systemctl start postgresql    # Linux

# Start Backend
cd backend
mvn spring-boot:run

# Start Frontend (in new terminal)
cd vasu
npm start
```

---

## Project Structure
```
finalllll/
├── backend/
│   ├── src/main/java/rwtool/homepage/
│   │   ├── RwToolsAuthApplication.java
│   │   ├── config/
│   │   ├── controller/
│   │   ├── dto/
│   │   ├── exception/
│   │   ├── model/
│   │   ├── repository/
│   │   └── service/
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── database/
│   │   └── setup.sql
│   └── pom.xml
└── vasu/
    ├── src/
    ├── public/
    └── package.json
```

---

## Support

If you encounter any issues:
1. Check the logs in the terminal
2. Verify all services are running
3. Check database connection in pgAdmin
4. Ensure all ports are available (8080 for backend, 3000 for frontend, 5432 for PostgreSQL)
