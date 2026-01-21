# Git Worktree: The Persistent Studio Workflow

## Introduction to Git Worktree

**Git worktree** is a powerful feature that allows you to check out multiple branches of a single repository simultaneously into separate directories. Unlike the traditional "single-threaded" development process where you must `git stash` or commit unfinished work to switch branches, worktrees enable a **multi-threaded environment** where different tasks live in their own "parallel universes". 

## Key Advantages

*   **Instant Context Switching:** You can jump from a feature branch to an urgent hotfix or a peer’s pull request simply by changing directories (`cd`), leaving your main work undisturbed and "messy" if needed.
*   **No More Stashing:** There is no need to use `git stash` or commit half-baked code just to clear your working directory for a different branch.
*   **Parallel Execution:** You can run separate instances of your application (e.g., frontend and backend or two different branches) at the same time for side-by-side comparison.
*   **Clean History:** Because you don't have to make "checkpoint" commits just to switch branches, your commit history stays cleaner.

## The "Persistent Studio" Workflow

The **"Persistent Studio"** or mindset-based approach is a shift in how you organize these worktrees. Instead of creating a new temporary directory for every single feature—which can lead to "dependency hell" and disk space bloat—you maintain a few permanent directories categorized by the **type of work** you are doing:

1.  **`work/`**: For your active, primary feature development.
2.  **`review/`**: For inspecting and testing peer pull requests.
3.  **`hotfix/`**: For urgent production bugs.
4.  **`main/`**: A clean "read-only" copy of the main branch for quick reference.

By using a **bare repository** to house the Git database (`.bare/`), you keep your project root clean and avoid cluttering your working files with Git metadata.

### Why use Detached HEAD?

According to the sources, using `--detach` is the most effective way to manage multiple worktrees because:
*   **Flexibility:** You can point any worktree folder to any branch at any time without Git complaining that the branch is already in use elsewhere.
*   **Context Preservation:** You can leave your primary `work/` folder in a messy, uncommitted state while using `checkout.sh` on a `review/` folder to quickly inspect a teammate's PR,.
*   **Speed:** Since the directory (and its `node_modules` or dependencies) already exists, switching branches is nearly instant compared to a clean checkout and install,.

---

## Commands

To run these scripts, we use the `curl` command to fetch the **raw text content** from GitHub and pipe it into `bash`. We use the `-s` flag with `bash` followed by `--` to pass the required positional parameters to the script without them being interpreted as arguments for the shell itself.

#### 1. Clone a Bare Repository

This script initializes the project by cloning the Git database into a `.bare` directory and setting up the root `.git` pointer and `.shared` configuration folder.

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/clone-bare.sh | bash -s -- <git-url> <target-directory>
```

#### 2. Add a New Worktree

This script creates a new worktree folder at the specified path and checks out the desired branch in **detached mode** to maintain workflow flexibility.

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/add-worktree.sh | bash -s -- <target-worktree-folder> <branch-name>
```

#### 3. Sync or Checkout a Branch in an Existing Worktree

This script "teleports" an existing mindset-based worktree (like `review` or `scratch`) to a specific branch after fetching the latest changes from the remote origin.

```bash
curl -fsSL https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/checkout.sh | bash -s -- <target-worktree-folder> <branch-name>
```

### Alternative: Using wget
If `curl` is not available on your system, you can use `wget` to achieve the same result:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/fea-lib/scripts/refs/heads/main/add.sh) <target-worktree-folder> <branch-name>
```
*Note: Using the `<(command)` syntax (Process Substitution) allows the shell to treat the output of the download as a file path, which is sometimes more reliable for interactive scripts.*

### Running Git Worktree Automation Scripts from GitHub

This document provides sample commands for executing the **Git Worktree "Persistent Studio"** automation scripts directly from their remote GitHub repository.

#### ⚠️ Security Warning: Remote Code Execution (RCE)
Running scripts directly from a URL is a form of **Arbitrary Code Execution (ACE)**, meaning an attacker could potentially run any command of their choice on your machine if the source is compromised. These scripts run with your current user privileges, allowing them to modify files or access sensitive data. 

**Best Practices for Security:**
*   **Use Secure Flags:** Use `curl -fsSL` to ensure the download fails silently if the server returns an error, preventing the shell from executing an error page as code.
*   **Review Code:** Always download and inspect the script content locally before executing it.
*   **Verify Integrity:** Use a SHA256 checksum to validate the file before execution whenever possible.
