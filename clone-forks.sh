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
OMIT_TIMESTAMP=0
USER_TARGET_DIR=""

# ---------- .env loader (KEY=VALUE, ignores comments/blank lines) ----------
# This script checks if a .env file exists in the current directory.
# If it does, it loads environment variables from the .env file.
# For each non-empty, non-comment line in .env:
#   - It splits the line into a key and value at the '=' character.
#   - It strips surrounding single or double quotes from the value.
#   - It exports the key-value pair as an environment variable.
if [[ -f ".env" ]]; then
  echo "Loading environment from .env"
  while IFS='=' read -r key value; do
    [[ -z "${key}" || "${key}" =~ ^\s*# ]] && continue
    value="${value%\"}"; value="${value#\"}"
    value="${value%\'}"; value="${value#\'}"
    export "${key}"="${value}"
  done < .env
fi

# Parses command-line options for the clone-forks.sh script.
# Supported options:
#   --pull-existing    : If specified, enables pulling updates for existing repositories.
#   --https            : If specified, prefers cloning repositories using HTTPS instead of SSH.
#   --help             : If specified, displays usage information.
#   --omit-timestamp   : If specified, omits timestamps from output or logs.
#   --target-dir <dir> : Specifies the target directory for cloning repositories. Requires a directory argument.
# Any unknown option will result in an error message and script termination.
if [[ $# -gt 0 ]]; then
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pull-existing) PULL_EXISTING=1; shift ;;
      --https)         PREFER_HTTPS=1; shift ;;
      --help)          SHOW_HELP=1; shift ;;
      --omit-timestamp) OMIT_TIMESTAMP=1; shift ;;
      --target-dir)
        if [[ -n "${2:-}" && ! "${2:-}" =~ ^-- ]]; then
          USER_TARGET_DIR="$2"; shift 2;
        else
          echo "Error: --target-dir requires a directory argument" >&2; exit 2;
        fi
        ;;
      *) echo "Unknown option: $1" >&2; echo "Use --help for usage information" >&2; exit 2 ;;
    esac
  done
fi

# Show help and exit if requested
if [[ $SHOW_HELP -eq 1 ]]; then
  show_help
  exit 0
fi

# ---------- self-checks ----------
need() {
  local missing=()
  for dep in "$@"; do
    command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing dependencies: ${missing[*]}" >&2
    exit 1
  fi
}
need curl jq git

# ---------- soft dependency: gh ----------
USABLE_GH=0
TOKEN="${GITHUB_TOKEN:-}"
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    USABLE_GH=1
    # Prefer gh's stored token if USABLE_GH=1; fallback to env var; else unauthenticated
    TOKEN="$(gh auth token 2>/dev/null || true)"
  fi
fi


# Determine TARGET_DIR based on switches
if [[ -n "$USER_TARGET_DIR" ]]; then
  TARGET_DIR="$USER_TARGET_DIR"
elif [[ $OMIT_TIMESTAMP -eq 1 ]]; then
  TARGET_DIR="forks"
else
  STAMP=$(date +"%Y%m%d-%H%M%S")
  TARGET_DIR="forks-$STAMP"
fi
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

: '
repository_clone() - Clone a GitHub repository using either the GitHub CLI (gh) or git.

Arguments:
  $1 - repo_link: The repository identifier for gh (e.g., "owner/repo").
  $2 - url: The full HTTPS or SSH URL to the repository (for git clone).
  $3 - dest: The destination directory to clone the repository into.

Behavior:
  - If the global variable USABLE_GH is set to 1, attempts to clone using "gh repo clone".
    - On success, prints "success:gh:<output>" and returns 0.
    - On failure, falls back to "git clone".
      - On success, prints "success:git:<output>" and returns 0.
      - On failure, prints "fail:both:<gh_output> | <git_output>" and returns 1.
  - If USABLE_GH is not 1, attempts to clone using "git clone" only.
    - On success, prints "success:git:<output>" and returns 0.
    - On failure, prints "fail:git:<output>" and returns 1.

All command output is captured and printed as part of the status message.
'
repository_clone() {
  local repo_link="$1" url="$2" dest="$3" out status
  if [[ "$USABLE_GH" -eq 1 ]]; then
    out=$(gh repo clone "$repo_link" "$dest" -- --quiet < /dev/null 2>&1)
    status=$?
    if [[ $status -eq 0 ]]; then
      echo "success:gh:$out"
      return 0
    else
      # Try fallback to git clone
      out2=$(git clone --quiet "$url" "$dest" < /dev/null 2>&1)
      status2=$?
      if [[ $status2 -eq 0 ]]; then
        echo "success:git:$out2"
        return 0
      else
        echo "fail:both:$out | $out2"
        return 1
      fi
    fi
  else
    out=$(git clone --quiet "$url" "$dest" < /dev/null 2>&1)
    status=$?
    if [[ $status -eq 0 ]]; then
      echo "success:git:$out"
      return 0
    else
      echo "fail:git:$out"
      return 1
    fi
  fi
}

# repo_sync
# -----------
# Synchronizes a local git repository with its remote counterpart.
#
# Arguments:
#   $1 - The repository link (for use with GitHub CLI).
#   $2 - The destination directory of the local repository.
#
# Behavior:
#   - If the environment variable USABLE_GH is set to 1, attempts to sync using GitHub CLI (`gh repo sync`).
#   - Otherwise, falls back to using `git pull --ff-only` in the specified directory.
#
# Output:
#   - On success, prints "success:gh:<output>" or "success:git:<output>" depending on the method used.
#   - On failure, prints "fail:gh:<output>" or "fail:git:<output>".
#
# Returns:
#   0 on success, 1 on failure.
repo_sync() {
  local repo_link="$1" dest="$2" status out
  if [[ "$USABLE_GH" -eq 1 ]]; then
    out=$(gh repo sync "$repo_link" -- -C "$dest" < /dev/null 2>&1)
    status=$?
    if [[ $status -eq 0 ]]; then
      echo "success:gh:$out"
      return 0
    else
      echo "fail:gh:$out"
      return 1
    fi
  else
    out=$(git -C "$dest" pull --ff-only < /dev/null 2>&1)
    status=$?
    if [[ $status -eq 0 ]]; then
      echo "success:git:$out"
      return 0
    else
      echo "fail:git:$out"
      return 1
    fi
  fi
}

# Escapes special characters in a string for XML.
# Replaces &, <, >, ", and ' with their corresponding XML entities.
# Usage: xml_escape "string"
# Example: xml_escape "5 < 6 & 7 > 3" outputs "5 &lt; 6 &amp; 7 &gt; 3"
xml_escape() {
  local s="$1"
  s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"
  s="${s//\"/&quot;}"; s="${s//\'/&apos;}"
  printf '%s' "$s"
}

# write_shortcuts
# ---------------
# Creates shortcut files pointing to a given repository URL in the specified destination directory.
#
# Arguments:
#   $1 - dest: The destination directory where the shortcut files will be created.
#   $2 - repo_link: The repository URL to be saved in the shortcut files.
#
# Behavior:
#   - Writes the repository URL to a plain text file named REPO_URL.txt.
#   - Creates a Windows Internet Shortcut (.url) file named REPO_URL.url with the repository URL and an icon reference.
#   - Creates a macOS Webloc (.webloc) file named REPO_URL.webloc containing the repository URL in XML plist format.
#   - Uses xml_escape to properly escape the URL for XML.
#
# Requirements:
#   - The function xml_escape must be defined elsewhere in the script for proper XML escaping.
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

# choose_url: Selects and echoes either the SSH or HTTPS URL based on user preference.
# Arguments:
#   $1 - SSH URL string.
#   $2 - HTTPS URL string.
# Behavior:
#   If the environment variable PREFER_HTTPS is set to 1 and a non-empty HTTPS URL is provided,
#   the function echoes the HTTPS URL. Otherwise, it falls back to the SSH URL.
#   If PREFER_HTTPS is not set to 1, it prefers the SSH URL if available, otherwise falls back to HTTPS.
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
      sync_result=$(repo_sync "$repo_link" "$dest")
      sync_status=$?
      sync_type="$(cut -d: -f2 <<< "$sync_result")"
      if [[ $sync_status -eq 0 ]]; then
        if [[ "$sync_type" == "gh" ]]; then
          echo -e "${login}\t${name}\tpulled-gh" >> "$TARGET_DIR/pulled.tsv"
        else
          echo -e "${login}\t${name}\tpulled-git" >> "$TARGET_DIR/pulled.tsv"
        fi
        ((PULLED++))
      else
        echo "WARN: repo sync failed in $dest ($sync_type)"
        echo "$sync_result"
      fi
    else
      echo -e "${login}\t${name}\tskipped-existing" >> "$TARGET_DIR/skipped-existing.tsv"
      ((SKIPPED++))
    fi
    continue
  fi

  echo "Cloning $url -> $dest"
  clone_result=$(repository_clone "$repo_link" "$url" "$dest")
  clone_status=$?
  clone_type="$(cut -d: -f2 <<< "$clone_result")"
  if [[ $clone_status -eq 0 ]]; then
    write_shortcuts "$dest" "$repo_link"
    if [[ "$clone_type" == "gh" ]]; then
      echo -e "${login}\t${name}\tcloned-gh\t${url}" >> "$TARGET_DIR/cloned.tsv"
    else
      echo -e "${login}\t${name}\tcloned-git\t${url}" >> "$TARGET_DIR/cloned.tsv"
    fi
    ((CLONED=CLONED+1))
  else
    echo "WARN: Failed to clone $url ($clone_type)"
    echo "$clone_result"
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
