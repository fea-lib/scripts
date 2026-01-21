#!/bin/bash
# Usage: ./checkout.sh <target-worktree-folder> <branch-name>

WORKTREE_FOLDER=$1
BRANCH_NAME=$2

if [ -z "$WORKTREE_FOLDER" ] || [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <target-worktree-folder> <branch-name>"
    exit 1
fi

if [ ! -d "$WORKTREE_FOLDER" ]; then
    echo "❌ Error: Directory '$WORKTREE_FOLDER' does not exist."
    exit 1
fi

echo "🔄 Syncing worktree '$WORKTREE_FOLDER' to branch '$BRANCH_NAME'..."

# Enter the specific worktree directory
cd "$WORKTREE_FOLDER" || exit

# Fetch the latest changes from the remote
git fetch origin

# Checkout the branch in detached mode
# This allows you to inspect any branch or PR without conflicts.
git checkout --detach "$BRANCH_NAME"

# Best Practice: Re-link or update environment files here if needed,
# ln -sf ../.shared/.env .env

echo "✅ Worktree '$WORKTREE_FOLDER' is now at '$BRANCH_NAME' (Detached HEAD)."