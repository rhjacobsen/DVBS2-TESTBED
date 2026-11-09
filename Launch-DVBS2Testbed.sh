#!/usr/bin/env bash

set -euo pipefail

# ---------------------------------------------------------------------
# MATLAB scripts to launch
# ---------------------------------------------------------------------
scripts=(
    "S1a_Transmitter.m"
    "S1b_ACMControl.m"
    "S2a_RFAcquisition.m"
    "S2b_Reciever.m"
    "S3_ProcessingUnit.m"
)

stagger_seconds=1

# ---------------------------------------------------------------------
# Locate MATLAB
# ---------------------------------------------------------------------
#if command -v matlab >/dev/null 2>&1; then
#    matlab_exe=$(command -v matlab)
#else
#    echo "ERROR: matlab not found in PATH"
#    exit 1
#fi

matlab_exe="/usr/local/MATLAB/R2026a/bin/matlab"

if [[ ! -x "$matlab_exe" ]]; then
    echo "ERROR: MATLAB executable not found:"
    echo "  $matlab_exe"
    exit 1
fi


# ---------------------------------------------------------------------
# Directories
# ---------------------------------------------------------------------
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
code_dir="$project_root/Testbed"
log_dir="$project_root/logs"

mkdir -p "$log_dir"

timestamp=$(date +"%Y-%m-%d_%H%M%S")

echo "=== DVB-S2 testbed launcher ==="
echo "MATLAB: $matlab_exe"
echo "Logs:   $log_dir"

# ---------------------------------------------------------------------
# Kill previous MATLAB testbed instances
# ---------------------------------------------------------------------
pkill -f "S1a_Transmitter.m" || true
pkill -f "S1b_ACMControl.m" || true
pkill -f "S2a_RFAcquisition.m" || true
pkill -f "S2b_Reciever.m" || true
pkill -f "S3_ProcessingUnit.m" || true

sleep 2

# ---------------------------------------------------------------------
# Launch scripts
# ---------------------------------------------------------------------
for script in "${scripts[@]}"; do

    script_path="$code_dir/$script"

    if [[ ! -f "$script_path" ]]; then
        echo "WARNING: $script_path not found"
        continue
    fi

    name=$(basename "$script" .m)
    log_file="$log_dir/${name}_${timestamp}.log"

    $matlab_exe \
        -nodesktop \
        -nosplash \
        -logfile "$log_file" \
        -r "run('$script_path')" &

    pid=$!

    printf "started %-25s PID %-8s log: %s\n" \
        "$name" "$pid" "$log_file"

    sleep "$stagger_seconds"

done

echo
echo "All MATLAB instances started."

