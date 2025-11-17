#!/data/data/com.termux/files/usr/bin/bash
# build_killallbutme.sh
# Run with: source ./build_killallbutme.sh
# Purpose: Install `killallbutme` – kill all Termux GUI sessions *except* the current one

mkdir -p ~/.config/termux/functions

cat > ~/.config/termux/functions/killallbutme.sh << 'INNER_EOF'
# ----------------------------------------------------------------------
# killallbutme – close every Termux GUI session *except* the current one
#
# Usage:
#   killallbutme          # lists sessions + asks confirmation
#   killallbutme -y        # force-kill all others (no prompt)
#   killallbutme --yes     # same as -y
#   killallbutme --help    # show this help
#
# Session → pts mapping:
#   1 → pts/0,  2 → pts/1,  3 → pts/2,  etc.
#
# Kills the *root* shell (zsh/bash) that owns each pts device.
# All child processes die with it.
# ----------------------------------------------------------------------
killallbutme() {
    local force=""
    local show_help=false

    for arg in "$@"; do
        case "$arg" in
            -y|--yes) force=1 ;;
            --help)   show_help=true ;;
            *) echo "Unknown option: $arg" >&2; return 1 ;;
        esac
    done

    if $show_help; then
        awk '/^#/{if(!f){f=1;next}; if(/^killallbutme\(\)/){exit}; print substr($0,3)}' \
            "${BASH_SOURCE[0]:-${(%):-%x}}"
        return 0
    fi

    local current_pts=$(tty)
    current_pts="${current_pts##*/}"   # pts/1 → 1

    echo "=== Termux Sessions (current: pts/$current_pts) ==="

    # Find the *root* shell for each pts/* by matching the TTY column
    local sessions=()
    while IFS= read -r pid tty cmd; do
        local pts="${tty##*/}"
        [[ "$pts" == "$current_pts" ]] && continue
        sessions+=("$pid")
        printf "  Session %2d → PID %5d (pts/%d) %s\n" \
               $((pts + 1)) "$pid" "$pts" "${cmd##*/}"
    done < <(ps -ef | awk -v uid="$UID" '
        $1 == uid && /data\/data\/com\.termux/ && $8 ~ /^\/dev\/pts\// {
            print $2 " " $8 " " $9
        }' | sort -k2)

    (( ${#sessions[@]} == 0 )) && { echo "No other sessions to kill."; return 0; }

    echo "Will kill ${#sessions[@]} other session(s): ${sessions[*]}"

    if [[ -z "$force" ]]; then
        printf "Confirm? [y/N] "
        read -r ans
        [[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; return 0; }
    fi

    for pid in "${sessions[@]}"; do
        kill "$pid" 2>/dev/null && echo "Killed PID $pid"
    done

    echo "Done."
}
INNER_EOF

# Idempotent .bashrc entry
grep -Fq 'killallbutme.sh' ~/.bashrc || \
    echo '[[ -f ~/.config/termux/functions/killallbutme.sh ]] && . ~/.config/termux/functions/killallbutme.sh' >> ~/.bashrc

# Reload
source ~/.bashrc 2>/dev/null || true

echo "killallbutme installed!"
echo "Try: killallbutme --help"
