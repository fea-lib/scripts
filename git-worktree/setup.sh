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

# Shell function definitions
SHELL_FUNCS="\n# --- Git Worktree Local Automation Functions ---\n\n# 1. Clone a Bare Repository\ngwt-clone() {\n  bash \"$TARGET_DIR/clone.sh\" \"$1\" \"$2\"\n}\n\n# 2. Add a New Worktree (Detached Mode)\ngwt-add() {\n  bash \"$TARGET_DIR/add.sh\" \"$1\" \"$2\"\n}\n\n# 3. Sync/Checkout an Existing Worktree (Detached Mode)\ngwt-checkout() {\n  bash \"$TARGET_DIR/checkout.sh\" \"$1\" \"$2\"\n}\n"

# Try to detect the user's shell config file
CONFIG_FILES="$HOME/.zshrc $HOME/.bashrc $HOME/.profile $HOME/.bash_profile"
FOUND_ANY=0
for config in $CONFIG_FILES; do
  if [ -f "$config" ]; then
    printf "\n# --- Added by git-worktree setup.sh ---\n" >> "$config"
    printf "%s\n" "$SHELL_FUNCS" >> "$config"
    echo "Shell functions were added to: $config"
    echo "Reload your shell config with: source $config"
    FOUND_ANY=1
  fi
done

if [ $FOUND_ANY -eq 0 ]; then
  echo "No common shell config file found. Please add the following to your shell configuration file manually:"
  echo "$SHELL_FUNCS"
  echo "Then reload your shell config with: source ~/.zshrc  or  source ~/.bashrc"
fi
