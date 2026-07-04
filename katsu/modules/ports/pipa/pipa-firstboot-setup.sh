#!/bin/sh
set -eu

TITLE="Ultramarine OS Pipa Setup"
STATE_DIR=/var/lib/pipa-firstboot
SENTINEL="$STATE_DIR/needs-setup"
LOCK_FILE="$STATE_DIR/lock"
AUTOSTART_FILE=/root/.config/autostart/pipa-firstboot-setup.desktop
DEFAULT_HOSTNAME="pipa"
DEFAULT_SHELL="/bin/bash"
PIPA_FIRSTBOOT_DM="$(cat /etc/pipa-firstboot-dm 2>/dev/null || printf '%s' gdm)"

[ -f "$SENTINEL" ] || exit 0

mkdir -p "$STATE_DIR"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

dialog_backend() {
    if command -v zenity >/dev/null 2>&1; then
        printf '%s\n' zenity
        return 0
    fi

    if command -v kdialog >/dev/null 2>&1; then
        printf '%s\n' kdialog
        return 0
    fi

    return 1
}

prompt_info() {
    message="$1"

    case "$(dialog_backend)" in
        zenity)
            zenity --info --title "$TITLE" --text "$message" >/dev/null 2>&1 || return 1
            ;;
        kdialog)
            kdialog --title "$TITLE" --msgbox "$message" >/dev/null 2>&1 || return 1
            ;;
    esac
}

prompt_error() {
    message="$1"

    case "$(dialog_backend)" in
        zenity)
            zenity --error --title "$TITLE" --text "$message" >/dev/null 2>&1 || true
            ;;
        kdialog)
            kdialog --title "$TITLE" --error "$message" >/dev/null 2>&1 || true
            ;;
    esac
}

trim_whitespace() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

prompt_required_text() {
    prompt="$1"
    default_value="${2:-}"

    while :; do
        case "$(dialog_backend)" in
            zenity)
                answer="$(zenity --entry --title "$TITLE" --text "$prompt" --entry-text "$default_value" 2>/dev/null)" || return 1
                ;;
            kdialog)
                answer="$(kdialog --title "$TITLE" --inputbox "$prompt" "$default_value" 2>/dev/null)" || return 1
                ;;
        esac
        answer="$(trim_whitespace "$answer")"
        if [ -n "$answer" ]; then
            printf '%s\n' "$answer"
            return 0
        fi
        prompt_error "This field cannot be empty."
    done
}

prompt_optional_text() {
    prompt="$1"
    default_value="${2:-}"

    case "$(dialog_backend)" in
        zenity)
            answer="$(zenity --entry --title "$TITLE" --text "$prompt" --entry-text "$default_value" 2>/dev/null)" || return 1
            ;;
        kdialog)
            answer="$(kdialog --title "$TITLE" --inputbox "$prompt" "$default_value" 2>/dev/null)" || return 1
            ;;
    esac
    trim_whitespace "$answer"
}

prompt_password() {
    prompt="$1"

    while :; do
        case "$(dialog_backend)" in
            zenity)
                password="$(zenity --entry --title "$TITLE" --text "$prompt" --hide-text 2>/dev/null)" || return 1
                ;;
            kdialog)
                password="$(kdialog --title "$TITLE" --password "$prompt" 2>/dev/null)" || return 1
                ;;
        esac
        if [ -z "$password" ]; then
            prompt_error "Password cannot be empty."
            continue
        fi

        case "$(dialog_backend)" in
            zenity)
                confirmation="$(zenity --entry --title "$TITLE" --text "Confirm the password." --hide-text 2>/dev/null)" || return 1
                ;;
            kdialog)
                confirmation="$(kdialog --title "$TITLE" --password "Confirm the password." 2>/dev/null)" || return 1
                ;;
        esac
        if [ "$password" != "$confirmation" ]; then
            prompt_error "Passwords do not match. Please try again."
            continue
        fi

        printf '%s\n' "$password"
        return 0
    done
}

valid_username() {
    printf '%s' "$1" | grep -Eq '^[a-z_][a-z0-9_-]*[$]?$'
}

valid_hostname() {
    printf '%s' "$1" | grep -Eq '^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$'
}

if ! dialog_backend >/dev/null; then
    echo "pipa-firstboot-setup: zenity or kdialog is required." >&2
    exit 1
fi

prompt_info "Welcome to Ultramarine OS for Xiaomi Pad 6.\n\nThis first-boot setup will create your user account, set the hostname, and then reboot into the normal login screen." || exit 0

while :; do
    fullname="$(prompt_optional_text 'Full name (optional):' '')" || exit 0
    username="$(prompt_required_text 'Username:' '')" || exit 0
    username="$(printf '%s' "$username" | tr '[:upper:]' '[:lower:]')"

    if ! valid_username "$username"; then
        prompt_error "Username must start with a letter or underscore and may contain lowercase letters, numbers, hyphens, or underscores."
        continue
    fi

    if id "$username" >/dev/null 2>&1; then
        prompt_error "User '$username' already exists. Choose another username."
        continue
    fi

    hostname="$(prompt_required_text 'Hostname:' "$DEFAULT_HOSTNAME")" || exit 0
    hostname="$(printf '%s' "$hostname" | tr '[:upper:]' '[:lower:]')"

    if ! valid_hostname "$hostname"; then
        prompt_error "Hostname may only contain lowercase letters, numbers, and hyphens, and it must begin and end with a letter or number."
        continue
    fi

    password="$(prompt_password "Password for $username:")" || exit 0
    break
done

if [ -n "$fullname" ]; then
    useradd -m -G wheel -s "$DEFAULT_SHELL" -c "$fullname" "$username"
else
    useradd -m -G wheel -s "$DEFAULT_SHELL" "$username"
fi

printf 'root:%s\n%s:%s\n' "$password" "$username" "$password" | chpasswd

printf '%s\n' "$hostname" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1 localhost
::1 localhost
127.0.1.1 $hostname.localdomain $hostname
HOSTS

case "$PIPA_FIRSTBOOT_DM" in
    sddm)
        rm -f /etc/sddm.conf.d/10-firstboot-autologin.conf
        ;;
    gdm)
        rm -f /etc/gdm/custom.conf.d/10-firstboot-autologin.conf
        ;;
esac
rm -f "$AUTOSTART_FILE" "$SENTINEL"

prompt_info "Setup complete.\n\nUser '$username' was created, the hostname was set to '$hostname', and the system will now reboot." || true
systemctl reboot
