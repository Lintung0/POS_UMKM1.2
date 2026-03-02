#!/bin/bash

echo "🐳 MYSQL SETUP WITH DOCKER - POS UMKM"
echo "====================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. Please logout and login again, then run this script."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Starting Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
    sleep 3
fi

echo "✅ Docker is ready"
echo ""

# MySQL configuration
MYSQL_ROOT_PASSWORD="pos_umkm_2026"
MYSQL_DATABASE="pos_umkm"
MYSQL_USER="pos_user"
MYSQL_PASSWORD="pos_password"
CONTAINER_NAME="pos-mysql"

echo "1️⃣ Setting up MySQL Container"
echo "============================="

# Stop and remove existing container if exists
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Run MySQL container
docker run -d \
  --name $CONTAINER_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -p 3306:3306 \
  --restart unless-stopped \
  mysql:8.0

echo "✅ MySQL container started"
echo ""

echo "2️⃣ Waiting for MySQL to be ready..."
echo "=================================="

# Wait for MySQL to be ready
for i in {1..30}; do
    if docker exec $CONTAINER_NAME mysqladmin ping -h localhost --silent; then
        echo "✅ MySQL is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

echo ""
echo "3️⃣ Testing Database Connection"
echo "=============================="

# Test connection
docker exec $CONTAINER_NAME mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SELECT 'Database connection successful!' as status;"

if [ $? -eq 0 ]; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    exit 1
fi

echo ""
echo "4️⃣ Updating Backend Configuration"
echo "================================="

# Update .env file
cat > /home/kirek/code/pos-umkm/backend/.env << EOF
# Database Configuration (MySQL Docker)
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=$MYSQL_USER
DB_PASSWORD=$MYSQL_PASSWORD
DB_NAME=$MYSQL_DATABASE

# Server Configuration
SERVER_PORT=8082
GIN_MODE=debug

# JWT Configuration
JWT_SECRET=MYJWTKEY12345
EOF

echo "✅ Backend configuration updated"
echo ""

echo "5️⃣ MySQL Container Information"
echo "=============================="
echo "Container Name: $CONTAINER_NAME"
echo "Database Name: $MYSQL_DATABASE"
echo "Username: $MYSQL_USER"
echo "Password: $MYSQL_PASSWORD"
echo "Root Password: $MYSQL_ROOT_PASSWORD"
echo "Port: 3306"
echo "Host: localhost"

echo ""
echo "6️⃣ Docker Commands for Management"
echo "================================="
echo "Start container:  docker start $CONTAINER_NAME"
echo "Stop container:   docker stop $CONTAINER_NAME"
echo "View logs:        docker logs $CONTAINER_NAME"
echo "Connect to MySQL: docker exec -it $CONTAINER_NAME mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE"

echo ""
echo "✅ MySQL Docker setup completed!"
echo "🚀 Ready to restart POS system with MySQL backend"
echo ""
echo "Next steps:"
echo "1. cd /home/kirek/code/pos-umkm"
echo "2. ./stop.sh && ./start.sh"
echo "3. Check logs for successful MySQL connection"
