# Deploy Wazuh Docker (single-node)

This deployment is defined in `docker-compose.yml` and brings up:

- Wazuh Manager
- Wazuh Indexer (OpenSearch)
- Wazuh Dashboard
- A Wazuh Agent container enrolled to the manager

## Prerequisites

1) Increase `max_map_count` on your host (Linux). This command must be run with root permissions:

```bash
sysctl -w vm.max_map_count=262144
```

2) Generate certificates (required the first time):

```bash
docker compose -f generate-indexer-certs.yml run --rm generator
```

## Start / stop

Start in the foreground:

```bash
docker compose up
```

Start in the background:

```bash
docker compose up -d
```

Stop:

```bash
docker compose down
```

The first boot can take ~1 minute while the indexer initializes and index templates/patterns are created.

## Published ports

By default, this compose publishes:

- `443/tcp` 	 Wazuh Dashboard (mapped to container port `5601`)
- `9200/tcp` 	 Wazuh Indexer (OpenSearch)
- `1514/tcp`, `1515/tcp` and `514/udp` 	 Manager ingestion/enrollment ports

### Note about the Wazuh API port (55000)

The Wazuh API runs on port `55000` inside the manager container.

In some environments, publishing `55000:55000` to the host fails with an error like:

> ports are not available ... listen tcp 0.0.0.0:55000: bind: An attempt was made to access a socket in a way forbidden by its access permissions.

Workaround (used here): do not publish the API port to the host. The dashboard reaches the API over the internal Docker network.

If you need to access the API from the host, you can still run commands from inside the manager container:

```bash
docker compose exec wazuh.manager curl -k https://localhost:55000/
```

## Default credentials

These are the credentials configured by default in `docker-compose.yml` and the shipped OpenSearch internal users file:

- Indexer (OpenSearch): user `admin`, password `SecretPassword`
- Dashboard service account: user `kibanaserver`, password `kibanaserver`
- Wazuh API: user `wazuh-wui`, password `MyS3cr37P450r.*-`

## Troubleshooting

### Dashboard login / token errors (HTTP 500)

If the dashboard shows errors like:

- `AxiosError: Request failed with status code 500`
- `3000 - Error getting the authorization token ... Ensure the API host is accesible ...`

Common causes:

1) The dashboard cannot reach the Wazuh API.
	 - The dashboard reads API connection details from `config/wazuh_dashboard/wazuh.yml`.
	 - In this repo it uses `url: "https://wazuh.manager"` and `port: 55000`.

2) Indexer (OpenSearch) credentials in your running volumes do not match what is configured.
	 - The indexer persists data in the `wazuh-indexer-data` volume.
	 - If you change passwords/users after first boot, OpenSearch security state may not match the compose values.

Quick checks:

```bash
curl -k -u admin:SecretPassword https://localhost:9200/_cluster/health?pretty
```

```bash
docker compose exec wazuh.dashboard bash -lc \
	'curl -k -u kibanaserver:kibanaserver https://wazuh.indexer:9200/_plugins/_security/api/account'
```

Reset (destructive) if your persistent volumes contain mismatched credentials:

```bash
docker compose down
docker volume rm $(docker volume ls -q | grep wazuh-indexer-data)
docker compose up -d
```

## Optional: generate a test alert with an exact string

This is useful for validating that events are being ingested and visible in the dashboard.

### 1) Add a local rule on the manager

The manager container includes `/var/ossec/etc/rules/local_rules.xml`. Add a rule that matches your test phrase.

Example (rule id `100099`):

```xml
<rule id="100099" level="3">
	<match>welcome to dependency hell</match>
	<description>Test message received: welcome to dependency hell</description>
	<group>test,</group>
</rule>
```

Restart the manager to load rules:

```bash
docker compose exec wazuh.manager /var/ossec/bin/wazuh-control restart
```

### 2) Inject the message into the manager analysis queue

Send the exact message to the manager queue socket:

```bash
docker compose exec wazuh.manager bash -lc 'python3 - <<"PY"
import socket
msg = b"1:test:welcome to dependency hell"
path = "/var/ossec/queue/sockets/queue"
s = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
s.connect(path)
s.send(msg)
print("sent", msg)
PY'
```

Verify it landed in alerts:

```bash
docker compose exec wazuh.manager tail -n 50 /var/ossec/logs/alerts/alerts.json
```

### 3) Find it in Wazuh Dashboard

In the Wazuh Dashboard, go to Wazuh  Security events (or Discover/Threat hunting depending on your menu layout) and search:

- `rule.id:100099`
- `full_log:"welcome to dependency hell"`

## FAQ

### The indexer won"t start / keeps restarting

Most commonly the host kernel setting `vm.max_map_count` is too low.

```bash
sysctl -w vm.max_map_count=262144
```

### The dashboard is up but looks broken / says it can"t connect

First boot can be slow while the indexer initializes. Give it a minute, then re-check container status:

```bash
docker compose ps
docker compose logs --tail=200 wazuh.indexer
```

### Docker fails with "ports are not available" when exposing 55000

Some environments block or reserve certain host ports. If publishing the manager API port fails, keep it internal-only (recommended for local setups) and access it via container exec:

```bash
docker compose exec wazuh.manager curl -k https://localhost:55000/
```

### Dashboard auth/token errors after changing passwords

If you changed credentials after the first run, persistent volumes may still contain the old OpenSearch security state.

Destructive reset:

```bash
docker compose down
docker volume rm $(docker volume ls -q | grep wazuh-indexer-data)
docker compose up -d
```

### Agent enrollment shows "Duplicate name "..."

This happens when an agent with the same name is already enrolled and still considered connected. For the single-node demo agent container, a clean reset is usually simplest:

```bash
docker compose down
docker volume rm $(docker volume ls -q | grep wazuh-agent-etc)
docker compose up -d
```

### Manager logs: "Too big message size from socket"

This usually means something connected to the agent protocol port (`1514/tcp`) and sent data that doesn"t conform to the expected Wazuh protocol (or sent a payload larger than the negotiated/expected size). Avoid sending raw text to `1514`.

To validate ingestion, generate events through:

- A monitored log file on the agent, or
- The manager-side queue injection example in this README.
