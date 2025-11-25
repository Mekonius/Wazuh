#!/bin/bash

# This script sets up the Wazuh environment by performing necessary initializations.

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Pull the latest images
echo "Pulling the latest Wazuh images..."
docker-compose pull

# Start the services
echo "Starting Wazuh services..."
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30  # Adjust the sleep time as necessary

# Display the status of the services
echo "Wazuh services status:"
docker-compose ps

echo "Setup complete. You can access the Wazuh dashboard at https://localhost."