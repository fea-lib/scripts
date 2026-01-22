#!/bin/sh
# setup.sh: Download git-worktree scripts locally and set up shell functions to use them

set -e

# Target directory for local scripts
TARGET_DIR="$HOME/.fea-scripts"
REPO_RAW_URL="https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree"
SCRIPTS="add.sh checkout.sh clone.sh"

mkdir -p "$TARGET_DIR"

# Download each script
for script in $SCRIPTS; do
  curl -fsSL "$REPO_RAW_URL/$script" -o "$TARGET_DIR/$script"
  chmod +x "$TARGET_DIR/$script"
done

# Function to append shell functions as real lines
append_shell_funcs() {
  cat <<EOF >> "$1"
# --- Added by git-worktree setup.sh ---
# --- Git Worktree Local Automation Functions ---

# 1. Clone a Bare Repository
gwt-clone() {
  bash "$TARGET_DIR/clone.sh" "\$1" "\$2"
}

# 2. Add a New Worktree (Detached Mode)
gwt-add() {
  bash "$TARGET_DIR/add.sh" "\$1" "\$2"
}

# 3. Sync/Checkout an Existing Worktree (Detached Mode)
gwt-checkout() {
  bash "$TARGET_DIR/checkout.sh" "\$1" "\$2"
}
EOF
}

CONFIG_FILES="$HOME/.zshrc $HOME/.bashrc $HOME/.profile $HOME/.bash_profile"
FOUND_ANY=0
for config in $CONFIG_FILES; do
  if [ -f "$config" ]; then
    append_shell_funcs "$config"
    echo "Shell functions were added to: $config"
    echo "Reload your shell config with: source $config"
    FOUND_ANY=1
  fi
done

if [ $FOUND_ANY -eq 0 ]; then
  echo "No common shell config file found. Please add the following to your shell configuration file manually:"
  append_shell_funcs /dev/stdout
  echo "Then reload your shell config with: source ~/.zshrc  or  source ~/.bashrc"
fi