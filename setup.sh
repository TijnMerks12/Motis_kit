#!/usr/bin/env bash
# Eenmalige installatie op Ubuntu (Oracle ARM of x86, mini-pc, Chromebook-Linux). Gebruik: bash setup.sh
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"; DIR="${MOTIS_DIR:-$HOME/motis}"; USR="$(id -un)"
sudo apt-get update -qq && sudo apt-get install -y -qq curl bzip2 python3
# swapruimte als er weinig geheugen is (import kan veel RAM gebruiken)
if [ "$(free -g | awk '/Mem:/{print $2}')" -lt 16 ] && [ -z "$(swapon --show --noheadings)" ]; then
  sudo fallocate -l 8G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile >/dev/null && sudo swapon /swapfile
  grep -q /swapfile /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi
mkdir -p "$DIR" && cd "$DIR"
case "$(uname -m)" in x86_64) T=linux-amd64;; aarch64|arm64) T=linux-arm64;; *) echo "Onbekende architectuur"; exit 1;; esac
if [ -z "$(find . -maxdepth 2 -type f -name motis -perm -u+x | head -1)" ]; then
  curl -fL -o motis.tar.bz2 "https://github.com/motis-project/motis/releases/latest/download/motis-$T.tar.bz2" && tar xjf motis.tar.bz2
fi
BIN="$(find "$DIR" -maxdepth 2 -type f -name motis -perm -u+x | head -1)"; RUN="$(dirname "$BIN")"
[ -n "$BIN" ] || { echo "MOTIS-programma niet gevonden na uitpakken"; exit 1; }
cp "$KIT/config.yml" "$RUN/config.yml"; cp "$KIT/gateway.py" "$KIT/update.sh" "$KIT/test.sh" "$RUN/"; rm -rf "$RUN/app"; cp -r "$KIT/app" "$RUN/app"; chmod +x "$RUN"/*.sh
cd "$RUN"
[ -f netherlands-latest.osm.pbf ] || curl -fL -o netherlands-latest.osm.pbf https://download.geofabrik.de/europe/netherlands-latest.osm.pbf
curl -fL -o nl_ovapi.gtfs.zip https://gtfs.ovapi.nl/nl/gtfs-nl.zip
./motis import
for s in motis gateway; do
  [ $s = motis ] && EXE="$RUN/motis server" || EXE="/usr/bin/python3 $RUN/gateway.py"
  sudo tee /etc/systemd/system/$s.service >/dev/null <<UNIT
[Unit]
Description=$s
After=network-online.target
[Service]
User=$USR
WorkingDirectory=$RUN
ExecStart=$EXE
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
done
sudo systemctl daemon-reload && sudo systemctl enable --now motis gateway
(crontab -l 2>/dev/null | grep -v update.sh; echo "30 3 * * * $RUN/update.sh >> $RUN/update.log 2>&1") | crontab -
echo "Klaar. Test met: $RUN/test.sh (wacht ~1 minuut tot MOTIS gestart is)"
