# `killsession` – Detailed Failure Analysis

## Goal
Close **one specific** Termux GUI session by number (e.g. `killsession 3`)

## Implementation
    ps -ef | awk -v p="$pts" '/data\/data\/com\.termux.*(zsh|bash)/ && $8 ~ "pts/" p "($|[^0-9])" && !/awk/ {print $2; exit}'
    kill "$pid"

## What Actually Happened
- Correct PID was found and killed
- Shell process terminated
- **Tab remained open**
- User could still swipe to it
- No error, but no visual change

## Root Cause
> **Termux GUI sessions are managed by the Java layer, not the shell.**

Killing the shell sends a signal, but:
- The Android `Activity` holding the terminal view is **not notified**
- No `finish()` is called on the tab
- Tab persists until manual swipe or app restart

## Evidence
    $ killallbutme
    Killed PID 12384
    $ # Swipe left → Session 3 still there

## References
- [Termux-app source: TerminalSession.java](https://github.com/termux/termux-app/blob/master/app/src/main/java/com/termux/terminal/TerminalSession.java) – No `onProcessExit` → close tab
- [Android Activity Lifecycle](https://developer.android.com/guide/components/activities/activity-lifecycle) – Shell death ≠ Activity death

