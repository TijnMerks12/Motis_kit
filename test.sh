#!/usr/bin/env bash
# Test: route Zaltbommel -> Eindhoven Centraal (coördinaten bij benadering), over een uur.
T=$(date -u -d '+1 hour' +%Y-%m-%dT%H:%M:%SZ)
curl -sf "http://127.0.0.1:8080/api/v5/plan?fromPlace=51.8118,5.2517&toPlace=51.4433,5.4812&time=$T&numItineraries=3" | python3 -c '
import json,sys
d=json.load(sys.stdin)
for i in d.get("itineraries",[]):
    print(i.get("startTime"),"->",i.get("endTime"),"overstappen:",i.get("transfers"))
    for l in i.get("legs",[]):
        print("  ",l.get("mode"),(l.get("routeShortName") or ""),(l["from"].get("name")),"->",(l["to"].get("name")),"realtime" if l.get("realTime") else "")
print("aantal reisopties:",len(d.get("itineraries",[])))' || echo "Geen antwoord: MOTIS draait nog niet of import mislukt (sudo journalctl -u motis -n 50)"
