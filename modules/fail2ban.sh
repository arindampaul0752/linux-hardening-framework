setup_fail2ban() {

	log "INFO" "Configuring Fail2ban..."

	if ! command -v fail2ban-client >/dev/null 2>&1; then
		install_package fail2ban
	else
		log "INFO" "Fail2Ban already installed."

	fi

	local JAIL_FILE="/etc/fail2ban/jail.local"
	local BACKUP="${JAIL_FILE}.bak.$(date +%F-%H%M%S)"

	[[ -f "$JAIL_FILE" ]] && run_cmd "cp $JAIL_FILE $BACKUP"

	run_cmd "cat > $JAIL_FILE <<EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

bantime.increment = true
bantime.factor = 2
bantime.max = 24h

ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
backend = auto

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
bantime = 7d
findtime = 1d
maxretry = 5
EOF"

	service_enable fail2ban
	service_reload fail2ban

	log "INFO" "Fail2Ban configured successfully."
}
