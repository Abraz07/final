#!/bin/bash

# Database Setup Script for New Machine
# Run this script to set up PostgreSQL database for the project

echo "========================================="
echo "PostgreSQL Database Setup Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if PostgreSQL is installed
echo "Checking PostgreSQL installation..."
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed!${NC}"
    echo ""
    echo "Please install PostgreSQL first:"
    echo "  macOS:   brew install postgresql@15"
    echo "  Linux:   sudo apt install postgresql"
    echo "  Windows: Download from https://www.postgresql.org/download/windows/"
    exit 1
fi

echo -e "${GREEN}✓ PostgreSQL is installed${NC}"
echo ""

# Check if PostgreSQL is running
echo "Checking if PostgreSQL is running..."
if ! pg_isready -q; then
    echo -e "${YELLOW}⚠ PostgreSQL is not running. Attempting to start...${NC}"
    
    # Try to start PostgreSQL
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew services start postgresql@15
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo systemctl start postgresql
    fi
    
    sleep 2
    
    if ! pg_isready -q; then
        echo -e "${RED}❌ Failed to start PostgreSQL${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ PostgreSQL is running${NC}"
echo ""

# Set password for postgres user
echo "Setting password for postgres user..."
psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Password set successfully${NC}"
else
    echo -e "${YELLOW}⚠ Could not set password (might need sudo)${NC}"
    echo "Trying with sudo..."
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
fi
echo ""

# Drop existing database if it exists
echo "Checking for existing database..."
DB_EXISTS=$(psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='rwtool_db'")

if [ "$DB_EXISTS" = "1" ]; then
    echo -e "${YELLOW}⚠ Database 'rwtool_db' already exists${NC}"
    read -p "Do you want to drop and recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Dropping existing database..."
        psql -U postgres -c "DROP DATABASE rwtool_db;"
        echo -e "${GREEN}✓ Database dropped${NC}"
    else
        echo "Skipping database creation..."
        exit 0
    fi
fi
echo ""

# Create database
echo "Creating database 'rwtool_db'..."
psql -U postgres -c "CREATE DATABASE rwtool_db;"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create database${NC}"
    exit 1
fi
echo ""

# Run setup SQL script if it exists
if [ -f "database/setup.sql" ]; then
    echo "Running database setup script..."
    psql -U postgres -d rwtool_db -f database/setup.sql
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Setup script executed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to execute setup script${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ database/setup.sql not found, skipping...${NC}"
fi
echo ""

# Verify database and table
echo "Verifying database setup..."
TABLE_EXISTS=$(psql -U postgres -d rwtool_db -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='users'")

if [ "$TABLE_EXISTS" = "1" ]; then
    echo -e "${GREEN}✓ 'users' table exists${NC}"
else
    echo -e "${YELLOW}⚠ 'users' table not found (will be created by Spring Boot)${NC}"
fi
echo ""

# Display connection info
echo "========================================="
echo -e "${GREEN}Database Setup Complete!${NC}"
echo "========================================="
echo ""
echo "Connection Details:"
echo "  Host:     localhost"
echo "  Port:     5432"
echo "  Database: rwtool_db"
echo "  Username: postgres"
echo "  Password: postgres"
echo ""
echo "You can now:"
echo "  1. Open pgAdmin and connect to the database"
echo "  2. Run the backend: mvn spring-boot:run"
echo ""
echo "To test the connection:"
echo "  psql -U postgres -d rwtool_db -c '\\dt'"
echo ""
