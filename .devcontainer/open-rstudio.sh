#!/usr/bin/env bash
# Opens RStudio in the user's browser once the Codespaces tunnel serves it (run by .vscode/tasks.json on folder open).
set -uo pipefail

# Only relevant inside GitHub Codespaces; local sessions use localhost:8787 directly.
[ "${CODESPACES:-}" = "true" ] || exit 0

url="https://${CODESPACE_NAME}-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

# Poll the forwarded URL until RStudio, Caddy, and the tunnel all respond:
# the first requests after boot can fail while the stack is still starting.
for _ in $(seq 1 60); do
  if curl -sf --max-time 10 -H "X-Github-Token: ${GITHUB_TOKEN:-}" -o /dev/null "${url}/"; then
    break
  fi
  sleep 2
done

if [ -n "${BROWSER:-}" ]; then
  "$BROWSER" "$url"
else
  echo "RStudio is ready: $url"
fi
