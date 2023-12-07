#!/bin/bash

# Check if arguments are provided
if [ $# -lt 2 ]; then
    # echo "Usage: $0 <service_name> <port>"
    echo "400"
    exit 1
fi

# Extract arguments
service_name=$1
port=$2

# Check if container/service already exists
if [ "$(docker ps -a -q -f name=$service_name)" ]; then
    # echo "Service '$service_name' already exists. Please use a different service name."
    echo "409"
    exit 1
fi

# Check if the port is already in use
if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
    echo "406"  # Port already in use
    exit 1
fi

# Function to check if jtoken is empty
is_jtoken_empty() {
    [ -z "$jtoken" ]
}

# Function to wait until jtoken is not empty
wait_for_jtoken() {
    local timeout=30  # Maximum wait time in seconds
    local interval=1   # Interval to check in seconds
    local waited=0

    while is_jtoken_empty && [ $waited -lt $timeout ]; do
        sleep $interval
        jtoken=$(docker logs "$service_name" | grep "token=" | awk -F"token=" '{print $2}' | awk '{print $1}' | head -n 1)
        waited=$((waited + interval))
    done
}

# Create docker-compose.yml
cat > docker-compose.yml <<EOF
services:
  $service_name:
    image: jupyter/scipy-notebook:70178b8e48d7
    container_name: $service_name
    ports:
      - "$port:8888"
    volumes:
      - jupyter$service_name:/home/jovyan/work
    environment:
      - JUPYTER_ENABLE_LAB=yes
    tty: true
    stdin_open: true

volumes:
  jupyter$service_name:

EOF

docker compose up -d

# Wait for jtoken to be available
wait_for_jtoken

echo "$jtoken"