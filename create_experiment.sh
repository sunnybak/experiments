#!/bin/bash

# Script to add a new GitHub submodule to the experiments repository
# Usage: ./add_submodule.sh <experiment_name>

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}Success: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_info() {
    echo -e "$1"
}

print_usage() {
    echo -e "${BLUE}GitHub Submodule Creator for Experiments Repository${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
    echo "Usage:"
    echo "  $0 <experiment_name>"
    echo "  $0 --help"
    echo ""
    echo "Arguments:"
    echo "  experiment_name   Name of the experiment (required)"
    echo ""
    echo "Examples:"
    echo "  $0 my-experiment"
    echo "  $0 neural-networks"
    echo ""
    echo "Features:"
    echo "  • Automatically constructs GitHub URL: https://github.com/sunnybak/<experiment_name>.git"
    echo "  • Validates experiment name"
    echo "  • Checks for existing submodules"
    echo "  • Automatically commits and pushes changes (with confirmation)"
    echo "  • Provides colored output and progress feedback"
}

# Function to check if submodule already exists
check_submodule_exists() {
    local name="$1"
    if [ -d "$name" ]; then
        print_error "Directory '$name' already exists"
        return 1
    fi
    
    if git submodule status | grep -q " $name "; then
        print_error "Submodule '$name' already exists in .gitmodules"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    # Check for help flag
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        print_usage
        exit 0
    fi
    
    print_info "🚀 GitHub Submodule Creator for Experiments Repository"
    print_info "=================================================="
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check if we're in the experiments directory
    current_dir=$(basename "$PWD")
    if [ "$current_dir" != "experiments" ]; then
        print_error "This script should be run from the experiments directory"
        exit 1
    fi
    
    # Get experiment name
    local experiment_name="$1"
    if [ -z "$experiment_name" ]; then
        read -p "Enter experiment name: " experiment_name
        if [ -z "$experiment_name" ]; then
            print_error "Experiment name cannot be empty"
            print_info ""
            print_usage
            exit 1
        fi
    fi
    
    # Validate experiment name (no spaces, special characters, etc.)
    if [[ ! "$experiment_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Experiment name can only contain letters, numbers, hyphens, and underscores"
        exit 1
    fi
    
    # Check if submodule already exists
    if ! check_submodule_exists "$experiment_name"; then
        exit 1
    fi
    
    # Construct GitHub URL automatically
    local github_url="https://github.com/sunnybak/$experiment_name.git"
    
    print_info ""
    print_info "📋 Summary:"
    print_info "  Experiment name: $experiment_name"
    print_info "  GitHub URL: $github_url"
    print_info ""
    
    # Confirm before proceeding
    read -p "Proceed with adding submodule? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Cancelled by user"
        exit 0
    fi
    
    print_info ""
    print_info "🔄 Adding submodule..."
    
    # Add the submodule
    if git submodule add "$github_url" "$experiment_name"; then
        print_success "Submodule added successfully"
    else
        print_error "Failed to add submodule. Make sure the repository $github_url exists."
        exit 1
    fi
    
    # Check git status
    print_info ""
    print_info "📊 Git status:"
    git status --short
    
    # Ask if user wants to commit
    print_info ""
    read -p "Commit changes? (Y/n): " commit_confirm
    if [[ ! "$commit_confirm" =~ ^[Nn]$ ]]; then
        print_info "📝 Committing changes..."
        if git commit -m "Add $experiment_name submodule"; then
            print_success "Changes committed successfully"
            
            # Ask if user wants to push
            print_info ""
            read -p "Push to remote? (Y/n): " push_confirm
            if [[ ! "$push_confirm" =~ ^[Nn]$ ]]; then
                print_info "🚀 Pushing to remote..."
                if git push; then
                    print_success "Changes pushed successfully"
                else
                    print_error "Failed to push changes"
                    exit 1
                fi
            fi
        else
            print_error "Failed to commit changes"
            exit 1
        fi
    fi
    
    print_info ""
    print_success "🎉 Experiment '$experiment_name' has been successfully added as a submodule!"
    print_info ""
    print_info "📋 Next steps:"
    print_info "  • The experiment is now available in the '$experiment_name' directory"
    print_info "  • To update the submodule: git submodule update --remote $experiment_name"
    print_info "  • To check submodule status: git submodule status"
    print_info "  • GitHub repository: $github_url"
}

# Run main function with all arguments
main "$@" 