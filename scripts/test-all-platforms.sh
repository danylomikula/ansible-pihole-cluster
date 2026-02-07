#!/usr/bin/env bash
#
# Run molecule tests on Hetzner Cloud across all supported platforms and scenarios
#
# Requirements:
#   - HCLOUD_TOKEN environment variable (Hetzner API token)
#   - hcloud CLI installed
#   - molecule installed with ansible driver
#
# Usage:
#   HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh                     # Test ALL scenarios on ALL platforms
#   HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh converge            # Only converge (no destroy)
#   HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh --scenario default  # Test specific scenario
#   HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh --platform debian13 # Test specific platform
#   STOP_ON_FAILURE=false HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh  # Continue on errors
#

set -euo pipefail

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Change to extensions directory where molecule config lives
cd "${PROJECT_ROOT}/extensions"

# =============================================================================
# SUPPORTED PLATFORMS
# =============================================================================
PLATFORMS=(
    "debian13"
    "ubuntu2404"
    "rockylinux10"
)

# =============================================================================
# AVAILABLE SCENARIOS
# =============================================================================
SCENARIOS=(
    "default"        # Full test: all features (unbound, updatelists, nebula-sync)
    "custom-config"  # Custom Pi-hole configuration values
    "no-unbound"     # External DNS without Unbound
)

# =============================================================================
# HETZNER CONFIGURATION
# =============================================================================
HCLOUD_SERVER_TYPE="${HCLOUD_SERVER_TYPE:-cx33}"
HCLOUD_LOCATION="${HCLOUD_LOCATION:-fsn1}"
HCLOUD_FALLBACK_LOCATIONS="${HCLOUD_FALLBACK_LOCATIONS:-nbg1,hel1}"

# =============================================================================
# Configuration
# =============================================================================
MOLECULE_COMMAND="test"
SINGLE_SCENARIO=""
SINGLE_PLATFORM=""
STOP_ON_FAILURE="${STOP_ON_FAILURE:-true}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Results tracking
RESULTS_NAME=()
RESULTS_STATUS=()
RESULTS_TIME=()

# Track if cleanup is needed
CLEANUP_NEEDED=false

# =============================================================================
# Cleanup trap - ensures Hetzner resources are destroyed on failure/interrupt
# =============================================================================
cleanup() {
    local exit_code=$?
    # Prevent recursive calls
    trap - EXIT INT TERM
    if [[ "${CLEANUP_NEEDED}" == "true" ]]; then
        echo ""
        log_warning "Cleaning up Hetzner Cloud resources..."
        molecule destroy -s hetzner 2>/dev/null || true
        log_info "Cleanup completed"
    fi
    exit "${exit_code}"
}

# Catch EXIT, Ctrl+C (INT), and TERM signals
trap cleanup EXIT INT TERM

# =============================================================================
# Functions
# =============================================================================
usage() {
    echo "Usage: $0 [OPTIONS] [MOLECULE_COMMAND]"
    echo ""
    echo "Run molecule tests on Hetzner Cloud infrastructure."
    echo ""
    echo "Options:"
    echo "  --scenario NAME     Run only specific scenario on all platforms"
    echo "  --platform NAME     Run all scenarios on specific platform only"
    echo "  --list-scenarios    List available scenarios"
    echo "  --list-platforms    List available platforms"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Molecule commands: test, converge, verify, destroy, etc."
    echo ""
    echo "Environment variables:"
    echo "  HCLOUD_TOKEN        Required: Hetzner Cloud API token"
    echo "  HCLOUD_SERVER_TYPE  Server type (default: cx33)"
    echo "  HCLOUD_LOCATION     Primary location (default: fsn1)"
    echo "  STOP_ON_FAILURE     Stop on first failure (default: true)"
    echo ""
    echo "Examples:"
    echo "  HCLOUD_TOKEN=xxx $0                           # Test ALL scenarios on ALL platforms"
    echo "  HCLOUD_TOKEN=xxx $0 --scenario default        # Test only default scenario"
    echo "  HCLOUD_TOKEN=xxx $0 --platform debian13       # Test all scenarios on debian13"
    echo "  HCLOUD_TOKEN=xxx $0 converge                  # Only converge, no destroy"
    exit 0
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_scenario() {
    echo -e "${CYAN}[SCENARIO]${NC} $1"
}

check_requirements() {
    if [[ -z "${HCLOUD_TOKEN:-}" ]]; then
        log_error "HCLOUD_TOKEN environment variable is required"
        echo ""
        echo "Get your token from: https://console.hetzner.cloud/projects/*/security/tokens"
        exit 1
    fi

    if ! command -v hcloud &> /dev/null; then
        log_error "hcloud CLI is required but not installed"
        echo ""
        echo "Install with: brew install hcloud"
        exit 1
    fi

    if ! command -v molecule &> /dev/null; then
        log_error "molecule is required but not installed"
        echo ""
        echo "Install with: pip install molecule ansible"
        exit 1
    fi
}

run_test() {
    local name="$1"
    local distro="$2"
    local scenario="$3"
    local start_time
    local end_time
    local duration

    log_info "Testing: ${name}"
    log_info "  Platform: ${distro}"
    log_info "  Scenario: ${scenario}"
    log_info "  Server type: ${HCLOUD_SERVER_TYPE}"
    log_info "  Location: ${HCLOUD_LOCATION}"
    start_time=$(date +%s)

    # Mark cleanup needed before creating resources
    CLEANUP_NEEDED=true

    if MOLECULE_HCLOUD_DISTRO="${distro}" \
       MOLECULE_HCLOUD_SCENARIO="${scenario}" \
       HCLOUD_SERVER_TYPE="${HCLOUD_SERVER_TYPE}" \
       HCLOUD_LOCATION="${HCLOUD_LOCATION}" \
       HCLOUD_FALLBACK_LOCATIONS="${HCLOUD_FALLBACK_LOCATIONS}" \
       molecule "${MOLECULE_COMMAND}" -s hetzner 2>&1; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        RESULTS_NAME+=("${name}")
        RESULTS_STATUS+=("PASS")
        RESULTS_TIME+=("${duration}")
        CLEANUP_NEEDED=false  # Successful test includes destroy
        log_success "${name} completed in ${duration}s"
        return 0
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        RESULTS_NAME+=("${name}")
        RESULTS_STATUS+=("FAIL")
        RESULTS_TIME+=("${duration}")
        log_error "${name} failed after ${duration}s"
        # Run cleanup for failed test before continuing
        log_warning "Running cleanup for failed test..."
        molecule destroy -s hetzner 2>/dev/null || true
        CLEANUP_NEEDED=false
        return 1
    fi
}

print_summary() {
    echo ""
    echo "=============================================="
    echo "TEST SUMMARY"
    echo "=============================================="
    echo ""

    local passed=0
    local failed=0
    local i

    for i in "${!RESULTS_NAME[@]}"; do
        local name="${RESULTS_NAME[$i]}"
        local status="${RESULTS_STATUS[$i]}"
        local duration="${RESULTS_TIME[$i]}"

        if [[ "$status" == "PASS" ]]; then
            echo -e "${GREEN}✓${NC} ${name}: PASS (${duration}s)"
            ((passed++))
        else
            echo -e "${RED}✗${NC} ${name}: FAIL (${duration}s)"
            ((failed++))
        fi
    done

    local total=${#RESULTS_NAME[@]}
    echo ""
    echo "----------------------------------------------"
    echo "Passed: ${passed}/${total}"
    echo "Failed: ${failed}/${total}"
    echo "----------------------------------------------"

    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    return 0
}

test_all() {
    local scenarios_to_test=("${SCENARIOS[@]}")
    local platforms_to_test=("${PLATFORMS[@]}")

    # Filter to single scenario if specified
    if [[ -n "${SINGLE_SCENARIO}" ]]; then
        scenarios_to_test=("${SINGLE_SCENARIO}")
    fi

    # Filter to single platform if specified
    if [[ -n "${SINGLE_PLATFORM}" ]]; then
        platforms_to_test=("${SINGLE_PLATFORM}")
    fi

    local total_tests=$((${#scenarios_to_test[@]} * ${#platforms_to_test[@]}))
    log_info "Running ${total_tests} tests (${#scenarios_to_test[@]} scenarios x ${#platforms_to_test[@]} platforms)"
    log_info "Using Hetzner Cloud (server type: ${HCLOUD_SERVER_TYPE}, location: ${HCLOUD_LOCATION})"
    echo ""

    local has_failures=false
    local current=0

    for scenario in "${scenarios_to_test[@]}"; do
        log_scenario "=== Scenario: ${scenario} ==="
        for distro in "${platforms_to_test[@]}"; do
            ((current++))
            local test_name="${scenario}/${distro}"
            log_info "[${current}/${total_tests}] ${test_name}"
            if ! run_test "${test_name}" "${distro}" "${scenario}"; then
                has_failures=true
                if [[ "${STOP_ON_FAILURE}" == "true" ]]; then
                    log_warning "Stopping due to failure (set STOP_ON_FAILURE=false to continue)"
                    return 1
                fi
            fi
            echo ""
        done
    done

    if [[ "${has_failures}" == "true" ]]; then
        return 1
    fi
    return 0
}

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --scenario)
            SINGLE_SCENARIO="$2"
            shift 2
            ;;
        --platform)
            SINGLE_PLATFORM="$2"
            shift 2
            ;;
        --list-scenarios)
            echo "Available scenarios:"
            for s in "${SCENARIOS[@]}"; do
                echo "  - ${s}"
            done
            exit 0
            ;;
        --list-platforms)
            echo "Available platforms:"
            for p in "${PLATFORMS[@]}"; do
                echo "  - ${p}"
            done
            exit 0
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            MOLECULE_COMMAND="$1"
            shift
            ;;
    esac
done

# =============================================================================
# Main
# =============================================================================
main() {
    check_requirements

    log_info "Molecule command: ${MOLECULE_COMMAND}"
    log_info "Hetzner Cloud configuration:"
    log_info "  Server type: ${HCLOUD_SERVER_TYPE}"
    log_info "  Primary location: ${HCLOUD_LOCATION}"
    log_info "  Fallback locations: ${HCLOUD_FALLBACK_LOCATIONS}"
    if [[ -n "${SINGLE_SCENARIO}" ]]; then
        log_info "Scenario filter: ${SINGLE_SCENARIO}"
    fi
    if [[ -n "${SINGLE_PLATFORM}" ]]; then
        log_info "Platform filter: ${SINGLE_PLATFORM}"
    fi
    echo ""

    test_all
    print_summary
}

main
