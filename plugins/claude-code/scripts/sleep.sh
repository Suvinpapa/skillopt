#!/usr/bin/env bash
# Claude Code plugin runner — SELF-CONTAINED.
#
# The plugin is installed as just the plugins/claude-code subdir, so the shared
# <repo>/plugins/run-sleep.sh is NOT bundled with it. This launcher therefore
# resolves the engine on its own: it finds a Python >= 3.10 and the skillopt_sleep
# package (via SKILLOPT_SLEEP_REPO, a colocated checkout, an upward CWD search,
# or a pip-installed package) and execs the engine CLI. No external file needed.
set -euo pipefail

# If the shared runner happens to be present (in-repo dev), defer to it.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for cand in "$HERE/../../run-sleep.sh" \
            "${CLAUDE_PLUGIN_ROOT:-/nonexistent}/../run-sleep.sh"; do
  if [ -f "$cand" ]; then exec bash "$cand" "$@"; fi
done

# ── pick a Python >= 3.10 (include bare `python`; Windows git-bash has no python3) ──
PY=""
for c in python3.13 python3.12 python3.11 python3.10 python3 python; do
  if command -v "$c" >/dev/null 2>&1; then
    ver="$("$c" -c 'import sys; print("%d%d" % sys.version_info[:2])' 2>/dev/null || echo 0)"
    if [ "${ver:-0}" -ge 310 ]; then PY="$c"; break; fi
  fi
done
if [ -z "$PY" ]; then
  echo "[sleep] ERROR: need Python >= 3.10 (found none on PATH)." >&2
  exit 1
fi

# ── locate the skillopt_sleep package (a dir that CONTAINS skillopt_sleep/) ──
REPO_ROOT=""
if [ -n "${SKILLOPT_SLEEP_REPO:-}" ] && [ -d "$SKILLOPT_SLEEP_REPO/skillopt_sleep" ]; then
  REPO_ROOT="$SKILLOPT_SLEEP_REPO"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "$CLAUDE_PLUGIN_ROOT/../../skillopt_sleep" ]; then
  REPO_ROOT="$(cd "$CLAUDE_PLUGIN_ROOT/../.." && pwd)"
else
  d="$PWD"
  while [ "$d" != "/" ] && [ -n "$d" ]; do
    if [ -d "$d/skillopt_sleep" ]; then REPO_ROOT="$d"; break; fi
    d="$(dirname "$d")"
  done
fi

if [ "$#" -eq 0 ]; then set -- status; fi

# If we found the package directory, cd into it so `-m skillopt_sleep` resolves
# even without a pip install. Otherwise rely on a pip-installed package.
if [ -n "$REPO_ROOT" ]; then
  cd "$REPO_ROOT"
elif ! "$PY" -c 'import skillopt_sleep' >/dev/null 2>&1; then
  echo "[sleep] ERROR: could not locate the skillopt_sleep package." >&2
  echo "        Set SKILLOPT_SLEEP_REPO to your SkillOpt checkout, or 'pip install -e .' it." >&2
  exit 1
fi

exec "$PY" -m skillopt_sleep "$@"
