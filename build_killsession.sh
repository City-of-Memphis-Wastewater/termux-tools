#!/data/data/com.termux/files/usr/bin/bash
#
# Run this file using 'source build_killsession'

mkdir -p ~/.config/termux/functions
cat >> ~/.config/termux/functions/killsession.sh << 'EOF'

# ----------------------------------------------------------------------
# killsession – close a Termux GUI session (the tabs you see when you
#               swipe in from the left)
#
# Usage:
#   killsession <session-number>   # interactive – asks for confirmation
#   killsession <session-number> -y   # force-kill, no prompt
#
# Session numbers map to pts devices:
#   Session 1 → pts/0
#   Session 2 → pts/1
#   Session 3 → pts/2   … etc.
#
# The function finds the *root* shell (zsh or bash) that belongs to the
# requested pts and kills it. All child processes (python, vim, …) die
# with the parent.
# ----------------------------------------------------------------------
killsession() {
    local num="$1"
    local force="$2"

    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ]; then
        echo "Usage: killsession <session-number> [-y]"
        return 1
    fi

    local pts=$((num - 1))
    local pid=$(ps -ef | awk -v p="$pts" '
    /data\/data\/com\.termux.*(zsh|bash)/ && $8 ~ "pts/" p "($|[^0-9])" && !/awk/ {print $2; exit}
    ')

    if [ -z "$pid" ]; then
        echo "No session found for #$num (pts/$pts)"
        return 1
    fi

    if [ "$force" = "-y" ]; then
        kill "$pid" 2>/dev/null && echo "Killed session #$num (PID $pid)"
    else
        echo "Kill session #$num (PID $pid)? [y/N]"
        read -r ans
        [[ "$ans" =~ ^[Yy]$ ]] && kill "$pid" && echo "Killed session #$num"
    fi
}
EOF

# 2. Refwrwnce the file that holds the function from .bashrc
echo '[[ -f ~/.config/termux/functions/killsession.sh ]] && . ~/.config/termux/functions/killsession.sh' >> ~/.bashrc

source ~/.bashrc
