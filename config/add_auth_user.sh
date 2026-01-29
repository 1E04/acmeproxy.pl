#!/usr/bin/env bash

# Absoluter Pfad zum Script-Verzeichnis
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Config im selben Ordner
CONF_FILE="$SCRIPT_DIR/acmeproxy.pl.conf"
echo $CONF_FILE

echo "ADD NEW AUTH USER"
echo "--------------------------"

read -rp "ACMEPROXY_USERNAME: " USER
read -rp "ACMEPROXY_PASSWORD (empty if using hash): " PASS
read -rp "Hash (empty if using password): " HASH
read -rp "Hosts (Add Multiple Hosts with same credentials by whitespace): " HOSTS

if [[ -z "$USER" || -z "$HOSTS" ]]; then
  echo "❌ User and Host requiered"
  exit 1
fi

if [[ -n "$PASS" && -n "$HASH" ]]; then
  echo "❌ Please use Password or Hash"
  exit 1
fi

# Host-Liste durchgehen
for HOST in $HOSTS; do
  ENTRY="        {
            'user' => '$USER',"

  if [[ -n "$PASS" ]]; then
    ENTRY+="
            'pass' => '$PASS',"
  else
    ENTRY+="
            'hash' => '$HASH',"
  fi

  ENTRY+="
            'host' => '$HOST',
        },"

  # Einfügen vor das schließende ]
  awk -v entry="$ENTRY" '
    # Wenn wir die auth-Zeile sehen, markieren
    /'\''auth'\''\s*=>\s*\[/ {
      print
      print entry
      next
    }
    { print }
' "$CONF_FILE" | sudo tee "$CONF_FILE" > /dev/null
done

echo "✅ User added successfully!"

