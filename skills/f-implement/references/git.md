# Git

Load this before creating a branch or a worktree. This skill creates branches and worktrees. It does not commit, push, stage, merge, or rewrite history.

## Identity

Read the effective identity. Do not set it.

```
git config --get user.name
git config --get user.email
```

Do not run `git config` with a value for `user.name` or `user.email`. Do not pass those values on a command line, in an environment variable, or in a commit. Do not invent a name or an address.

Resolve the remote: the remote the current branch tracks, otherwise `origin`. Read it with `git remote get-url`.

Ask once and wait when any of these is true:

- `user.name` or `user.email` is missing
- the email has no domain
- the remote host is not a public forge and the email domain is a public mailbox
- the repository has another remote on a different host, and the email domain matches that other host but not the remote used for this branch

Matching a host means the host equals the email domain, or the host ends with `.` plus the email domain.

Public forge hosts, compared as lowercase hostnames without a port: `github.com`, `gitlab.com`, `bitbucket.org`, `codeberg.org`.

Public mailbox domains: `gmail.com`, `googlemail.com`, `outlook.com`, `hotmail.com`, `live.com`, `yahoo.com`, `icloud.com`, `me.com`, `proton.me`, `protonmail.com`, `gmx.com`, `gmx.de`, `web.de`, `aol.com`.

Parse the host from the remote URL. For `scheme://...`, take the host after `://`, drop userinfo, and stop at `/` or `:`. For `user@host:path`, take the host between `@` and `:`.

A work address on a public forge is not itself a mismatch. After the user confirms an identity, continue. Still do not write the config. Do not copy the name or the address into the implementation log.

## Branch name

`dev/<KEY>-<short-kebab-title>`

`KEY` is the first of these that yields exactly one key:

1. The task's **Ticket** line
2. One ticket-shaped key in the title or body
3. The task ID

A ticket-shaped key has a project part of two to ten characters (an uppercase letter, then uppercase letters or digits), a hyphen, and a number. In the title and body, ignore a key whose project part is `TASK`, `REQ`, `REF`, `TEST`, or `AC`. Do not apply that ignore list to a **Ticket** line. If the **Ticket** line is exactly this task's own ID, treat the line as absent and continue. If the line exists and is anything else that is not exactly one ticket-shaped key, ask. Do not scan past it.

Several keys in the title or body, and no **Ticket** line: ask which one. Do not invent a key. Do not call a tracker. Do not ask only because no ticket exists; use the task ID.

The slug is the task title in ASCII lowercase. Drop the key and the task ID. Turn other runs of non-letters and non-digits into one hyphen and trim hyphens. Keep at most six hyphen-separated words. If nothing remains, use `task`.

Keep the key's own casing. `dev/ABC-123-fix-login` and `dev/TASK-001-fix-login` are the shapes.

If that branch already exists, ask. Do not delete it. Resume uses the branch already recorded in the log.

## One task

Use the current worktree. Do not add a worktree.

Create the branch from the current commit with `git checkout -b <branch>` only when `git status --porcelain` is empty and `HEAD` is not detached. A dirty tree, a detached `HEAD`, or a current branch that already holds other work: ask. Do not move those changes onto the new branch and do not discard them.

When the log already records this branch and `HEAD` is that branch, keep it. That is a resume, including when the tree is dirty with this task's files.

## Several tasks

Record the base with `git rev-parse HEAD` while the current tree is clean. A dirty tree: ask for the base commit. Do not guess one.

For each task:

```
git worktree add -b <branch> <path> <base>
```

`<path>` is a sibling of the repository: the parent of `git rev-parse --show-toplevel`, then the repository directory name, a hyphen, and the task ID. If that path exists, ask for another path outside the repository. Do not place a worktree inside the repository.

Each task has its own branch. Do not add a worktree without `-b`.

Do not run `git worktree remove`, `git worktree prune`, or delete a worktree directory.

## Diff and commit message

Show the change with `git status --short`, `git diff --stat`, and `git diff`. Run them inside the worktree that holds the task. Do not `git add`. List untracked files from the status output and read them when the summary needs their contents.

Suggest one Conventional Commits message per task. Do not run it.

```
<type>(<scope>): <imperative summary>

<TASK-ID>
```

`type` is `feat`, `fix`, `refactor`, `test`, `docs`, or `chore`, from the change. `scope` is the ticket key when the key is not the task ID; otherwise a short area from the title. No secret and no file dump.
