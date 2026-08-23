#!/usr/bin/env bash
set -Eeuo pipefail

PRODUCT_REPO="NevynIt/AgentBoxV3"
RUNTIME_DIR="${AGENTBOX_RUNTIME_DIR:-$HOME/agentbox-runtime}"
TTY_DEVICE="/dev/tty"

say() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Linux" ] || die "AgentBox V3 must be installed from inside the target Linux environment."
[ -r /etc/os-release ] || die "Unable to identify this Linux distribution."
# shellcheck disable=SC1091
. /etc/os-release
case "${ID:-}:${ID_LIKE:-}" in
    ubuntu:*|debian:*|*:debian*) ;;
    *) die "The bootstrap currently supports Ubuntu/Debian-family hosts. For native hardware, use Ubuntu just as you would inside Multipass or WSL2." ;;
esac

if [ ! -r "$TTY_DEVICE" ]; then
    die "An interactive terminal is required for sudo/GitHub authentication. Run the bootstrap from a normal Linux terminal."
fi

SUDO=()
need_admin() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=()
        return
    fi
    command -v sudo >/dev/null 2>&1 || die "sudo is required to install missing host packages."
    say
    say "AgentBox may need operating-system administrator rights to install host prerequisites."
    say "If sudo asks for a password, enter your Linux user password directly at the sudo prompt."
    say "AgentBox does not receive or store that password."
    sudo -v <"$TTY_DEVICE"
    SUDO=(sudo)
}

missing=()
for command in git gh; do
    command -v "$command" >/dev/null 2>&1 || missing+=("$command")
done

if [ "${#missing[@]}" -gt 0 ]; then
    need_admin
    say "Installing public-bootstrap prerequisites: ${missing[*]}"
    "${SUDO[@]}" apt-get update
    DEBIAN_FRONTEND=noninteractive "${SUDO[@]}" apt-get install -y ca-certificates curl git gh
fi

say
say "AgentBox V3 is currently private, so this Linux user must authenticate to GitHub."
if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    gh auth login --hostname github.com --git-protocol https --web --scopes repo <"$TTY_DEVICE"
fi

gh auth setup-git --hostname github.com
gh auth status --hostname github.com

gh repo view "$PRODUCT_REPO" >/dev/null 2>&1 || \
    die "The authenticated GitHub identity cannot access $PRODUCT_REPO."

if [ -e "$RUNTIME_DIR" ]; then
    [ -d "$RUNTIME_DIR/.git" ] || die "$RUNTIME_DIR already exists but is not a Git checkout."
    remote="$(git -C "$RUNTIME_DIR" remote get-url origin 2>/dev/null || true)"
    case "$remote" in
        *NevynIt/AgentBoxV3.git|*NevynIt/AgentBoxV3) ;;
        *) die "$RUNTIME_DIR exists but origin is not $PRODUCT_REPO." ;;
    esac
    [ -z "$(git -C "$RUNTIME_DIR" status --porcelain)" ] || \
        die "$RUNTIME_DIR contains local changes. Refusing to overwrite the installed Product checkout."
    git -C "$RUNTIME_DIR" switch main
    GIT_TERMINAL_PROMPT=0 git -C "$RUNTIME_DIR" fetch origin main
    git -C "$RUNTIME_DIR" merge --ff-only origin/main
else
    GIT_TERMINAL_PROMPT=0 git clone --branch main --single-branch \
        "https://github.com/$PRODUCT_REPO.git" "$RUNTIME_DIR"
fi

[ -f "$RUNTIME_DIR/install.sh" ] || \
    die "Current $PRODUCT_REPO/main does not contain the Product-owned installer."

say
say "Public bootstrap complete. Handing control to the Product-owned AgentBox installer."
exec bash "$RUNTIME_DIR/install.sh" "$@" <"$TTY_DEVICE"
