# MOTIS-kit (eigen reisplanner-server)
Draait MOTIS (open-source, MIT) met Nederlandse GTFS + live vertragingen (OVapi) en serveert je app via één https-adres.

## 1. Oracle-server (gratis, creditcard alleen ter verificatie)
1. Account op cloud.oracle.com; kies een thuisregio waar Ampere A1 beschikbaar is. NOOIT op "Upgrade" klikken.
2. Maak een Budget met alarm op €1 (Billing → Budgets).
3. Compute → Instance maken: Ubuntu 24.04, shape **VM.Standard.A1.Flex**, **2 OCPU / 12 GB** (binnen de gratis grens; check in de console wat jouw account geeft), bootvolume 50 GB, upload je publieke SSH-sleutel. Bij "Out of capacity": later opnieuw proberen.
4. Laat poort 22 als enige open; de rest gaat via Tailscale.
(Alternatief: gebruikte mini-pc met Ubuntu; stappen 2-4 vervallen.)

## 1b. Testen op een Chromebook (Linux aanzetten: Instellingen → Ontwikkelaars) of andere kleine machine
Gebruik een kleiner kaartgebied: `BBOX="4.8,51.25,6.3,52.15" bash setup.sh` (Utrecht, Zaltbommel, Eindhoven, Horst). Zorg voor ~10 GB vrije schijfruimte. Geen server nodig; later verhuis je dezelfde kit.

## Let op Oracle
Oracle weigert volgens derden virtuele/prepaidkaarten; een fysieke Visa/Mastercard (ook debit) is nodig. Alternatieven: Azure for Students (GitHub Student Pack, geen creditcard, $100/jaar) of een gebruikte mini-pc. Met GitHub Pro (in het pack) kun je Pages ook vanuit een privé-repo draaien.

## 2. Installeren (op de server)
```
git clone <jouw-repo-met-deze-map> && cd <repo>/motis-kit
bash setup.sh        # download ~1,5 GB, import duurt even
./test.sh            # (in ~/motis/...) laat 3 reisopties zien
```
## 3. Tailscale (iPhone <-> server, gratis persoonlijk plan; controleer de actuele voorwaarden)
```
curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up
sudo tailscale serve --bg 8081
```
Zet in de Tailscale-admin MagicDNS + HTTPS aan, installeer de Tailscale-app op je iPhone en open het getoonde `https://<naam>.ts.net` in Safari → Zet op beginscherm.

## Onderhoud
Dagelijks 03:30 ververst `update.sh` de dienstregeling. Logs: `sudo journalctl -u motis -n 50`.
