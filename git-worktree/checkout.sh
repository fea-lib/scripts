#!/bin/bash
# Usage: ./checkout.sh <target-worktree-folder> <branch-name> [--detach]

WORKTREE_FOLDER=$1
BRANCH_NAME=$2
DETACH_MODE=$3

if [ -z "$WORKTREE_FOLDER" ] || [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <target-worktree-folder> <branch-name> [--detach]"
    exit 1
fi

if [ ! -d "$WORKTREE_FOLDER" ]; then
    echo "❌ Error: Directory '$WORKTREE_FOLDER' does not exist."
    exit 1
fi

if [ "$DETACH_MODE" = "--detach" ]; then
    echo "🔄 Syncing worktree '$WORKTREE_FOLDER' to branch '$BRANCH_NAME' (detached)..."
else
    echo "🔄 Syncing worktree '$WORKTREE_FOLDER' to branch '$BRANCH_NAME'..."
fi

cd "$WORKTREE_FOLDER" || exit

git fetch origin

if [ "$DETACH_MODE" = "--detach" ]; then
    # Detached mode
    git checkout --detach "$BRANCH_NAME"
else
    # Regular mode
    git checkout "$BRANCH_NAME"
    # Set upstream if not already set
    git branch --set-upstream-to=origin/"$BRANCH_NAME" "$BRANCH_NAME" 2>/dev/null || true
fi

# Best Practice: Re-link or update environment files here if needed,
# ln -sf ../.shared/.env .env

echo "✅ Worktree '$WORKTREE_FOLDER' is now at '$BRANCH_NAME' (Detached HEAD)."