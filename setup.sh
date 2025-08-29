#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Backspace nur setzen, wenn Terminal vorhanden
if [ -t 0 ]; then
    stty erase ^H
fi

# Funktion: farbige Überschrift (grün)
ueberschrift() {
    echo -e "\e[32m$1\e[0m"
}

# Funktion: farbige Frage (gelb)
frage() {
    echo -ne "\e[33m$1\e[0m"
}

# Funktion: apt update
funktion_update() {
    ueberschrift "=== Paketlisten werden aktualisiert ==="
    apt update
}

# Funktion: apt upgrade automatisch ohne Nachfragen
funktion_upgrade_auto() {
    ueberschrift "=== Upgrade wird automatisch ausgeführt ==="
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
}

# Funktion: SSH aktivieren
funktion_ssh_aktivieren() {
    ueberschrift "=== SSH wird aktiviert ==="
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 2m/' /etc/ssh/sshd_config
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
    systemctl enable ssh
    systemctl restart ssh
    echo "SSH wurde aktiviert und Konfiguration angepasst."
}

# Funktion: Benutzer erstellen
funktion_benutzer_erstellen() {
    ueberschrift "=== Neuer Benutzer wird erstellt ==="
    frage "Benutzername: "
    read -r benutzername
    frage "Passwort: "
    read -s -r passwort
    echo
    useradd -m -s /bin/bash "$benutzername"
    echo "$benutzername:$passwort" | chpasswd
    echo "Benutzer '$benutzername' wurde erstellt."
}

# Funktion: Programme installieren
funktion_programme_installieren() {
    ueberschrift "=== Programme werden installiert ==="
    frage "Bitte geben Sie die Programme ein (durch Leerzeichen getrennt): "
    read -r programme
    if [ -n "$programme" ]; then
        apt install -y $programme
        echo "Installation abgeschlossen."
    else
        echo "Keine Programme angegeben."
    fi
}

# --- Hauptteil ---
funktion_update
funktion_upgrade_auto

# SSH-Abfrage
frage "Möchten Sie SSH aktivieren? (j/n): "
read -r antwort
if [[ "$antwort" =~ ^[Jj]$ ]]; then
    funktion_ssh_aktivieren
else
    echo "SSH wird nicht aktiviert."
fi

# Benutzer-Abfrage
frage "Möchten Sie einen neuen Benutzer erstellen? (j/n): "
read -r antwort
if [[ "$antwort" =~ ^[Jj]$ ]]; then
    funktion_benutzer_erstellen
else
    echo "Kein Benutzer wird erstellt."
fi

# Zusätzliche Programme
frage "Möchten Sie zusätzliche Programme installieren? (j/n): "
read -r antwort
if [[ "$antwort" =~ ^[Jj]$ ]]; then
    funktion_programme_installieren
else
    echo "Keine zusätzlichen Programme werden installiert."
fi

ueberschrift "=== Skript beendet ==="
