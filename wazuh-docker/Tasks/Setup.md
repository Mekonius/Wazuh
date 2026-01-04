# 🧑‍🎓 Elevguide – Wazuh i DevNet

Denne guide hjælper dig med at **installere, forstå og bruge Wazuh** til at overvåge dit Python API, som kører på en Linux VM i cloud.

Målet er **ikke** at blive SIEM-ekspert, men at forstå:
- hvordan logs opstår
- hvordan netværk og services overvåges
- hvordan sikkerhed hænger sammen med DevNet

---

## 🎯 Hvad er Wazuh? (kort forklaring)

Wazuh er et **sikkerheds- og overvågningsværktøj**.

Det kan:
- overvåge Linux-systemer
- analysere logfiler
- opdage fejl og angreb
- give alarmer, når noget unormalt sker

👉 Tænk på Wazuh som **et overvågningskamera for dit API**.

---

## 🏗️ Arkitektur (det vi bygger)

```
Client (curl / Postman)
   ↓ HTTPS
Nginx (reverse proxy)
   ↓
Python API (systemd service)
   ↓
Logfiler
   ↓
Wazuh Agent → Wazuh Manager → Dashboard
```

---

## 🔹 Del 1: Installation af Wazuh (All-in-One)

> ⚠️ Kør alle kommandoer som `root` eller med `sudo`

### 1️⃣ Opdater systemet
```bash
sudo apt update && sudo apt upgrade -y
```

### 2️⃣ Installer Wazuh (all-in-one)
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

⏳ Installationen tager nogle minutter.

### 3️⃣ Notér login-oplysninger
Efter installationen får du:
- URL til dashboard
- brugernavn
- password

Gem dem!

---

## 🔹 Del 2: Log ind i Wazuh Dashboard

1. Åbn browser
2. Gå til:
```
https://DIN_VM_IP
```
3. Log ind med oplysningerne fra installationen

✅ Hvis dashboardet vises → Wazuh kører korrekt

---

## 🔹 Del 3: Forstå hvad Wazuh ser

I dashboardet kan du se:
- Operativsystem
- CPU / RAM
- Åbne porte
- Services
- Sikkerhedshændelser

### Mini-øvelse
1. Stop dit API:
```bash
sudo systemctl stop api.service
```
2. Se i Wazuh om der kommer en event
3. Start API igen
```bash
sudo systemctl start api.service
```

👉 Forklaring: Wazuh overvåger systemets tilstand

---

## 🔹 Del 4: Log dit Python API korrekt

### 1️⃣ Tilføj logging i dit API (eksempel)
```python
import logging

logging.basicConfig(
    filename="/var/log/api.log",
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

logging.info("API started")
```

Ved forkert API-key:
```python
logging.warning("Invalid API key from %s", request.remote_addr)
```

### 2️⃣ Test at loggen virker
```bash
cat /var/log/api.log
```

---

## 🔹 Del 5: Overvåg API-loggen i Wazuh

Wazuh overvåger automatisk mange logfiler.

Sørg for at:
- logfilen eksisterer
- API skriver til den

### Test
1. Lav et forkert API-kald
2. Se loggen vokse
3. Tjek Wazuh dashboard → Events

👉 Du har nu koblet **API → log → Wazuh**

---

## 🔹 Del 6: Netværk & sikkerhed (det vigtige)

Når du laver et API-kald, sker følgende:
1. Client sender HTTPS request
2. Trafik går via port 443
3. Nginx modtager request
4. API behandler request
5. Log skrives
6. Wazuh analyserer loggen

### Begreber du skal kunne forklare
- IP-adresse
- Port
- HTTPS
- Client / Server
- Logfil

---

## 🔹 Del 7: Fejlsøgning (typiske problemer)

### API vises ikke i Wazuh
- Kører API som service?
- Skrives der til logfilen?
- Rettigheder på `/var/log/api.log`?

### Kan ikke logge ind på dashboard
- Firewall: port 443 åben?
- Brug korrekt IP

---

## ✅ Afleveringskrav

Du skal kunne vise:
- API kører på Linux VM
- API tilgås via HTTPS
- Logs skrives korrekt
- Wazuh viser events
- Forklaring af netværk og sikkerhed

---

## 🎓 Husk

> **DevNet handler ikke kun om kode**
>
> Det handler om **kode + netværk + drift + sikkerhed**

Wazuh binder det hele sammen.

