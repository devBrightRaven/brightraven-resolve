#!/usr/bin/env bash
# post-deploy-health.sh — Remind AI to verify deployment health after deploy commands

INPUT="$1"

# Only trigger on deploy-related commands
if ! echo "$INPUT" | grep -qiE '(docker compose up|docker-compose up|docker build|deploy|push.*(production|staging|main)|kubectl apply|helm install|helm upgrade)' 2>/dev/null; then
  exit 0
fi

cat <<'EOF'

╭─── DEPLOY HEALTH CHECK ─────────────────────╮
│                                               │
│  Deployment detected. Verify before moving on:│
│                                               │
│  □ Services alive?   docker ps / kubectl pods  │
│  □ Endpoints up?     curl health endpoint      │
│  □ Logs clean?       last 20 lines, no errors  │
│  □ Error spike?      check monitoring/alerts    │
│  □ Rollback ready?   know how to revert         │
│                                               │
╰───────────────────────────────────────────────╯

EOF
