# Set the root directory for the project first
if [[ -z "$PROJECT_ROOT" ]]; then
    export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
fi

# Load the core bats libraries
load '/usr/lib/bats/bats-support/load.bash'
load '/usr/lib/bats/bats-assert/load.bash'
load '/usr/lib/bats/bats-file/load.bash'

# Load our custom helpers using absolute path
load "${PROJECT_ROOT}/test/helpers/load.bash"

# Add scripts directory to PATH for testing
PATH="$PROJECT_ROOT/scripts:$PATH"
