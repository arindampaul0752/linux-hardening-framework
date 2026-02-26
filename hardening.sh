#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE ="/var/log/linux-hardening.log"

DRY_RUN=false
ONLY_MODULE=""

log() {
	local level="$1"
	local message="$2"
	echo "[$level] $message"
	echo "$(date '+%F %T') [$level] $message" >> "$LOG_FILE"
}

run_cmd() {
	if $DRY_RUN; then
		log "DRY-RUN" "$*"
	else
		"$@"
	fi
}

check_root() {
	if [[ "$EUID" -ne 0 ]]; then
		echo "Run as root."
		exit 1
	fi
}

usage() {
	echo "Usage: $0 [--dry-run] [--only ssh|fail2ban]"
	exit 0
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--dry-run)
			DRY_RUN=true
			shift
			;;
		--only)
			ONLY_MODULE="$2"
			shift 2
			;;
		*)
			usage
			;;
	esac
done

detect_environment() {
	if command -v apt >/dev/null 2>&1; then
		PKG_MANAGER="apt"
	elif command -v dnf >/dev/null 2>&1; then
		PKG_MANAGER="dnf"
	elif command -v yum >/dev/null 2>&1; then
		PKG_MANAGER="yum"
	elif command -v pacman >/dev/null 2>&1; then
		PKG_MANAGER="pacman"
	else
		log "ERROR" "Unsupported package manager."
		exit 1
	fi

	if ! command -v systemctl >/dev/null 2>&1; then
		log "ERROR" "systemd required."
		exit 1
	fi

	if systemctl list-units-files | grep -q '^sshd.service'; then
		SSH_SERVICE="sshd"
	elif systemctl list-units-files | grep -q '^ssh.service'; then
		SSH_SERVICE="ssh"
	else
		log "ERROR" "SSH service not found."
		exit 1
	fi

	log "INFO" "Package manager: $PKG_MANAGER"
	log "INFO" "SSH service: $SSH_SERVICE" 
	
}

install_package() {
	case "$PKG_MANAGER" in
		apt)
			apt update -y
			apt install -y "$1"
		dnf)
			dnf install -y "$1"
			;;
		yum)
			yum install -y "$1"
			;;
		pacman)
			pacamn -Sy --noconfirm "$1"
			;;
	esac
}

service_enable() {
	run_cmd "systemctl enable $1"
}

service_reload() {
	run_cmd "systemctl reload $1 2>/dev/null || systemctl restart $1"
}

source "$BASE_DIR/modules/ssh_hardening.sh"
source "$BASE_DIR/modules/fail2ban.sh"

main() {
	check_root
	detect_environment

	log "INFO" "Starting Linux Hardening"

	if [[ -z "$ONLY_MODULE" || "$ONLY_MODULE" == "ssh" ]]; then
		harden_ssh
	fi

	if [[ -z "$ONLY_MODULE" || "$ONLY_MODULE" == "fail2ban" ]]; then
		setup_fail2ban
	fi

	log "SUCCESS" "Hardening complete."
}

main
