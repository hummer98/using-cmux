# Privacy Policy

_Last updated: 2026-04-28_

## Overview

`using-cmux` is a Claude Code plugin consisting of skill markdown files and
POSIX shell wrappers around the [`cmux`](https://cmux.dev) CLI. This document
describes how the plugin handles user data.

## Data Collection

This plugin does **not** collect, store, or transmit any user data.

- No analytics
- No telemetry
- No third-party services
- No network access of its own

## How the Plugin Works

The plugin runs entirely on the user's local machine. It executes shell
commands such as `cmux send`, `cmux read-screen`, and `cmux send-key` to
operate cmux terminal sessions. No data leaves the user's machine as a result
of using this plugin.

## Interaction with Claude Code

When users invoke this plugin's skills or commands inside Claude Code, the
user's prompts and tool results flow through Claude Code itself. That data is
governed by [Anthropic's privacy policy](https://www.anthropic.com/legal/privacy),
not by this plugin. The plugin is merely a passive set of instructions and
shell scripts that Claude Code reads and executes.

## Source Code

The plugin's source is publicly available at
<https://github.com/hummer98/using-cmux> under the MIT License (see
[LICENSE](LICENSE)). Users are encouraged to inspect the scripts in `bin/` and
the skill files in `skills/` to verify the behavior described above.

## Contact

For privacy-related inquiries, contact:

- yuji.yamamoto@tayorie.jp

## License

This plugin is distributed under the MIT License. See [LICENSE](LICENSE) for
details.
