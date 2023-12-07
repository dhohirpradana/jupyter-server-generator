#!/bin/bash

# Function to check if a port is in use
port_in_use() {
  lsof -i :$1 -sTCP:LISTEN -t >/dev/null
}

# Find an unused port starting from a minimum value
find_unused_port() {
  local port=$1
  local max_port=65535  # Maximum port number
  
  while [ $port -le $max_port ]; do
    if ! port_in_use $port; then
      echo $port
      return
    fi
    ((port++))
  done

  echo "404"
}

# Usage example: Find an unused port starting from 38000
unused_port=$(find_unused_port 38000)
echo "$unused_port"