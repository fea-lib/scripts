# Git Worktree: The Persistent Studio Workflow

- [Introduction to Git Worktree](#introduction-to-git-worktree)
- [Key Advantages](#key-advantages)
- [The "Persistent Studio" Workflow](#the-persistent-studio-workflow)
  - [Why use Detached HEAD?](#why-use-detached-head)
- [Commands](#commands)
  - [Alternative: Using wget](#alternative-using-wget)
  - [⚠️ Security Warning: Remote Code Execution (RCE)](#️-security-warning-remote-code-execution-rce)
- [Shell Functions](#shell-functions)
  - [Step 1: Open Your Shell Configuration File](#step-1-open-your-shell-configuration-file)
  - [Step 2: Copy and Paste the Functions](#step-2-copy-and-paste-the-functions)
  - [Step 3: Save and Exit](#step-3-save-and-exit)
  - [Step 4: Reload Your Configuration](#step-4-reload-your-configuration)
  - [Usage Instructions](#usage-instructions)
  - [Verification Tip](#verification-tip)
- [Optional: Setup files locally](#optional-setup-files-locally)
  - [Verification Tip](#verification-tip-1)

## Introduction to Git Worktree

**Git worktree** is a powerful feature that allows you to check out multiple branches of a single repository simultaneously into separate directories. Unlike the traditional "single-threaded" development process where you must `git stash` or commit unfinished work to switch branches, worktrees enable a **multi-threaded environment** where different tasks live in their own "parallel universes".

## Key Advantages

- **Instant Context Switching:** You can jump from a feature branch to an urgent hotfix or a peer’s pull request simply by changing directories (`cd`), leaving your main work undisturbed and "messy" if needed.
- **No More Stashing:** There is no need to use `git stash` or commit half-baked code just to clear your working directory for a different branch.
- **Parallel Execution:** You can run separate instances of your application (e.g., frontend and backend or two different branches) at the same time for side-by-side comparison.
- **Clean History:** Because you don't have to make "checkpoint" commits just to switch branches, your commit history stays cleaner.

## The "Persistent Studio" Workflow

The **"Persistent Studio"** or mindset-based approach is a shift in how you organize these worktrees. Instead of creating a new temporary directory for every single feature—which can lead to "dependency hell" and disk space bloat—you maintain a few permanent directories categorized by the **type of work** you are doing:

1.  **`work/`**: For your active, primary feature development.
2.  **`review/`**: For inspecting and testing peer pull requests.
3.  **`hotfix/`**: For urgent production bugs.
4.  **`main/`**: A clean "read-only" copy of the main branch for quick reference.

By using a **bare repository** to house the Git database (`.bare/`), you keep your project root clean and avoid cluttering your working files with Git metadata.

### Why use Detached HEAD?

In the "Persistent Studio" workflow, using `--detach` is central to maintaining a flexible, mindset-driven environment. Detached HEAD mode allows each permanent worktree (like `work/`, `review/`, or `hotfix/`) to freely switch between branches as your focus shifts, without the usual Git restrictions. This approach offers:

- **Maximum Flexibility:** Instantly repurpose any worktree folder for any branch, at any time, without Git blocking you because a branch is "already checked out" elsewhere.
- **Seamless Context Switching:** Keep your main `work/` directory in progress—even with uncommitted changes—while using `checkout.sh` to quickly review a teammate's PR or address a hotfix in another folder.
- **Efficiency:** Since dependencies and build artifacts remain in place, switching branches in an existing worktree is nearly instant, eliminating the overhead of repeated installs or setup.

## Commands

To run these scripts, we use the `curl` command to fetch the **raw text content** from GitHub and pipe it into `bash`. We use the `-s` flag with `bash` followed by `--` to pass the required positional parameters to the script without them being interpreted as arguments for the shell itself.

#### 1. Clone a Bare Repository

This script initializes the project by cloning the Git database into a `.bare` directory and setting up the root `.git` pointer and `.shared` configuration folder.

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/clone.sh | bash -s -- <git-url> <target-directory>
```

#### 2. Add a New Worktree

This script creates a new worktree folder at the specified path and checks out the desired branch in **detached mode** to maintain workflow flexibility.

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/add.sh | bash -s -- <target-worktree-folder> <branch-name>
```

#### 3. Sync or Checkout a Branch in an Existing Worktree

This script "teleports" an existing mindset-based worktree (like `review` or `scratch`) to a specific branch after fetching the latest changes from the remote origin.

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/checkout.sh | bash -s -- <target-worktree-folder> <branch-name>
```

### Alternative: Using wget

If `curl` is not available on your system, you can use `wget` to achieve the same result:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/add.sh) <target-worktree-folder> <branch-name>
```

_Note: Using the `<(command)` syntax (Process Substitution) allows the shell to treat the output of the download as a file path, which is sometimes more reliable for interactive scripts._

### ⚠️ Security Warning: Remote Code Execution (RCE)

Running scripts directly from a URL is a form of **Arbitrary Code Execution (ACE)**, meaning an attacker could potentially run any command of their choice on your machine if the source is compromised. These scripts run with your current user privileges, allowing them to modify files or access sensitive data.

**Best Practices for Security:**

- **Use Secure Flags:** Use `curl -fsSL` to ensure the download fails silently if the server returns an error, preventing the shell from executing an error page as code.
- **Review Code:** Always download and inspect the script content locally before executing it.
- **Verify Integrity:** Use a SHA256 checksum to validate the file before execution whenever possible.

## Shell Functions

This guide provides instructions on how to create persistent shell functions to run your worktree automation scripts directly from GitHub. Using **shell functions** instead of aliases is required for these tasks because aliases cannot handle positional arguments (like directory names or branch names), while functions allow you to pass dynamic values directly to the scripts.

### Step 1: Open Your Shell Configuration File

To make these commands persistent, you must add them to the configuration file that your shell loads every time you open a new terminal window.

- **For Zsh (Default on macOS):** Use `nano ~/.zshrc`.
- **For Bash:** Use `nano ~/.bashrc`.
- **For Warp:** Warp uses your machine's underlying shell (usually Zsh or Bash). Follow the instructions for the shell currently active in your Warp terminal.

### Step 2: Copy and Paste the Functions

Scroll to the bottom of the file and paste the following block of code. These functions use the `bash -s --` syntax to ensure your local arguments are passed correctly to the remote script.

```bash
# --- Git Worktree Automation Functions ---

# 1. Clone a Bare Repository
gwt-clone() {
  curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/clone-bare.sh | bash -s -- "$1" "$2"
}

# 2. Add a New Worktree (Detached Mode)
gwt-add() {
  curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/add.sh | bash -s -- "$1" "$2"
}

# 3. Sync/Checkout an Existing Worktree (Detached Mode)
gwt-checkout() {
  curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/checkout.sh | bash -s -- "$1" "$2"
}
```

- **`curl -fsSL`**: These flags ensure the command fails silently if the URL is wrong, preventing your shell from executing a 404 error page.
- **`"$1" "$2"`**: These are positional parameters that represent the inputs you type after the command.

### Step 3: Save and Exit

1.  In the Nano editor, press **`Ctrl + O`** then **`Enter`** to save the file.
2.  Press **`Ctrl + X`** to exit the editor.

### Step 4: Reload Your Configuration

For the changes to take effect in your current terminal session, run the **`source`** command:

```bash
# If using Zsh
source ~/.zshrc

# If using Bash
source ~/.bashrc
```

### Usage Instructions

You can now use these short commands from any directory in your terminal.

**To clone a project:**
`gwt-clone <git-url> <target-directory>`

**To create a new mindset folder (e.g., 'work'):**
`gwt-add work <branch-name>`

**To teleport an existing folder (e.g., 'review') to a new branch:**
`gwt-checkout review <branch-name>`

### Verification Tip

You can verify that a function is correctly loaded by typing `which <function-name>` (e.g., `which gwt-add`). The terminal should display the code block for that function.

## Optional: Setup files locally

If you prefer to use the git-worktree scripts from your local machine (for speed, offline use, or security), you can set up everything with a single command. This will:

- Download the latest versions of the scripts (`add.sh`, `checkout.sh`, `clone.sh`) into `~/.fea-scripts/`
- Print out shell functions you can add to your shell config, so you can use `gwt-clone`, `gwt-add`, and `gwt-checkout` with your local scripts

**To set up locally, run:**

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/git-worktree/setup.sh | bash
```

### Verification Tip

You can verify that a function is correctly loaded by typing `which <function-name>` (e.g., `which gwt-add`). The terminal should display the code block for that function.
