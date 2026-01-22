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

# 5. Create the post-add script for automatic symlinking
# This script runs every time a new worktree is added.
SCRIPTS_DIR="$TARGET_DIR/.scripts"
mkdir -p "$SCRIPTS_DIR"
POST_ADD_SCRIPT_PATH="$SCRIPTS_DIR/post-add.sh"

cat << 'EOF' > "$POST_ADD_SCRIPT_PATH"
#!/bin/bash

WORKTREE_DIR=$1

if [ -z "$WORKTREE_DIR" ]; then
    echo "Usage: $0 <worktree-directory>"
    exit 1
fi

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
else
    echo "$SHARED_DIR is not a directory. Skipping shared file linking."
fi
EOF

# Ensure the script is executable
chmod +x "$POST_ADD_SCRIPT_PATH"

echo "✅ Setup complete."
echo "   1. Place your .env or other config files in $TARGET_DIR/.shared"
echo "   2. Run 'git worktree add <folder-name>' to create your mindset-based worktrees."
echo "   3. Shared files will be automatically symlinked into the new worktrees."
