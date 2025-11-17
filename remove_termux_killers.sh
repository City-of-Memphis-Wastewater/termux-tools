#!/data/data/com.termux/files/usr/bin/bash
# remove_termux_killers.sh – uninstall killsession & killallbutme cleanly

rm -f ~/.config/termux/functions/killsession.sh ~/.config/termux/functions/killallbutme.sh

# Remove sourcing lines from .bashrc
sed -i '/killsession\.sh/d' ~/.bashrc
sed -i '/killallbutme\.sh/d' ~/.bashrc

source ~/.bashrc 2>/dev/null || true

echo "Cleaned up – functions removed. No more session killers."
