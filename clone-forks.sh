#!/usr/bin/env bash
# clone-forks.sh
# Clone all forks of Somos-Viva/desafios-tecnicos into forks-YYYYmmdd-HHMMSS
# with reporting, logging, optional pulling of existing clones, and HTTPS/SSH choice.
#
# Dependencies: bash (>=4), curl, jq, git
# Optional auth (to avoid rate limits):
#   - GitHub CLI (`gh`) logged in: `gh auth login`
#   - .env with GITHUB_TOKEN=... (classic token; scope: public_repo)
#   - GITHUB_TOKEN exported in your shell
#
# Usage:
#   ./clone-forks.sh [--pull-existing] [--https]

set -euo pipefail

# ---------- config ----------
OWNER="Somos-Viva"
REPO="desafios-tecnicos"
API="https://api.github.com/repos/$OWNER/$REPO/forks"
UA="forks-cloner/1.3"

# ---------- help function ----------
show_help() {
  cat << EOF
clone-forks.sh - Clone all forks of a GitHub repository

Usage:
  ./clone-forks.sh [OPTIONS]

Options:
  --pull-existing    Pull latest changes for existing clones instead of skipping
  --https            Prefer HTTPS URLs over SSH for cloning
  --help             Show this help message and exit

Description:
  This script clones all forks of $OWNER/$REPO into a timestamped directory.
  Each fork directory contains shortcut files (REPO_URL.txt, .url, .webloc).
  Detailed reports are generated showing cloned, skipped, and pulled repositories.

Authentication:
  For higher rate limits, use one of these authentication methods:
  - GitHub CLI (gh auth login)
  - GITHUB_TOKEN environment variable
  - .env file with GITHUB_TOKEN=your_token

Environment:
  The script loads environment variables from a .env file if present.

Reports:
  - found-forks.tsv: All forks discovered with their URLs
  - cloned.tsv: Successfully cloned repositories
  - skipped-existing.tsv: Existing directories that were skipped
  - pulled.tsv: Existing directories that were updated with git pull

EOF
}

# Make git/ssh fully non-interactive (no password/hostkey prompts blocking the loop)
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new'

# ---------- parse flags (FIX: no bogus empty arg) ----------
PULL_EXISTING=0
PREFER_HTTPS=0
SHOW_HELP=0
if [[ $# -gt 0 ]]; then
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pull-existing) PULL_EXISTING=1; shift ;;
      --https)         PREFER_HTTPS=1; shift ;;
      --help)          SHOW_HELP=1; shift ;;
      *) echo "Unknown option: $1" >&2; echo "Use --help for usage information" >&2; exit 2 ;;
    esac
  done
fi

# Show help and exit if requested
if [[ $SHOW_HELP -eq 1 ]]; then
  show_help
  exit 0
fi

# ---------- .env loader (KEY=VALUE, ignores comments/blank lines) ----------
if [[ -f ".env" ]]; then
  echo "Loading environment from .env"
  while IFS='=' read -r key value; do
    [[ -z "${key}" || "${key}" =~ ^\s*# ]] && continue
    value="${value%\"}"; value="${value#\"}"
    value="${value%\'}"; value="${value#\'}"
    export "${key}"="${value}"
  done < .env
fi

# ---------- self-checks ----------
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need curl; need jq; need git

# Prefer gh's stored token; fallback to env var; else unauthenticated
if command -v gh >/dev/null 2>&1; then
  TOKEN="$(gh auth token 2>/dev/null || true)"
else
  TOKEN="${GITHUB_TOKEN:-}"
fi

STAMP=$(date +"%Y%m%d-%H%M%S")
TARGET_DIR="forks-$STAMP"
mkdir -p "$TARGET_DIR"

LOG="$TARGET_DIR/clone-forks.log"
timestamp_tee() {
    while IFS= read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
    done | tee -a "$LOG"
}
exec > >(timestamp_tee) 2>&1

auth_header=()
if [[ -n "${TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: token $TOKEN")
else
  echo "Note: No token found (gh/GITHUB_TOKEN). You may hit rate limits."
fi

# ---------- helpers ----------
xml_escape() {
  local s="$1"
  s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"
  s="${s//\"/&quot;}"; s="${s//\'/&apos;}"
  printf '%s' "$s"
}

write_shortcuts() {
  local dest="$1" repo_link="$2"
  printf '%s\n' "$repo_link" > "$dest/REPO_URL.txt"
  cat > "$dest/REPO_URL.url" <<EOF
[InternetShortcut]
URL=$repo_link
IconFile=$repo_link/favicon.ico
IconIndex=1
EOF
  local esc_link; esc_link="$(xml_escape "$repo_link")"
  cat > "$dest/REPO_URL.webloc" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>URL</key>
    <string>$esc_link</string>
  </dict>
</plist>
EOF
}

choose_url() {
  local ssh_url="$1" https_url="$2"
  if [[ "$PREFER_HTTPS" -eq 1 ]]; then
    [[ -n "$https_url" ]] && { echo "$https_url"; return; }
    echo "$ssh_url"
  else
    [[ -n "$ssh_url" ]] && { echo "$ssh_url"; return; }
    echo "$https_url"
  fi
}

# ---------- gather all forks (handle pagination) ----------
echo "==> Fetching forks from $API"
page=1
ALL_FORKS_JSON="[]"
while :; do
  RESP=$(curl -sS "${auth_header[@]}" \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: $UA" \
    "$API?per_page=100&page=$page") || { echo "curl failed"; exit 1; }

  TYPE=$(jq -r 'type' <<<"$RESP" 2>/dev/null || echo "invalid")
  if [[ "$TYPE" != "array" ]]; then
    echo "GitHub API did not return an array; response was:"
    echo "$RESP"
    exit 1
  fi

  COUNT=$(jq 'length' <<<"$RESP")
  [[ "$COUNT" -eq 0 ]] && break

  ALL_FORKS_JSON=$(jq -s '.[0] + .[1]' <<<"$ALL_FORKS_JSON"$'\n'"$RESP")
  ((page++))
done

TOTAL_FOUND=$(jq 'length' <<<"$ALL_FORKS_JSON")
echo "==> Total forks found: $TOTAL_FOUND"

# ---------- preflight reporting ----------
FOUND_TSV="$TARGET_DIR/found-forks.tsv"
echo -e "login\trepo\tchosen_clone_url\tssh_url\thttps_url" > "$FOUND_TSV"
jq -r '.[] | [.owner.login, .name, .ssh_url, .clone_url] | @tsv' <<<"$ALL_FORKS_JSON" |
while IFS=$'\t' read -r login name ssh_url https_url; do
  chosen="$(choose_url "$ssh_url" "$https_url")"
  echo -e "${login}\t${name}\t${chosen}\t${ssh_url}\t${https_url}" >> "$FOUND_TSV"
done
echo "==> Preflight list saved: $FOUND_TSV"
echo "Target directory: $TARGET_DIR"
echo

# ---------- clone / pull with reporting ----------
# Create temporary file with fork data
TEMP_FILE=$(mktemp 2>/dev/null || mktemp -t 'forklist')
trap '[[ -n "${TEMP_FILE:-}" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"' EXIT
jq -r '.[] | [.owner.login, .name, .ssh_url, .clone_url] | @tsv' <<<"$ALL_FORKS_JSON" > "$TEMP_FILE"

# Initialize report files
touch "$TARGET_DIR/cloned.tsv" "$TARGET_DIR/skipped-existing.tsv" "$TARGET_DIR/pulled.tsv"
CLONED=0; SKIPPED=0; PULLED=0

# Process each fork
while IFS=$'\t' read -r login name ssh_url https_url; do
    [[ -z "$login" || -z "$name" ]] && continue
    url="$(choose_url "$ssh_url" "$https_url")"
    dest="$TARGET_DIR/${login}-${name}"
    repo_link="https://github.com/${login}/${name}"

    if [[ -d "$dest/.git" ]]; then
        echo "Already exists: $dest"
        write_shortcuts "$dest" "$repo_link"
        if [[ "$PULL_EXISTING" -eq 1 ]]; then
            echo "Pulling latest in $dest"
            if git -C "$dest" pull --ff-only < /dev/null; then
                echo -e "${login}\t${name}\tpulled" >> "$TARGET_DIR/pulled.tsv"
                ((PULLED++))
            else
                echo "WARN: git pull failed in $dest"
            fi
        else
            echo -e "${login}\t${name}\tskipped-existing" >> "$TARGET_DIR/skipped-existing.tsv"
            ((SKIPPED++))
        fi
        continue
    fi

    echo "Cloning $url -> $dest"
    if git clone --quiet "$url" "$dest" < /dev/null; then
        write_shortcuts "$dest" "$repo_link"
        echo -e "${login}\t${name}\tcloned\t${url}" >> "$TARGET_DIR/cloned.tsv"
        # Bash weirdness:
        # This terminates the code if CLONED is initialized to zero.
        # The expression returns the value before update,
        # M]making set -euo pipefail trigger a stop.
        # ((CLONED++))
        ((CLONED=CLONED+1))
    else
        echo "WARN: Failed to clone $url"
    fi
done < "$TEMP_FILE"

## Clean up temporary file
rm -f "$TEMP_FILE"
# trap is doing it too

# ---------- summary ----------
echo
echo "========== Summary =========="
echo "Found forks:   $TOTAL_FOUND"
echo "Cloned:        $CLONED         (details: $TARGET_DIR/cloned.tsv)"
echo "Skipped exist: $SKIPPED        (details: $TARGET_DIR/skipped-existing.tsv)"
echo "Pulled:        $PULLED         (details: $TARGET_DIR/pulled.tsv)"
echo "Log file:      $LOG"
echo "============================="
echo "Each fork dir contains: REPO_URL.txt, REPO_URL.url, REPO_URL.webloc"
