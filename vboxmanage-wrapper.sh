#!/usr/bin/env bash
# Wrapper for VBoxManage on NixOS that handles startvm command
# by delegating to VBoxHeadless which has proper setuid wrapper

if [[ "$1" == "startvm" ]] && [[ "$3" == "--type" ]] && [[ "$4" == "headless" ]]; then
    # Use VBoxHeadless wrapper instead of VBoxManage for starting VMs
    exec /run/wrappers/bin/VBoxHeadless --startvm "$2" &
    # Wait a bit for VM to start
    sleep 2
    exit 0
else
    # For all other commands, use regular VBoxManage
    exec /run/current-system/sw/bin/VBoxManage "$@"
fi
