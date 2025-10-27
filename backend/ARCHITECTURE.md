# RW Tools Backend Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     React Frontend (Port 3000)               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Home Page   │  │  Login Page  │  │ Signup Page  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/REST API
                            │
┌─────────────────────────────────────────────────────────────┐
│              Spring Boot Backend (Port 8080)                 │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              AuthController                            │  │
│  │  POST /api/auth/signup                                │  │
│  │  POST /api/auth/login                                 │  │
│  │  GET  /api/auth/health                                │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              AuthService                               │  │
│  │  - signup(SignupRequest)                              │  │
│  │  - login(LoginRequest)                                │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           UserRepository (JPA)                        │  │
│  │  - findByEmail(String)                                │  │
│  │  - existsByEmail(String)                              │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         Security Configuration                         │  │
│  │  - JWT Authentication Filter                          │  │
│  │  - Password Encoder (BCrypt)                          │  │
│  │  - CORS Configuration                                 │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ JDBC
                            │
┌─────────────────────────────────────────────────────────────┐
│              PostgreSQL Database (Port 5432)                 │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    users table                         │  │
│  │  - id (BIGSERIAL PRIMARY KEY)                         │  │
│  │  - full_name (VARCHAR NOT NULL)                       │  │
│  │  - email (VARCHAR UNIQUE NOT NULL)                    │  │
│  │  - phone_number (VARCHAR NOT NULL)                    │  │
│  │  - domain (VARCHAR)                                   │  │
│  │  - password (VARCHAR NOT NULL) [BCrypt hashed]       │  │
│  │  - role (VARCHAR NOT NULL) [USER/ADMIN/OPS]          │  │
│  │  - is_active (BOOLEAN DEFAULT true)                  │  │
│  │  - created_at (TIMESTAMP)                             │  │
│  │  - updated_at (TIMESTAMP)                             │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Request Flow

### Signup Flow
```
1. User fills signup form in React
   ↓
2. POST /api/auth/signup with JSON body
   ↓
3. AuthController receives request
   ↓
4. Validates request (email format, password length, etc.)
   ↓
5. AuthService.signup()
   ↓
6. Check if email exists in database
   ↓
7. Hash password with BCrypt
   ↓
8. Save user to database
   ↓
9. Generate JWT token
   ↓
10. Return AuthResponse with token
   ↓
11. React stores token and redirects to dashboard
```

### Login Flow
```
1. User enters email/password in React
   ↓
2. POST /api/auth/login with credentials
   ↓
3. AuthController receives request
   ↓
4. AuthService.login()
   ↓
5. Find user by email
   ↓
6. Verify password with BCrypt
   ↓
7. Generate JWT token
   ↓
8. Return AuthResponse with token
   ↓
9. React stores token for authenticated requests
```

## Security Features

### Password Security
- **BCrypt Hashing**: Passwords are hashed with BCrypt (strength 10)
- **Never stored in plain text**
- **Salt automatically generated** per password

### JWT Authentication
- **Token Structure**: Header.Payload.Signature
- **Expiration**: 24 hours (configurable)
- **Claims**: email, role
- **Algorithm**: HS256

### CORS Configuration
- **Allowed Origin**: http://localhost:3000
- **Allowed Methods**: GET, POST, PUT, DELETE, OPTIONS
- **Credentials**: Enabled

## Database Schema

### users Table
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    domain VARCHAR(100),
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('USER', 'ADMIN', 'OPS')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

## API Endpoints

### POST /api/auth/signup
**Request:**
```json
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

**Error (409 Conflict):**
```json
{
  "error": "EMAIL_EXISTS",
  "message": "Email is already registered",
  "timestamp": "2025-10-26T18:45:00"
}
```

### POST /api/auth/login
**Request:**
```json
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

**Error (401 Unauthorized):**
```json
{
  "error": "INVALID_CREDENTIALS",
  "message": "Invalid email or password",
  "timestamp": "2025-10-26T18:45:00"
}
```

## Component Responsibilities

### Controller Layer
- **AuthController**: Handle HTTP requests/responses
- Validate input
- Return appropriate status codes

### Service Layer
- **AuthService**: Business logic for authentication
- **CustomUserDetailsService**: Load user for Spring Security

### Repository Layer
- **UserRepository**: Database operations
- JPA interface with custom queries

### Configuration Layer
- **SecurityConfig**: Spring Security setup
- **JwtUtil**: JWT token generation/validation
- **JwtAuthenticationFilter**: Intercept requests for token validation

### Exception Layer
- **GlobalExceptionHandler**: Centralized error handling
- **Custom Exceptions**: EmailAlreadyExistsException, InvalidCredentialsException

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Framework | Spring Boot 3.2.0 |
| Language | Java 17 |
| Database | PostgreSQL 14+ |
| ORM | Spring Data JPA / Hibernate |
| Security | Spring Security + JWT |
| Build Tool | Maven |
| Password Hashing | BCrypt |
| Token | JWT (JJWT library) |

## Environment Configuration

### Development
- Database: localhost:5432
- Auto DDL: update
- SQL logging: enabled

### Production
- Database: environment variables
- Auto DDL: validate
- SQL logging: disabled

## Future Enhancements

1. **Refresh Token**: Implement token refresh mechanism
2. **Email Verification**: Send verification email on signup
3. **Password Reset**: Forgot password functionality
4. **Rate Limiting**: Prevent brute force attacks
5. **Audit Logging**: Track user activities
6. **Role-based Access**: Fine-grained permissions
7. **OAuth2**: Social login integration
8. **Two-Factor Auth**: Additional security layer
