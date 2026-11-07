#!/bin/bash
# Slide-calibratie (Livingroom / Slide 2)
# - Haalt het IP van de Slide dynamisch op via het MAC-adres
# - Start de calibratie via de lokale API
# - Wacht lang genoeg en controleert daarna het resultaat
#
# Gebruik op je Mac:
#   chmod +x slide-calibratie.sh
#   ./slide-calibratie.sh
#
# Let op: de lokale API werkt alleen als de Slide in lokale modus staat.
# Een POST zonder body blijft hangen; daarom sturen we altijd -d '{}' mee.

MAC="98:f4:ab:64:e0:44"
SLIDE_ID="slide_98F4AB64E044"

echo "Slide-calibratie"
echo "================"
echo

# Stap 1: omschakelen naar lokale modus
read -n 1 -s -r -p "Druk met een paperclip 2x snel in het voorste gaatje onderin de slide tot het lampje 5x knippert, druk daarna op een toets om verder te gaan"
echo
echo

# Stap 2: IP dynamisch opzoeken
MY_IP=$(ipconfig getifaddr en0 2>/dev/null)
SUB=${MY_IP%.*}
if [ -z "$SUB" ]; then
  echo "Kan je eigen IP-adres niet bepalen (en0). Ben je verbonden met wifi?"
  exit 1
fi
echo "Je Mac: $MY_IP, subnet: $SUB.0/24"
echo "Zoek de Slide (MAC $MAC)..."

# Eerst via de ARP-tabel (snel)
ping -c 2 "$SUB.255" >/dev/null 2>&1
sleep 2
SLIDE_IP=$(arp -a 2>/dev/null | grep -i "$MAC" | head -1 | sed -E 's/.*\(([0-9.]+)\).*/\1/')

# Niet gevonden? Scan het subnet met de lokale API (parallel, 20 tegelijk)
if [ -z "$SLIDE_IP" ]; then
  echo "Niet in de ARP-tabel, scan het subnet..."
  SLIDE_IP=$(seq 1 254 | xargs -P 20 -I{} sh -c 'OUT=$(curl -s -m 1 -X POST -H "Content-Type: application/json" -d "{}" http://'"$SUB"'.{}/rpc/Slide.GetInfo 2>/dev/null); case "$OUT" in *'"$SLIDE_ID"'*) echo "'"$SUB"'.{}";; esac' | head -1)
fi

if [ -z "$SLIDE_IP" ]; then
  echo "Slide niet gevonden op $SUB.0/24."
  echo "Controleer of de Slide aan staat, op hetzelfde wifi-netwerk zit,"
  echo "en of het lampje echt 5x snel knipperde (lokale modus)."
  exit 1
fi
echo "Slide gevonden op: $SLIDE_IP"
echo

# Hulpfunctie: GetInfo ophalen
get_info() {
  curl -s -m 5 -X POST -H 'Content-Type: application/json' -d '{}' "http://$SLIDE_IP/rpc/Slide.GetInfo"
}

# Stap 3: status vóór de calibratie
echo "Status vóór calibratie:"
INFO_BEFORE=$(get_info)
if [ -z "$INFO_BEFORE" ]; then
  echo "Geen antwoord op GetInfo. Staat de Slide wel in lokale modus (5x snel knipperen)?"
  exit 1
fi
echo "$INFO_BEFORE"
echo

# calib_time uitlezen (reistijd enkele reis, in milliseconden)
CALIB_TIME=$(echo "$INFO_BEFORE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('calib_time', 0))" 2>/dev/null)
if [ -z "$CALIB_TIME" ] || [ "$CALIB_TIME" = "0" ]; then
  CALIB_TIME=$(echo "$INFO_BEFORE" | grep -o '"calib_time": *[0-9]*' | grep -o '[0-9]*')
fi
if [ -z "$CALIB_TIME" ]; then
  CALIB_TIME=29093
fi
echo "calib_time vóór: ${CALIB_TIME} ms (enkele reis)"

# Wachtijd: heen + terug (minimaal 60 seconden)
WAIT=$((CALIB_TIME * 2 / 1000))
if [ "$WAIT" -lt 60 ]; then
  WAIT=60
fi
echo "Wachtijd na calibratie: $WAIT seconden"
echo

# Stap 4: calibratie starten
echo "Calibratie starten..."
CAL_RESULT=$(curl -s -m 10 -X POST -H 'Content-Type: application/json' -d '{}' "http://$SLIDE_IP/rpc/Slide.Calibrate")
echo "Antwoord: $CAL_RESULT"
echo "Het gordijn beweegt nu heen en weer. Niet onderbreken, niet aan het gordijn trekken."
echo

# Stap 5: voldoende lang wachten
REMAINING=$WAIT
while [ "$REMAINING" -gt 0 ]; do
  echo "Wachten... nog $REMAINING seconden tot de controle"
  if [ "$REMAINING" -gt 10 ]; then
    sleep 10
    REMAINING=$((REMAINING - 10))
  else
    sleep "$REMAINING"
    REMAINING=0
  fi
done
echo

# Stap 6: status ná de calibratie controleren
echo "Status ná calibratie:"
INFO_AFTER=$(get_info)
if [ -z "$INFO_AFTER" ]; then
  echo "Geen antwoord op GetInfo na de calibratie. Wacht nog een minuut en draai dan handmatig:"
  echo "  curl -m 5 -X POST -H 'Content-Type: application/json' -d '{}' http://$SLIDE_IP/rpc/Slide.GetInfo"
  exit 1
fi
echo "$INFO_AFTER"
echo

CALIB_TIME_AFTER=$(echo "$INFO_AFTER" | python3 -c "import sys, json; print(json.load(sys.stdin).get('calib_time', 0))" 2>/dev/null)
if [ -z "$CALIB_TIME_AFTER" ] || [ "$CALIB_TIME_AFTER" = "0" ]; then
  CALIB_TIME_AFTER=$(echo "$INFO_AFTER" | grep -o '"calib_time": *[0-9]*' | grep -o '[0-9]*')
fi
echo "calib_time vóór: $CALIB_TIME ms"
echo "calib_time ná:   $CALIB_TIME_AFTER ms"
if [ -n "$CALIB_TIME_AFTER" ] && [ "$CALIB_TIME_AFTER" != "$CALIB_TIME" ]; then
  echo "Calibratie gelukt: calib_time is veranderd."
else
  echo "Let op: calib_time is niet veranderd. Test of het gordijn nu wel volledig sluit."
  echo "Zo niet, dan is het waarschijnlijk een kracht/wrijving-probleem (motorsterkte),"
  echo "en die instelling zit niet in de lokale API."
fi
echo

# Stap 7: terug naar cloud-modus, zodat Alexa weer werkt
read -n 1 -s -r -p "Druk nu met een paperclip 2x snel in het voorste gaatje onderin de slide tot het lampje 2x langzaam knippert (cloud-modus, Alexa werkt weer), druk daarna op een toets om verder te gaan"
echo
echo
sleep 5
echo "Controleren of de Slide terug is in cloud-modus (GetInfo hoort dan niet meer te antwoorden)..."
if curl -s -m 5 -X POST -H 'Content-Type: application/json' -d '{}' "http://$SLIDE_IP/rpc/Slide.GetInfo" >/dev/null 2>&1; then
  echo "Let op: de Slide antwoordt nog steeds lokaal. Hij staat mogelijk nog in lokale modus."
  echo "Druk de resetknop nog een keer 2x in tot het lampje 2x langzaam knippert."
else
  echo "Klaar. De Slide antwoordt niet meer lokaal, dus hij staat weer in cloud-modus."
  echo "Alexa zou nu weer moeten werken, met de nieuwe calibratie."
fi

