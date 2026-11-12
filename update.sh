#!/usr/bin/env bash
# Dagelijks nieuwe dienstregeling ophalen (cron 03:30). Oude data blijft staan als de download mislukt.
set -euo pipefail; cd "$(dirname "$0")"
curl -fL -o new.gtfs.zip https://gtfs.ovapi.nl/nl/gtfs-nl.zip && mv new.gtfs.zip nl_ovapi.gtfs.zip
sudo systemctl stop motis; ./motis import; sudo systemctl start motis
