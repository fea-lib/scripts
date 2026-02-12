
#!/bin/bash
# Usage: ./add.sh <target-worktree-folder> <branch-name> [--detach]

# Parse arguments
WORKTREE_FOLDER=$1
BRANCH_NAME=$2
DETACH_MODE=$3

# Validate that both parameters are provided
if [ -z "$WORKTREE_FOLDER" ] || [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <target-worktree-folder> <branch-name> [--detach]"
    exit 1
fi

if [ "$DETACH_MODE" = "--detach" ]; then
    echo "📂 Creating new worktree in '$WORKTREE_FOLDER' at branch '$BRANCH_NAME' (detached)..."
else
    echo "📂 Creating new worktree in '$WORKTREE_FOLDER' at branch '$BRANCH_NAME'..."
fi

# The script is run from the root of the repo, so `pwd` is the git root.
GIT_ROOT=$(pwd)

if [ "$DETACH_MODE" = "--detach" ]; then
    # Detached mode
    git worktree add --detach "$WORKTREE_FOLDER" "$BRANCH_NAME"
else
    # Regular mode (with branch tracking)
    git worktree add "$WORKTREE_FOLDER" "$BRANCH_NAME"
    # Set upstream if not already set
    (cd "$WORKTREE_FOLDER" && git branch --set-upstream-to=origin/"$BRANCH_NAME" "$BRANCH_NAME" 2>/dev/null || true)
fi

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