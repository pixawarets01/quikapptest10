#!/bin/bash
# Common utilities for all workflows

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️ INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ SUCCESS: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

# Environment checks
check_flutter() {
    if command -v flutter >/dev/null 2>&1; then
        log_success "Flutter: $(flutter --version | head -1)"
        return 0
    else
        log_error "Flutter not found"
        return 1
    fi
}

# Build helpers
clean_build() {
    log_info "Cleaning build artifacts..."
    flutter clean >/dev/null 2>&1 || true
    rm -rf build/ >/dev/null 2>&1 || true
    log_success "Build artifacts cleaned"
}

get_deps() {
    log_info "Getting Flutter dependencies..."
    if flutter pub get; then
        log_success "Dependencies downloaded"
        return 0
    else
        log_error "Failed to get dependencies"
        return 1
    fi
}

# Export functions
export -f log_info log_success log_warning log_error
export -f check_flutter clean_build get_deps 