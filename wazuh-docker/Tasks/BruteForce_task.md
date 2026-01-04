#  Øvelser – Angrebs-demoer med Wazuh

##  HF5 / Svendeprøve-niveau – Faglig forventning

Disse øvelser forventes forklaret med **professionelt fagsprog** som anvendes i drift, DevOps og sikkerhed.

Eleven skal kunne anvende og forklare begreber som:
- authentication vs authorization
- request / response lifecycle
- reverse proxy
- attack surface
- log ingestion og alerting
- availability og integrity (CIA triad)
- mitigation og prevention

Forklaringer skal være **årsagsbaserede** (why), ikke kun handlingsbaserede (how).


Disse øvelser viser, hvordan **mistænkelig adfærd og angreb** kan opdages via logs og Wazuh.

Formålet er **forståelse**, ikke hacking.

>  I simulerer *kontrollerede angreb* mod jeres **eget API**.

---

##  Overordnet læringsmål

Efter øvelserne skal du kunne forklare:
- hvordan et angreb ser ud i logs
- hvordan Wazuh opdager det
- hvilke netværksbegreber der er involveret (IP, port, request)

---

#  Demo 1: Invalid API key (auth failure)

###  Hvad simulerer vi?
En klient prøver at tilgå API’et uden korrekt adgang.

---

### 1️ Forudsætning i API
Dit API skal tjekke API-key i en header, fx:
```http
X-API-Key: secret_key
```

Ved forkert key skal API:
- returnere **401 Unauthorized**
- skrive en log

Eksempel i Python:
```python
logging.warning("Invalid API key from %s", request.remote_addr)
```

---

### 2️ Simulér angrebet

Kør fra terminal eller Postman:
```bash
curl https://DIT_DOMÆNE/api/data \
  -H "X-API-Key: forkert_key"
```

Gentag 3–5 gange.

---

### 3️ Se hvad der sker

**På serveren**
```bash
cat /var/log/api.log
```

**I Wazuh Dashboard**
- Security events / Alerts
- Se IP-adressen
- Se tidspunkt

---

### 4️ Forklaring (det du skal kunne sige)
> *“En klient fra denne IP sender requests uden korrekt API-key. API’et afviser og logger det, og Wazuh opdager hændelsen.”*

---

#  Demo 2: Brute force mod API

###  Hvad simulerer vi?
En klient prøver mange gange på kort tid.

---

### 1️ Simulér brute force

```bash
for i in {1..20}; do
  curl https://DIT_DOMÆNE/api/data \
    -H "X-API-Key: forkert_key"
done
```

---

### 2️ Hvad skal I observere?

- Mange requests fra samme IP
- Mange warnings i logfilen
- Flere events i Wazuh

---

### 3️ Forklaring
> *“Mange fejl fra samme IP på kort tid kan indikere brute force. Det opdages via logs og overvågning.”*

---

#  Demo 3: Service manipulation (drift-angreb)

###  Hvad simulerer vi?
At et vigtigt system stopper.

---

### 1️ Stop API-service
```bash
sudo systemctl stop api.service
```

Vent 30 sekunder.

### 2️ Start igen
```bash
sudo systemctl start api.service
```

---

### 3️ Observation

I Wazuh:
- Service stopped
- Service started

---

### 4️ Forklaring
> *“Overvågning opdager når kritiske services stopper, hvilket kan skyldes fejl eller angreb.”*

---

#  Demo 4: Netværksstøj (port scan – valgfri)

>  Kun hvis tiden og niveauet er til det

### 1️ Simulér port scan
```bash
sudo apt install nmap -y
nmap DIT_VM_IP
```

---
###  Observation

I Wazuh:
- Network scan detection
- IP-adresse

---

###  Forklaring
> *“Port scanning bruges til at finde åbne services. Overvågning kan opdage denne adfærd.”*

---

# Fremlæggelsesspørgsmål (brug disse)

Eleven skal kunne svare på:
- Hvad gjorde klienten?
- Hvad skete der i API’et?
- Hvad blev logget?
- Hvad viste Wazuh?
- Hvorfor er det vigtigt?

---

## Husk

> *Et angreb er bare data og adfærd – logs er beviset.*

Wazuh hjælper dig med at se det.

