# Linux Hardening Framework

A modular Bash-based Linux hardening framework designed to secure SSH access and mitigate brute-force attacks among major Linux distributions.

This project focuses on safe automation, portability, and production-aware practices.

---

## Features

- Modular architecture
- SSH hardening with safety checks
- Fail2Ban installation and configuration
- Recidive jail for repeat attacker mitigation
- Distro-aware package detection
- systemd service abstraction
- Configuration backup and rollback
- Dry-run mode
- Selective module execution
- Logging to `/var/log/linux-hardening.log`

---

## Supported Distributions

Tested and designed for systemd-based systems:

- Ubuntu / Debian
- Kali Linux
- RHEL / CentOS / Rocky / AlmaLinux
- Fedora
- Arch Linux

The framework automatically detects:

- Package manager (`apt`, `dnf`, `yum`, `pacman`)
- SSH service name (`ssh`or `sshd`)
- systemd availability

---

## Project Structure

```
linux-hardening/
├ hardening.sh
|
├ modules/
|	├ ssh_hardening.sh
|	├ fail2ban.sh
|
├ README.md

```
---

## What it does

### SSH hardening

- Disables root login
- Disables password authentication
- Enforces  public key authentication
- Limits authentication attempts
- Reduces login grace time
- Disables X11 and TCP forwarding
- Validates configuration before reload
- Prevents lockout by verifying SSH key presence
- Automatically rolls back if config validation fails


### Fail2Ban Protection

- Installs Fail2Ban if missing
- Configures SSH jail
- Enables progressive ban logic
- Enables recidive jail for repeat offenders
- Automatically enables and reloads service

Recidive Jail Settings:

- Detects repeated bans within 24 hours
- Applies extended ban (7 days)

---

## Usage

Run as root:

```bash
sudo ./hardening.sh

```
Dry-run mode (no changes applied):

```bash
sudo ./hardening.sh --dry-run

```
Run only SSH hardening:

```bash
sudo ./hardening.sh --only ssh

```
Run only Fail2Ban setup:

```bash
sudo ./hardening.sh --only fail2ban

```

## Safety Design

This framework includes:

- Root execution enforcement 
- Automatic configuration verification
- SSH key existence verification
- SSH config validation (sshd -t) before reload
- Rollback on invalid configuration
- Controlled service reload abstraction

The goal is to reduce the risk of accidental lockout during hardening.

## Logging

All operations are logged to:

```
/var/log/linux-hardening.log

```

## Limitations

- Requires systemd
- Designed for server environments
- Does not include firewall automation (yet)
- Not a replacement for full CIS benchmark compliance

### Future Enhancements

- Firewall abstraction (UFW / firewalld)
- CIS benchmark flags
- Rate limiting via sshd
- Ansible role conversion
- Cl-based automated testing

## Author

Arindam Paul
B.Sc Cyber Security

Focused on Linux security automation and system hardening.

