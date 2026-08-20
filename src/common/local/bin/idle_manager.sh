#!/usr/bin/env bash

PID_FILE="/tmp/idle_manager_daemon.pid"
TOGGLE_LOCK="/tmp/idle_manager_toggle.lock"
CHECK_INTERVAL=2
DAEMON_PID_VAR=""
IDLE_BIN="hypridle"

if ! command -v hypridle >/dev/null 2>&1 && command -v swayidle >/dev/null 2>&1; then
    IDLE_BIN="swayidle"
fi
STATE=0 # 0 = running, 1 = paused

log_msg() {
    local time_stamp
    time_stamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$time_stamp] $1"
}

cleanup() {
    log_msg "INFO: Exiting daemon..."
    if [ -n "$DAEMON_PID_VAR" ] && [ "$STATE" -eq 1 ]; then
        log_msg "CLEANUP: Resuming $IDLE_BIN before exit..."
        kill -CONT "$DAEMON_PID_VAR" 2>/dev/null
    fi
    rm -f "$PID_FILE"
    exit 0
}

show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Manage idle daemon ($IDLE_BIN) and monitor audio to prevent screen from sleeping."
    echo ""
    echo "Options:"
    echo "  --help      Show this help message."
    echo "  --startup   Start the audio monitoring daemon (prints log to stdout)."
    echo "  --toggle    Toggle idle daemon and the monitoring daemon on/off."
    echo "  --check     Check if the daemon is currently running."
}

is_audio_playing() {
    pactl list sink-inputs 2>/dev/null | awk '
        /Sink Input/ { is_target=1; corked=0; muted=0 }
        is_target && /Corked: yes/ { corked=1 }
        is_target && /Mute: yes/ { muted=1 }
        is_target && /media.class = "Stream\/Output\/Audio"/ {
            if (corked == 0 && muted == 0) {
                found=1
            }
        }
        END { exit !found }
    '
    return $?
}

run_daemon() {
    if [ -f "$PID_FILE" ]; then
        old_pid=$(cat "$PID_FILE")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            log_msg "ERROR: Daemon is already running with PID $old_pid."
            exit 1
        fi
    fi

    echo $$ > "$PID_FILE"
    trap cleanup SIGINT SIGTERM EXIT

    log_msg "INFO: Idle manager daemon started successfully (PID: $$)."
    
    while true; do
        DAEMON_PID_VAR=$(pgrep -x -u "$USER" "$IDLE_BIN" | head -n 1)

        if [ -n "$DAEMON_PID_VAR" ]; then
            if is_audio_playing; then
                if [ "$STATE" -eq 0 ]; then
                    kill -STOP "$DAEMON_PID_VAR" 2>/dev/null
                    log_msg "ACTION: Audio detected. Suspended $IDLE_BIN (PID: $DAEMON_PID_VAR)."
                    STATE=1
                fi
            else
                if [ "$STATE" -eq 1 ]; then
                    kill -CONT "$DAEMON_PID_VAR" 2>/dev/null
                    log_msg "ACTION: Audio stopped. Resumed $IDLE_BIN (PID: $DAEMON_PID_VAR)."
                    STATE=0
                fi
            fi
        fi
        sleep "$CHECK_INTERVAL"
    done
}

toggle_service() {
    exec 201>"$TOGGLE_LOCK"
    flock -x 201

    DAEMON_RUNNING=0
    if [ -f "$PID_FILE" ]; then
        DAEMON_PID=$(cat "$PID_FILE")
        if ps -p "$DAEMON_PID" > /dev/null 2>&1; then
            DAEMON_RUNNING=1
        fi
    fi

    if [ "$DAEMON_RUNNING" -eq 1 ]; then
        log_msg "TOGGLE: Stopping $IDLE_BIN and daemon..."
        notify-send "Idle Manager" "Stopping $IDLE_BIN and daemon..."
        
        kill -TERM "$DAEMON_PID" 2>/dev/null
        rm -f "$PID_FILE" 2>/dev/null
        
        pkill -CONT -x -u "$USER" "$IDLE_BIN" 2>/dev/null
        pkill -TERM -x -u "$USER" "$IDLE_BIN" 2>/dev/null
        sleep 0.2
        
        log_msg "TOGGLE: All services stopped."
    else
        log_msg "TOGGLE: Starting $IDLE_BIN and daemon..."
        notify-send "Idle Manager" "Starting $IDLE_BIN and daemon..."
        
        pkill -CONT -x -u "$USER" "$IDLE_BIN" 2>/dev/null
        pkill -TERM -x -u "$USER" "$IDLE_BIN" 2>/dev/null
        sleep 0.2
        
        if [ "$IDLE_BIN" = "swayidle" ]; then
            swayidle -w timeout 300 "$HOME/.local/bin/lock.sh" timeout 600 'niri msg action power-off-monitors' 201>&- &
        else
            hypridle 201>&- &
        fi
        disown
        
        SCRIPT_PATH=$(realpath "$0")
        bash "$SCRIPT_PATH" --startup 201>&- &
        disown
        
        log_msg "TOGGLE: All services started."
    fi
}

check_status() {
    if [ -f "$PID_FILE" ]; then
        DAEMON_PID=$(cat "$PID_FILE")
        if ps -p "$DAEMON_PID" > /dev/null 2>&1; then
            echo "STATUS: Active (Daemon is running, PID: $DAEMON_PID)"
            exit 0
        fi
    fi
    echo "STATUS: Inactive (Daemon is stopped)"
    exit 1
}

case "$1" in
    --help)
        show_help
        ;;
    --startup)
        run_daemon
        ;;
    --toggle)
        toggle_service
        ;;
    --check)
        check_status
        ;;
    *)
        echo "Invalid option. Use '$0 --help' for available commands."
        exit 1
        ;;
esac