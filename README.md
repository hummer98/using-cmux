**[日本語](README.ja.md)** | English

![using-cmux](banner.jpeg)

# using-cmux

A Claude Code skill package for AI-driven cmux terminal operations.

## Motivation

Claude Code's built-in `Agent` tool is convenient, but what happens inside is opaque. It's difficult to inspect sub-agent output or intervene mid-task, making debugging and quality control challenging.

**With cmux, everything is visible.** By launching sub-agents on cmux — a terminal multiplexer — you can monitor each agent's I/O in real time and intervene at any point.

The existing [hashangit/cmux-skill](https://github.com/hashangit/cmux-skill) dedicates roughly 50% of its content to browser automation, burying the most critical use case: sub-agent operations. This package restructures that content, **putting sub-agent operation patterns front and center**.

## What's Included

| Category | Description |
|----------|-------------|
| **Basic operations** | Pane splitting, workspace management, command sending, screen reading |
| **Newline rules for `send`** | The most important rule — when to use `\n` vs. `send-key return` |
| **Sub-agent launch pattern** | Full lifecycle: launch → trust detection → prompt → completion detection → result collection |
| **`read-screen` troubleshooting** | Fixes for empty/stale output, `refresh-surfaces`, etc. |
| **Notifications** | `cmux notify` (in-app) vs. `osascript` (macOS Notification Center) |
| **Status & progress** | Sidebar status and progress bar control |

## Relationship with cmux-team

![Architecture](architecture.jpeg)

- **using-cmux**: General-purpose cmux CLI operations. Covers the full lifecycle of a single sub-agent
- **cmux-team**: Multi-agent orchestration. Handles team composition, task distribution, and synchronization. Built on top of using-cmux

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- [cmux](https://cmux.dev) installed, with Claude Code running inside a cmux session

## Installation

### Option 1: Plugin (recommended)

```
/plugin marketplace add hummer98/using-cmux
/plugin install using-cmux
```

Skills, commands, and hooks are installed together.

**To update:**

```
/plugin update using-cmux
/reload-plugins
```

### Option 2: Agent Skills (skills only)

```bash
npx skills add hummer98/using-cmux
```

> Note: Commands (`/cmux`) are not included in Agent Skills distribution.

### Option 3: Manual (legacy)

```bash
git clone https://github.com/hummer98/using-cmux.git
cd using-cmux
bash install.sh
```

Installed files:

| Destination | Contents |
|-------------|----------|
| `~/.claude/skills/using-cmux/SKILL.md` | Main skill definition (auto-loaded by Claude Code) |
| `~/.claude/commands/cmux.md` | `/cmux` slash command |

### Verify Installation (manual only)

```bash
bash install.sh --check
```

### Uninstall (manual only)

```bash
bash install.sh --uninstall
```

## Usage

### Auto-trigger

When Claude Code starts inside a cmux session, it detects the `CMUX_SOCKET_PATH` environment variable and automatically loads the skill. No manual setup required.

When Claude Code receives cmux-related instructions, it follows the patterns in SKILL.md to perform pane splitting, command sending, sub-agent launching, and more.

### `/cmux` Command

Display the quick reference:

```
/cmux
```

Useful for quickly checking available commands and basic usage.

## License

[MIT](LICENSE)
