#!/bin/bash

# Script to add a new GitHub submodule to the experiments repository
# Usage: ./add_submodule.sh <experiment_name>
# Prerequisites: GitHub repository must be created first at https://github.com/sunnybak/<experiment_name>

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
    echo "Prerequisites:"
    echo "  • Create the GitHub repository first at: https://github.com/sunnybak/<experiment_name>"
    echo "  • Repository can be empty (script will initialize it)"
    echo ""
    echo "Arguments:"
    echo "  experiment_name   Name of the experiment (required)"
    echo ""
    echo "Examples:"
    echo "  $0 my-experiment"
    echo "  $0 neural-networks"
    echo ""
    echo "What the script does:"
    echo "  1. Creates local directory for the experiment"
    echo "  2. Initializes git repository"
    echo "  3. Sets up remote to GitHub repository"
    echo "  4. Creates initial README.md and .gitignore"
    echo "  5. Makes initial commit and pushes to GitHub"
    echo "  6. Removes local directory"
    echo "  7. Adds as git submodule to experiments repository"
    echo ""
    echo "Features:"
    echo "  • Automatically constructs GitHub URL: https://github.com/sunnybak/<experiment_name>.git"
    echo "  • Validates experiment name"
    echo "  • Checks for existing submodules"
    echo "  • Creates proper initial repository structure"
    echo "  • Automatically commits and pushes changes"
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

# Function to create initial repository structure
create_initial_repo() {
    local experiment_name="$1"
    local github_url="$2"
    
    print_info "🔧 Creating initial repository structure..."
    
    # Create directory and initialize git
    mkdir "$experiment_name"
    cd "$experiment_name"
    
    git init
    
    # Create initial README.md
    cat > README.md << EOF
# $experiment_name

Experiment description goes here.

## Setup

\`\`\`bash
# Add setup instructions
\`\`\`

## Usage

\`\`\`bash
# Add usage instructions
\`\`\`

## Results

Document your findings here.
EOF
    
    # Create .gitignore
    cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Jupyter Notebooks
.ipynb_checkpoints

# Data files (add specific patterns as needed)
*.csv
*.json
*.pkl
*.h5
*.hdf5

# Model files
*.pt
*.pth
*.model
*.weights

# Logs
*.log
logs/
EOF
    
    # Create initial Python file
    cat > __init__.py << EOF
"""
$experiment_name experiment module.
"""

__version__ = "0.1.0"
EOF
    
    # Add all files and make initial commit
    git add .
    git commit -m "Initial commit for $experiment_name experiment"
    
    # Rename branch to main (GitHub standard)
    git branch -M main
    
    # Add remote origin
    git remote add origin "$github_url"
    
    # Push to GitHub
    print_info "📤 Pushing initial commit to GitHub..."
    git push -u origin main --force
    
    # Go back to parent directory
    cd ..
    
    print_success "Initial repository created and pushed to GitHub"
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
    print_warning "⚠️  Make sure you've created the GitHub repository first!"
    print_info "   Repository URL: https://github.com/sunnybak/$experiment_name"
    print_info ""
    
    # Confirm before proceeding
    read -p "Have you created the GitHub repository and want to proceed? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Cancelled by user"
        print_info ""
        print_info "To create the GitHub repository:"
        print_info "1. Go to https://github.com/new"
        print_info "2. Repository name: $experiment_name"
        print_info "3. Make it public or private as needed"
        print_info "4. Don't initialize with README (script will do this)"
        print_info "5. Run this script again"
        exit 0
    fi
    
    print_info ""
    
    # Create initial repository structure
    create_initial_repo "$experiment_name" "$github_url"
    
    # Remove the local directory (we'll get it back as a submodule)
    print_info "🧹 Cleaning up local directory..."
    rm -rf "$experiment_name"
    
    # Clean up any git cache references to the directory
    git rm --cached "$experiment_name" 2>/dev/null || true
    
    print_info "🔗 Adding as submodule..."
    
    # Add the submodule
    if git submodule add "$github_url" "$experiment_name" --force; then
        print_success "Submodule added successfully"
    else
        print_error "Failed to add submodule. Repository might not be accessible."
        exit 1
    fi
    
    # Check git status
    print_info ""
    print_info "📊 Git status:"
    git status --short
    
    # Ask if user wants to commit
    print_info ""
    read -p "Commit changes to experiments repository? (Y/n): " commit_confirm
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
    print_info "  • To work on it: cd $experiment_name"
    print_info "  • To update the submodule: git submodule update --remote $experiment_name"
    print_info "  • To check submodule status: git submodule status"
    print_info "  • GitHub repository: https://github.com/sunnybak/$experiment_name"
}

# Run main function with all arguments
main "$@" 