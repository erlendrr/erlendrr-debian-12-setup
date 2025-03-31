#!/usr/bin/bash

# Run the non-GNOME tasks
./non_desktop_tasks.sh

# If GNOME is the current session, run GNOME-specific tasks
if [ "$XDG_SESSION_DESKTOP" == "gnome" ]; then
    ./desktop_tasks.sh
else
    echo "[INFO] GNOME not found or not the current desktop session. Skipping GNOME-specific setup."
fi

echo "========== Full Setup Complete =========="
