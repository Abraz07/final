-- Create database
CREATE DATABASE rwtools_db;

-- Connect to the database
\c rwtools_db;

-- Users table will be created automatically by Hibernate
-- But you can verify the schema with this query after running the app:
-- SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- Optional: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Sample data (optional - for testing)
-- Note: Passwords should be BCrypt encoded in production
-- The password 'password123' encoded with BCrypt
INSERT INTO users (full_name, email, phone_number, domain, password, role, is_active, created_at, updated_at)
VALUES 
    ('Admin User', 'admin@rwtools.com', '1234567890', NULL, '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', true, NOW(), NOW()),
    ('Ops User', 'ops@rwtools.com', '1234567891', NULL, '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'OPS', true, NOW(), NOW()),
    ('Test User', 'user@rwtools.com', '1234567892', 'Finance', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'USER', true, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;
