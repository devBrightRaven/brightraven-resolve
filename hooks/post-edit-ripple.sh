#!/usr/bin/env bash
# post-edit-ripple.sh — Remind AI to run ripple check after file edits
# Skips documentation-only files

INPUT="$1"

# Extract file path from tool input
FILE=""
FILE=$(echo "$INPUT" | sed -n 's/.*"file_path"\s*:\s*"\([^"]*\)".*/\1/p' 2>/dev/null)

# Skip documentation and non-code files
if [[ "$FILE" =~ \.(md|txt|log|json\.bak|bak|csv)$ ]]; then
  exit 0
fi

# Skip if file path is empty
if [[ -z "$FILE" ]]; then
  exit 0
fi

cat <<'EOF'

╭─── RIPPLE CHECK ─────────────────────────────╮
│                                               │
│  Before saying "done", verify:                │
│                                               │
│  □ Same pattern?     grep for similar code    │
│  □ Upstream?         who calls / imports this  │
│  □ Downstream?       what does this feed into  │
│  □ Shadow paths?     nil / empty / error case  │
│  □ Actually tested?  run it, don't eyeball it  │
│                                               │
╰───────────────────────────────────────────────╯

EOF
