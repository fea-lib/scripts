#!/bin/bash
# Usage: ./add.sh <target-worktree-folder> <branch-name>

WORKTREE_FOLDER=$1
BRANCH_NAME=$2

# Validate that both parameters are provided [3]
if [ -z "$WORKTREE_FOLDER" ] || [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <target-worktree-folder> <branch-name>"
    exit 1
fi

echo "📂 Creating new worktree in '$WORKTREE_FOLDER' at branch '$BRANCH_NAME'..."

# The script is run from the root of the repo, so `pwd` is the git root.
GIT_ROOT=$(pwd)

# Create the worktree in detached mode,
# This prevents the branch from being "locked" to this specific folder.
git worktree add --detach "$WORKTREE_FOLDER" "$BRANCH_NAME"

echo "✅ Worktree created. Navigating to directory..."
cd "$WORKTREE_FOLDER" || exit

# Run the post-add script to link shared files.
POST_ADD_SCRIPT="$GIT_ROOT/.scripts/post-add.sh"
if [ -f "$POST_ADD_SCRIPT" ]; then
    echo "🚀 Running post-add script..."
    # Pass the absolute path to the worktree directory
    /bin/bash "$POST_ADD_SCRIPT" "$GIT_ROOT/$WORKTREE_FOLDER"
else
    echo "⚠️ Post-add script not found at $POST_ADD_SCRIPT"
fi