# Wazuh Docker Project

This project provides a Docker-based setup for Wazuh, including the Wazuh Indexer, Manager, and Dashboard. The following sections outline the structure, setup instructions, and usage of the project.

## Project Structure

```
wazuh-docker
├── docker-compose.yml       # Defines the services for Wazuh
├── config                   # Configuration files for Wazuh services
│   ├── indexer              # Configuration for Wazuh Indexer
│   │   └── opensearch.yml   # OpenSearch configuration
│   ├── manager              # Configuration for Wazuh Manager
│   │   └── ossec.conf       # Wazuh Manager configuration
│   └── dashboard            # Configuration for Wazuh Dashboard
│       └── opensearch_dashboards.yml # Dashboard configuration
├── certs                    # Directory for SSL certificates
│   └── .gitkeep             # Keeps the certs directory in version control
├── scripts                  # Scripts for setup and management
│   └── setup.sh             # Setup script for initializing services
├── .env                     # Environment variables for Docker Compose
├── .gitignore               # Git ignore file
└── README.md                # Project documentation
```

## Setup Instructions

1. **Clone the Repository**: Clone this repository to your local machine.
   
   ```bash
   git clone <repository-url>
   cd wazuh-docker
   ```

2. **Configure Environment Variables**: Update the `.env` file with any necessary environment variables for your setup.

3. **Modify Configuration Files**: Adjust the configuration files located in the `config` directory as needed for your environment.

4. **Start the Services**: Use Docker Compose to start the Wazuh services.

   ```bash
   docker compose up -d
   ```

5. **Access the Dashboard**: Once the services are running, you can access the Wazuh Dashboard at `https://localhost`.

6. **Check Agents**: To see which agents the manager knows about:

   ```bash
   docker exec -it wazuh-manager /var/ossec/bin/agent_control -l
   ```

   You should see an entry similar to `wazuh-agent` once the Docker agent is connected.

## Usage

- **Wazuh Indexer**: The Wazuh Indexer is responsible for storing and managing security data. You can customize its behavior through the `config/indexer/opensearch.yml` file.

- **Wazuh Manager**: The Wazuh Manager processes alerts and manages agents. Configuration can be modified in `config/manager/ossec.conf`.

- **Wazuh Dashboard**: The Wazuh Dashboard provides a web interface for visualizing security data. Its settings are located in `config/dashboard/opensearch_dashboards.yml`.

## Additional Notes

- Ensure that Docker and Docker Compose are installed on your machine.
- For SSL/TLS support, place your certificates in the `certs` directory.
- The `scripts/setup.sh` file can be used for additional setup tasks after the containers are up.
- The `manage-wazuh.sh` helper script can be used to start/stop the stack, check status, and repair the Docker agent configuration.

   Basic usage from the `wazuh-docker` folder:

   ```bash
   chmod +x manage-wazuh.sh

   ./manage-wazuh.sh up        # start indexer, manager, dashboard, agent
   ./manage-wazuh.sh status    # show containers and registered agents
   ./manage-wazuh.sh fix-agent # patch agent ossec.conf inside container
   ./manage-wazuh.sh down      # stop stack
   ```

This README provides a comprehensive overview of the Wazuh Docker project, making it easier for users to understand and utilize the setup effectively.