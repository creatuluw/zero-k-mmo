#!/bin/bash
###############################################################################
# Zero-K MMO Server - Setup Verification Script
# Checks that all required files, tools, and configurations are in place
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

###############################################################################
# Utility Functions
###############################################################################

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_failure() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        print_success "$description exists ($file)"
        return 0
    else
        print_failure "$description not found ($file)"
        return 1
    fi
}

check_dir() {
    local dir=$1
    local description=$2

    if [ -d "$dir" ]; then
        print_success "$directory exists ($dir)"
        return 0
    else
        print_failure "$directory not found ($dir)"
        return 1
    fi
}

check_command() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        print_success "$description installed ($(command -v $cmd))"
        return 0
    else
        print_failure "$description not found ($cmd)"
        return 1
    fi
}

###############################################################################
# Main Verification
###############################################################################

main() {
    print_header "Zero-K MMO Server Setup Verification"

    # Check current directory
    print_info "Current directory: $(pwd)"
    echo ""

    ###############################################################################
    # 1. Check Required Files
    ###############################################################################

    print_header "1. Checking Required Files"

    check_file "Dockerfile" "Docker configuration"
    check_file "railway.json" "Railway configuration"
    check_file "gameconfig.txt" "Game configuration"
    check_file "start-dedicated.sh" "Startup script"
    check_file "Makefile" "Make automation"
    check_file ".dockerignore" "Docker ignore rules"
    check_file ".gitignore" "Git ignore rules"
    check_file "README.md" "Documentation (README)"
    check_file "DEPLOYMENT.md" "Documentation (DEPLOYMENT)"
    check_file "QUICKSTART.md" "Documentation (QUICKSTART)"
    check_file "PROJECT_SUMMARY.md" "Documentation (PROJECT_SUMMARY)"

    ###############################################################################
    # 2. Check File Permissions
    ###############################################################################

    print_header "2. Checking File Permissions"

    if [ -x "start-dedicated.sh" ]; then
        print_success "start-dedicated.sh is executable"
    else
        print_warning "start-dedicated.sh is not executable (chmod +x start-dedicated.sh)"
    fi

    if [ -r "gameconfig.txt" ]; then
        print_success "gameconfig.txt is readable"
    else
        print_failure "gameconfig.txt is not readable"
    fi

    ###############################################################################
    # 3. Check Required Tools (for local testing)
    ###############################################################################

    print_header "3. Checking Required Tools"

    check_command "docker" "Docker"
    check_command "git" "Git"

    # Optional tools
    print_info "Optional tools:"
    if command -v "railway" &> /dev/null; then
        print_success "Railway CLI installed ($(command -v railway))"
    else
        print_warning "Railway CLI not found (install with: npm install -g @railway/cli)"
    fi

    if command -v "make" &> /dev/null; then
        print_success "Make installed ($(command -v make))"
    else
        print_warning "Make not found (useful for automation)"
    fi

    ###############################################################################
    # 4. Check Configuration Files Content
    ###############################################################################

    print_header "4. Validating Configuration Files"

    # Check Dockerfile
    if grep -q "FROM ubuntu" Dockerfile 2>/dev/null; then
        print_success "Dockerfile has valid base image"
    else
        print_failure "Dockerfile missing valid base image"
    fi

    if grep -q "EXPOSE 8200" Dockerfile 2>/dev/null; then
        print_success "Dockerfile exposes port 8200"
    else
        print_failure "Dockerfile missing port 8200 exposure"
    fi

    # Check gameconfig.txt
    if grep -q "\[SERVER\]" gameconfig.txt 2>/dev/null; then
        print_success "gameconfig.txt has SERVER section"
    else
        print_failure "gameconfig.txt missing SERVER section"
    fi

    if grep -q "Name = " gameconfig.txt 2>/dev/null; then
        print_success "gameconfig.txt has server name"
    else
        print_warning "gameconfig.txt missing server name"
    fi

    # Check railway.json
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool railway.json &> /dev/null; then
            print_success "railway.json is valid JSON"
        else
            print_failure "railway.json has invalid JSON syntax"
        fi
    else
        print_warning "Cannot validate railway.json (python3 not available)"
    fi

    ###############################################################################
    # 5. Check Directory Structure
    ###############################################################################

    print_header "5. Checking Directory Structure"

    # Create data directory if it doesn't exist
    if [ ! -d "data" ]; then
        print_warning "data directory not found (will be created on first run)"
        mkdir -p data/{replays,logs,config} 2>/dev/null && print_success "Created data directory structure" || print_failure "Failed to create data directory"
    else
        print_success "data directory exists"
    fi

    # Check for maps directory
    if [ -d "maps" ]; then
        print_success "maps directory exists"
        MAP_COUNT=$(find maps -type f 2>/dev/null | wc -l)
        if [ "$MAP_COUNT" -gt 0 ]; then
            print_success "Found $MAP_COUNT map file(s)"
        else
            print_warning "maps directory exists but is empty"
        fi
    else
        print_warning "maps directory not found (maps will be downloaded by players)"
    fi

    ###############################################################################
    # 6. Check Git Repository
    ###############################################################################

    print_header "6. Checking Git Repository"

    if [ -d ".git" ]; then
        print_success "Git repository initialized"

        if git remote -v | grep -q "origin"; then
            print_success "Git remote configured"
            print_info "Remote: $(git remote get-url origin)"
        else
            print_warning "No git remote configured"
        fi

        if [ -n "$(git status --porcelain)" ]; then
            print_warning "Uncommitted changes exist"
            print_info "Run: git add . && git commit -m 'Initial setup'"
        else
            print_success "Working directory clean"
        fi
    else
        print_failure "Not a git repository"
        print_info "Run: git init && git add . && git commit -m 'Initial setup'"
    fi

    ###############################################################################
    # 7. Docker Capabilities
    ###############################################################################

    print_header "7. Checking Docker Capabilities"

    if command -v docker &> /dev/null; then
        # Check if Docker daemon is running
        if docker info &> /dev/null; then
            print_success "Docker daemon is running"

            # Check Docker version
            DOCKER_VERSION=$(docker --version)
            print_info "Docker version: $DOCKER_VERSION"

            # Check available disk space
            DISK_SPACE=$(df -h . | tail -1 | awk '{print $4}')
            print_info "Available disk space: $DISK_SPACE"

            # Check if we can build (dry run)
            if docker build --help &> /dev/null; then
                print_success "Docker build command available"
            else
                print_failure "Docker build command not available"
            fi
        else
            print_failure "Docker daemon is not running"
            print_info "Start Docker: sudo systemctl start docker (Linux) or start Docker Desktop (Windows/Mac)"
        fi
    else
        print_failure "Docker not installed"
    fi

    ###############################################################################
    # 8. Network Configuration Check
    ###############################################################################

    print_header "8. Network Configuration"

    # Check if ports are available (local testing)
    print_info "Checking if required ports are available locally..."

    if command -v netstat &> /dev/null; then
        if netstat -uln 2>/dev/null | grep -q ":8200 "; then
            print_warning "Port 8200/UDP is already in use"
        else
            print_success "Port 8200/UDP is available"
        fi

        if netstat -tln 2>/dev/null | grep -q ":8452 "; then
            print_warning "Port 8452/TCP is already in use"
        else
            print_success "Port 8452/TCP is available"
        fi
    elif command -v ss &> /dev/null; then
        if ss -uln 2>/dev/null | grep -q ":8200 "; then
            print_warning "Port 8200/UDP is already in use"
        else
            print_success "Port 8200/UDP is available"
        fi

        if ss -tln 2>/dev/null | grep -q ":8452 "; then
            print_warning "Port 8452/TCP is already in use"
        else
            print_success "Port 8452/TCP is available"
        fi
    else
        print_warning "Cannot check port availability (netstat/ss not available)"
    fi

    ###############################################################################
    # 9. Makefile Commands Check
    ###############################################################################

    print_header "9. Checking Makefile Commands"

    if [ -f "Makefile" ]; then
        # Extract all targets from Makefile
        TARGETS=$(grep "^[a-zA-Z_-]*:" Makefile | cut -d: -f1 | head -10)
        TARGET_COUNT=$(echo "$TARGETS" | wc -l)
        print_success "Makefile found with $TARGET_COUNT targets"
        print_info "Run 'make help' for available commands"
    else
        print_failure "Makefile not found"
    fi

    ###############################################################################
    # 10. Final Summary
    ###############################################################################

    print_header "Verification Summary"

    echo -e "${GREEN}Passed: $PASSED${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo -e "${RED}Failed: $FAILED${NC}"
    echo ""

    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All critical checks passed!${NC}"
        echo ""
        echo "You're ready to deploy!"
        echo ""
        echo "Next steps:"
        echo "  1. Push to GitHub: git push origin main"
        echo "  2. Deploy to Railway: railway deploy"
        echo "  3. Or test locally: make run"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Some checks failed. Please fix the issues above.${NC}"
        echo ""
        echo "Common fixes:"
        echo "  - Install Docker: https://docs.docker.com/get-docker/"
        echo "  - Install Railway CLI: npm install -g @railway/cli"
        echo "  - Make files executable: chmod +x start-dedicated.sh"
        echo "  - Initialize git: git init && git add . && git commit -m 'Initial setup'"
        echo ""
        return 1
    fi
}

# Run main function
main "$@"
