#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# --- Config ---
# Hier die Werte vorgeben, statt zu fragen
SSH_AKTIVIEREN=${SSH_AKTIVIEREN:-"j"}        # "j" oder "n"
BENUTZERNAME=${BENUTZERNAME:-"user1"}       # gewünschter Benutzername
PASSWORT=${PASSWORT:-"Passwort123"}         # Passwort für neuen Benutzer
PROGRAMME=${PROGRAMME:-"vim git curl"}      # Programme, die installiert werden sollen

# --- Funktionen ---
ueberschrift() {
    echo -e "\e[32m$1\e[0m"
}

funktion_update() {
    ueberschrift "=== Paketlisten werden aktualisiert ==="
    apt update
}

funktion_upgrade_auto() {
    ueberschrift "=== Upgrade wird automatisch ausgeführt ==="
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
}

funktion_ssh_aktivieren() {
    ueberschrift "=== SSH wird aktiviert ==="
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 2m/' /etc/ssh/sshd_config
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
    systemctl enable ssh
    systemctl restart ssh
    echo "SSH wurde aktiviert."
}

funktion_benutzer_erstellen() {
    ueberschrift "=== Neuer Benutzer wird erstellt ==="
    useradd -m -s /bin/bash "$BENUTZERNAME" || true
    echo "$BENUTZERNAME:$PASSWORT" | chpasswd
    echo "Benutzer '$BENUTZERNAME' wurde erstellt."
}

funktion_programme_installieren() {
    ueberschrift "=== Programme werden installiert ==="
    if [ -n "$PROGRAMME" ]; then
        DEBIAN_FRONTEND=noninteractive apt install -y $PROGRAMME
        echo "Installation abgeschlossen."
    else
        echo "Keine Programme angegeben."
    fi
}

# --- Hauptteil ---
funktion_update
funktion_upgrade_auto

# SSH
if [[ "$SSH_AKTIVIEREN" =~ ^[Jj]$ ]]; then
    funktion_ssh_aktivieren
else
    echo "SSH wird nicht aktiviert."
fi

# Benutzer
funktion_benutzer_erstellen

# Programme
funktion_programme_installieren

ueberschrift "=== Skript beendet ==="
