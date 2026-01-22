#!/bin/bash

# Parameters: ./clone.sh <git-url> <target-directory>
GIT_URL=$1
TARGET_DIR=$2

if [ -z "$GIT_URL" ] || [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <git-url> <target-directory>"
    exit 1
fi

echo "🚀 Initializing bare repository and Studio Workflow in: $TARGET_DIR"

# 1. Clone the bare repo into the target dir's .bare subfolder
# This keeps the Git database separate from your working files.
mkdir -p "$TARGET_DIR"
git clone --bare "$GIT_URL" "$TARGET_DIR/.bare"

# 2. Set up the root .git file pointer
# This allows Git commands to work from the project root.
echo "gitdir: ./.bare" > "$TARGET_DIR/.git"

# 3. Configure hooks path
# This tells Git to look for hooks in the .bare/hooks directory.
(cd "$TARGET_DIR" && git config core.hooksPath .bare/hooks)

# 4. Create a .shared directory
# This acts as the single source of truth for .env and other untracked files.
mkdir -p "$TARGET_DIR/.shared"

# 5. Create the post-checkout hook for automatic symlinking
# This hook runs every time a new worktree is created.
HOOK_PATH="$TARGET_DIR/.bare/hooks/post-checkout"

cat << 'EOF' > "$HOOK_PATH"
#!/bin/bash

# $1 is the previous HEAD, $2 is the new HEAD, $3 is a flag (1 for branch checkout).
# All zeros in $1 indicates a new worktree/checkout.
if [[ "$1" == "0000000000000000000000000000000000000000" ]]; then
    WORKTREE_DIR=$(pwd)
    # Locate the .shared directory (sibling to worktree folders)
    SHARED_DIR="$(dirname "$WORKTREE_DIR")/.shared"

    if [ -d "$SHARED_DIR" ]; then
        echo "🔗 Linking shared files from .shared to $WORKTREE_DIR..."
        
        # Iterate through files in .shared and create relative symlinks.
        find "$SHARED_DIR" -type f | while read -r src_file; do
            # Calculate the relative path from .shared to the file
            rel_path="${src_file#$SHARED_DIR/}"
            target_file="$WORKTREE_DIR/$rel_path"
            
            # Ensure the target subdirectory exists in the new worktree
            mkdir -p "$(dirname "$target_file")"
            
            # Create a symbolic link (pointer) to the shared file.
            ln -sf "$src_file" "$target_file"
            echo "   ✅ Linked $rel_path"
        done
    fi
fi
EOF

# Ensure the hook is executable
chmod +x "$HOOK_PATH"

echo "✅ Setup complete."
echo "   1. Place your .env or other config files in $TARGET_DIR/.shared"
echo "   2. Run 'git worktree add <folder-name>' to create your mindset-based worktrees."
echo "   3. Shared files will be automatically symlinked into the new worktrees."
