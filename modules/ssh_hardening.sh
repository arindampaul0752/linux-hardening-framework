harden_ssh() {

	log "INFO" "Hardening SSH..."

	local SSH_CONFIG="/etc/ssh/sshd_config"
	local BACKUP="${SSHD_CONFIG}.bak.$(date +%F-%H%M%S)"

	[[ -f "$SSH_CONFIG" ]] || { log "ERROR" "sshd_config missing"; exit 1; }
	command -v sshd >/dev/null 2>&1 || { log "ERROR" "sshd not found"; exit 1; }

	run_cmd "cp $SSH_CONFIG $BACKUP"

	SSH_USER="${SUDO_USER: -root}"
	USER_HOME=$(eval echo "~$SSH_USER")
	AUTH_KEYS="$USER_HOME/.ssh/authorized_keys"

	if [[ ! -f "$AUTH_KEYS" || ! -s "$AUTH_KEYS" ]];  then
		log "ERROR" "No SSH key found for $SSH_USER. Aborting."
		exit 1
	fi

	log "INFO" "SSH key verified for $SSH_USER"

	set_option() {
		local key="$1"
		local value="$2"

		run_cmd "sed -i -E 's|^[#[:space:]]*${key}[[:space:]]+.*|${key} ${value}|'  $SSH_CONFIG"

		if ! grep -q -E "^${key}[[:space:]]+" "$SSH_CONFIG"; then
			run_cmd "echo '${key} ${value}' >> $SSH_CONFIG"
		fi
	}

	set_option PermitRootLogin no
	set_option PasswordAuthentication no
	set_option PubkeyAuthentication yes
	set_option ChallengeResponseAuthentication no
	set_option KbdInteractiveAuthentication no
	set_option X11Forwarding no
	set_option AllowTcpForwarding no
	set_option MaxAuthTries 3
	set_option LoginGraceTime 30

	if ! $DRY_RUN; then
		if ! sshd -t; then
			log "ERROR" "Invalid SSH config. Rolling back."
			cp "$BACKUP" "$SSH_CONFIG"
			exit 1
		fi
	fi

	service_reload "$SSH_CONFIG"

	log "INFO" "SSH hardened successfully."
	
	
}
