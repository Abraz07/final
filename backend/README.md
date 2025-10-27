# RW Tools Authentication Backend

Spring Boot backend service for RW Tools authentication system with PostgreSQL database.

## Tech Stack

- **Java**: 17
- **Spring Boot**: 3.2.0
- **Database**: PostgreSQL
- **Security**: Spring Security + JWT
- **Build Tool**: Maven

## Project Structure

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/rwtools/auth/
│   │   │   ├── config/              # Security & JWT configuration
│   │   │   │   ├── JwtUtil.java
│   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   └── SecurityConfig.java
│   │   │   ├── controller/          # REST API endpoints
│   │   │   │   └── AuthController.java
│   │   │   ├── dto/                 # Data Transfer Objects
│   │   │   │   ├── SignupRequest.java
│   │   │   │   ├── LoginRequest.java
│   │   │   │   ├── AuthResponse.java
│   │   │   │   └── ErrorResponse.java
│   │   │   ├── exception/           # Exception handling
│   │   │   │   ├── EmailAlreadyExistsException.java
│   │   │   │   ├── InvalidCredentialsException.java
│   │   │   │   └── GlobalExceptionHandler.java
│   │   │   ├── model/               # JPA entities
│   │   │   │   └── User.java
│   │   │   ├── repository/          # Database repositories
│   │   │   │   └── UserRepository.java
│   │   │   ├── service/             # Business logic
│   │   │   │   ├── AuthService.java
│   │   │   │   └── CustomUserDetailsService.java
│   │   │   └── RwToolsAuthApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       └── application-prod.properties
│   └── test/
├── database/
│   └── setup.sql                    # Database setup script
├── pom.xml                          # Maven dependencies
└── README.md
```

## Prerequisites

1. **Java 17** or higher
2. **Maven 3.6+**
3. **PostgreSQL 12+**
4. **pgAdmin** (optional, for database management)

## Database Setup

### 1. Install PostgreSQL

**macOS:**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Windows/Linux:**
Download from [PostgreSQL official website](https://www.postgresql.org/download/)

### 2. Create Database

```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE rwtools_db;

# Exit
\q
```

Or run the setup script:
```bash
psql -U postgres -f database/setup.sql
```

### 3. Configure Database Connection

Update `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/rwtools_db
spring.datasource.username=postgres
spring.datasource.password=your_password
```

## Running the Application

### 1. Build the project

```bash
cd backend
mvn clean install
```

### 2. Run the application

```bash
mvn spring-boot:run
```

Or run with a specific profile:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

The server will start on `http://localhost:8080`

## API Endpoints

### Health Check
```
GET /api/auth/health
```

### Signup
```
POST /api/auth/signup
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "1234567890",
  "domain": "Finance",
  "password": "password123",
  "role": "USER"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "id": 1,
  "email": "john@example.com",
  "fullName": "John Doe",
  "role": "USER"
}
```

### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "id": 1,
  "email": "john@example.com",
  "fullName": "John Doe",
  "role": "USER"
}
```

## Error Responses

### Email Already Exists (409 Conflict)
```json
{
  "error": "EMAIL_EXISTS",
  "message": "Email is already registered",
  "timestamp": "2025-10-26T18:45:00"
}
```

### Invalid Credentials (401 Unauthorized)
```json
{
  "error": "INVALID_CREDENTIALS",
  "message": "Invalid email or password",
  "timestamp": "2025-10-26T18:45:00"
}
```

### Validation Error (400 Bad Request)
```json
{
  "email": "Email should be valid",
  "password": "Password must be at least 6 characters"
}
```

## User Roles

- **USER**: Regular subscriber with domain access
- **ADMIN**: Administrator with full access
- **OPS**: Operations team member

## Security Features

- **Password Encryption**: BCrypt hashing
- **JWT Authentication**: Stateless token-based auth
- **CORS**: Configured for React frontend (localhost:3000)
- **Input Validation**: Bean validation on all requests
- **Exception Handling**: Global exception handler

## Testing with cURL

### Signup
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

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## pgAdmin Configuration

1. Open pgAdmin
2. Create new server connection:
   - **Name**: RW Tools Local
   - **Host**: localhost
   - **Port**: 5432
   - **Database**: rwtools_db
   - **Username**: postgres
   - **Password**: your_password

## Troubleshooting

### Port 8080 already in use
```bash
# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>
```

### Database connection refused
- Ensure PostgreSQL is running: `brew services list` (macOS)
- Check credentials in application.properties
- Verify database exists: `psql -U postgres -l`

### JWT secret key error
- Ensure jwt.secret in application.properties is at least 256 bits (32 characters)

## Development Tips

1. **Hot Reload**: Spring Boot DevTools enables automatic restart
2. **Database Changes**: Set `spring.jpa.hibernate.ddl-auto=update` for development
3. **Logging**: Adjust logging levels in application.properties
4. **Profiles**: Use different profiles for dev/prod environments

## Next Steps

1. Connect frontend React app to these endpoints
2. Add refresh token functionality
3. Implement password reset feature
4. Add email verification
5. Set up role-based access control for protected routes

## Support

For issues or questions, contact your team lead or refer to Spring Boot documentation:
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Spring Security](https://spring.io/projects/spring-security)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
