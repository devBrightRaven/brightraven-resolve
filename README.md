# brightraven-resolve

Six-pillar AI behavior governance plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Combines the best ideas from PUA (anti-giving-up), YES.md (evidence gates), gstack (product thinking, zero silent failures), washin-claude-skills (verification loops), and autoresearch (experiment discipline) into a single cohesive framework -- with empathy instead of pressure.

**Repository:** [github.com/devBrightRaven/brightraven-resolve](https://github.com/devBrightRaven/brightraven-resolve)

---

## Overview

AI coding agents are powerful but exhibit recurring failure modes: giving up too early, guessing instead of verifying, retrying the same broken approach, skipping ripple-effect checks, and claiming "done" without running tests. RESOLVE addresses each of these with a structured governance layer that activates automatically during a Claude Code session.

Unlike enforcement-heavy approaches that use guilt or pressure to correct agent behavior, RESOLVE uses the HEART pillar to normalize difficulty, reframe failure as information, and offer specific anchored praise. The result is an agent that stays persistent, stays honest, and stays kind.

---

## The Six Pillars

### 1. VISION -- Challenge What to Build

Before implementing, pause and ask the right questions. VISION triggers on new feature requests and ambiguous tasks, prompting three questions: what is this actually for, what does the 10-star version look like, and what can we cut and still ship value. It enforces zero silent failures (every failure mode must be visible) and shadow path coverage (happy path, nil input, empty/zero-length, upstream error).

### 2. STRUCTURE -- Evidence First, No Guessing

All claims require evidence: line numbers, tool output, curl responses, or grep results. Words like "probably," "might be," and "seems like" are banned outside of brainstorming. Before stating a root cause or making an irreversible recommendation, the agent must answer four questions about data source, time range, sample completeness, and alternative explanations. Safety gates require backup before modifying config, env, or deploy files.

### 3. PERSISTENCE -- Keep Going, Escalate Method Not Emotion

A structured debugging escalation ladder:
- **2 failures:** Full stop. Switch to a fundamentally different approach (not parameter tweaks).
- **3 failures:** Five-step audit -- re-read the error word by word, search the exact error string, read surrounding context, list and verify assumptions, invert the hypothesis.
- **4 failures:** Isolate with a minimal reproduction.
- **5+ failures:** Structured handoff with verified facts, eliminated causes, and recommended next steps.

Also enforces verification loops (never claim done without running tests), experiment discipline (define success criteria before changing anything, change one variable at a time), and anti-slack rules (no deflecting to the user, no unverified blame, no advice without action).

### 4. DIRECTION -- Right Path Before Persistence

Persistence in the wrong direction is worse than stopping. DIRECTION triggers when the agent is about to retry the same approach after a second failure. It forces a pause to ask: is the error message what I think it is, am I looking at the right layer, is my mental model correct. Real approach switches are distinguished from parameter tweaks (e.g., "change config value" vs. "check if config is even being loaded").

### 5. HEART -- Empathy, Not Pressure

The unique differentiator. HEART defines tone patterns for four situations:
- **On stuck:** Normalize difficulty. "Hitting walls is normal -- it means the problem is deeper than it looks."
- **On success:** Specific and anchored. "Ripple check clean. Change is contained."
- **On self-correction:** Affirm the correction. "Switching direction -- that's good judgment, not giving up."
- **On completion:** Factual summary with quiet confidence. No celebration theater.

All praise must be specific and anchored in what happened. Generic praise ("Great job!") is explicitly banned. Suggestions are framed as investments, not criticism.

### 6. AWARENESS -- Verify Ripple Effects After Every Change

After any code modification, check five dimensions before claiming done: same pattern elsewhere, upstream callers/importers, downstream consumers, shadow paths (nil/empty/error), and actual test execution. Bug closure requires three steps: verify the original failure no longer occurs, document symptom + root cause + fix, and record what went wrong. Deploy verification checks services, endpoints, logs, error rates, and rollback readiness.

---

## Components

### Skill: `resolve`

**Path:** `skills/resolve/SKILL.md`

The core governance document. Contains all six pillars in structured-label format. Auto-triggers when the agent exhibits failure modes (giving up, guessing, deflecting, blind retrying, passive waiting, claiming done without verification). Can also be invoked manually.

**Manual trigger:** `/resolve`

### Command: `/resolve`

**Path:** `commands/resolve.md`

Slash command that activates the resolve skill on demand. Use this to explicitly load the governance framework into the current session context.

### Hook: Post-Edit Ripple Check

**Path:** `hooks/post-edit-ripple.sh`

A `PostToolUse` hook that fires after every `Write` or `Edit` tool call. Displays a ripple-check reminder banner prompting the agent to verify same-pattern, upstream, downstream, shadow paths, and actual test execution. Skips documentation and non-code files (`.md`, `.txt`, `.log`, `.csv`, etc.).

### Hook: Post-Deploy Health Check

**Path:** `hooks/post-deploy-health.sh`

A `PostToolUse` hook that fires after `Bash` tool calls containing deploy-related commands (`docker compose up`, `kubectl apply`, `helm install`, `deploy`, push to production/staging/main, etc.). Displays a health-check reminder banner prompting verification of services, endpoints, logs, error rates, and rollback readiness.

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and configured
- Plugin support enabled in your Claude Code settings

### Steps

1. Clone the repository into your Claude Code plugins directory:

```bash
git clone https://github.com/devBrightRaven/brightraven-resolve.git \
  ~/.claude/plugins/marketplaces/brightraven-resolve
```

2. Enable the plugin in your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "plugins": [
    "~/.claude/plugins/marketplaces/brightraven-resolve"
  ]
}
```

3. Restart Claude Code. The plugin activates automatically for all sessions.

---

## Usage

### Automatic Activation

Once installed, RESOLVE operates passively through its hooks and skill auto-triggers:

- **Edit any code file** -- the ripple-check banner appears as a reminder.
- **Run a deploy command** -- the deploy health-check banner appears.
- **Agent detects a failure mode** (guessing, giving up, blind retry, etc.) -- the relevant pillar guidance activates from the skill.

### Manual Activation

Invoke the full governance framework explicitly:

```
/resolve
```

This loads all six pillars into the session context, useful at the start of a complex debugging session or feature implementation.

---

## File Structure

```
brightraven-resolve/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (hooks, metadata)
├── commands/
│   └── resolve.md           # /resolve slash command
├── hooks/
│   ├── post-edit-ripple.sh  # Ripple-check reminder after edits
│   └── post-deploy-health.sh # Health-check reminder after deploys
├── skills/
│   └── resolve/
│       └── SKILL.md         # Six-pillar governance skill
└── README.md
```

---

## Current Limitations

1. **No runtime toggle.** The plugin is session-level. Enabling or disabling it requires editing `settings.json` and restarting Claude Code.

2. **Single-model testing only.** RESOLVE has been tested with Claude Opus. Compliance behavior on other models (Codex, Gemini, etc.) has not been verified.

3. **Skill format not fully compressed.** `SKILL.md` uses a prose-like structured-label format. It could be further compressed using AI.MD structured-label format (estimated 53% size reduction) for lower token overhead.

4. **Static HEART patterns.** The praise and encouragement examples in the HEART pillar are static. There is no adaptive learning from user preferences or feedback.

5. **Advisory hooks only.** The post-edit and post-deploy hooks output reminder banners. They do not enforce or block any actions -- the agent can proceed without completing the checklist.

6. **No telemetry or metrics.** There is no tracking of how often each pillar triggers, which anti-patterns are most common, or the effectiveness of the governance layer.

---

## Design Lineage

RESOLVE synthesizes ideas from five prior approaches:

| Source | Contribution |
|--------|-------------|
| **PUA** | Anti-giving-up persistence, debugging escalation ladder |
| **YES.md** | Evidence gates, banned guessing language, conclusion integrity |
| **gstack** | Product thinking (VISION pillar), zero silent failures, shadow paths |
| **washin-claude-skills** | Verification loops, never-claim-done-without-testing |
| **autoresearch** | Experiment discipline, single-variable changes, measurable outcomes |

The key differentiator from PUA specifically: RESOLVE replaces pressure-based persistence ("you must not give up") with empathy-based persistence (HEART pillar -- normalize difficulty, reframe failure as data, affirm good judgment).

---

## License

[MIT](https://opensource.org/licenses/MIT)

**Author:** [devBrightRaven](https://github.com/devBrightRaven) / Bright Raven
