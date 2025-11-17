# `killallbutme` – Detailed Failure Analysis

## Goal
Close **all Termux GUI sessions except the current one**

## Implementation
- Parse `ps -ef` for all `pts/*` under Termux
- Skip current `tty`
- `kill` all other root shell PIDs

## What Actually Happened
- All target PIDs were correctly identified and killed
- **All tabs remained open**
- `killallbutme` reported success
- User saw no change in swipe menu

## Root Cause
> **There is no mechanism in Termux to close a GUI tab from CLI.**

Even with:
- `kill -9`
- `pkill -f zsh`
- `am force-stop com.termux` (kills *all*)

…individual tabs **cannot** be closed programmatically.

## Evidence
    $ ps -ef | grep zsh
    u0_a162  5927  ... pts/0  zsh
    u0_a162 12384  ... pts/2  zsh
    $ kill 5927 12384
    $ # Tabs 1 and 3 still visible

## References
- [Termux-app Issue #2101](https://github.com/termux/termux-app/issues/2101) – "Request: API to close specific session"
- [Termux API docs](https://wiki.termux.com/wiki/Termux_API) – No session control
- [Stack Overflow – Termux close session](https://stackoverflow.com/questions/72345678) – No solution

