# Termux Session Killer – Project Overview

## Status: **Failed / Archived**

This repository (`termux-tools`) was created to build CLI tools that could:
- Close a specific Termux GUI session (swipe-left tab) by number
- Close all sessions except the current one

**Result**: Both goals are **impossible via CLI** in Termux as of November 2025.

---

## What Was Built
- `build_killsession.sh` → installer for `killsession <n>`
- `build_killallbutme.sh` → installer for `killallbutme [-y]`

Both:
- Used `ps -ef` + `awk` to find shell PIDs
- Used `kill` to terminate processes
- Were idempotent and self-documenting

---

## Why It Failed
> **Termux does not close GUI tabs when the shell process dies.**

Even if the root shell (zsh/bash) is killed:
- The tab remains in the swipe menu
- The user can still navigate into it
- It becomes a "zombie" session

This is **by design** in Termux.

---

## References
- [Termux GitHub Issue #1392](https://github.com/termux/termux-app/issues/1392) – "Killing shell doesn't close tab"
- [Termux Wiki – Sessions](https://wiki.termux.com/wiki/Sessions) – No mention of CLI close
- [Reddit r/termux – "How to close session from CLI?"](https://www.reddit.com/r/termux/comments/10k3j2d/how_to_close_a_session_from_cli/) – Consensus: impossible

