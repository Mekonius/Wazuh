#!/usr/bin/env bash
set -euo pipefail

# Simple helper to start the Wazuh stack and ensure the Docker agent is wired
# to the manager correctly.

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$STACK_DIR"

COMMAND="${1:-up}"

case "$COMMAND" in
  up)
    echo "[manage-wazuh] Bringing up Wazuh stack..."
    docker compose up -d wazuh-indexer wazuh-manager wazuh-dashboard wazuh-agent
    ;;
  down)
    echo "[manage-wazuh] Stopping Wazuh stack..."
    docker compose down
    ;;
  status)
    echo "[manage-wazuh] Docker containers:"
    docker compose ps
    echo
    echo "[manage-wazuh] Agents seen by manager:"
    docker exec -it wazuh-manager /var/ossec/bin/agent_control -l || echo "manager not running"
    ;;
  fix-agent)
    echo "[manage-wazuh] Ensuring wazuh-agent container is up..."
    docker compose up -d wazuh-agent

    echo "[manage-wazuh] Patching agent ossec.conf inside container..."
    docker exec wazuh-agent sh -c "\
      sed -i 's#<address></address>#<address>wazuh-manager</address>#' /var/ossec/etc/ossec.conf && \
      sed -i 's#<manager_address></manager_address>#<manager_address>wazuh-manager</manager_address>#' /var/ossec/etc/ossec.conf && \
      /var/ossec/bin/wazuh-control restart
    "

    echo "[manage-wazuh] Current agents:"
    docker exec -it wazuh-manager /var/ossec/bin/agent_control -l
    ;;
  *)
    echo "Usage: $0 {up|down|status|fix-agent}" >&2
    exit 1
    ;;
esac
