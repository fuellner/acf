# Git

Load this before creating a branch or a worktree. This skill creates branches and worktrees. It does not commit, push, stage, merge, or rewrite history.

## Identity

Read the effective identity. Do not set it.

```
git var GIT_AUTHOR_IDENT
git var GIT_COMMITTER_IDENT
```

Each line is `Name <email> timestamp timezone`. Read the name and the email from both. This includes an identity supplied by the environment.

Do not run `git config` with a value for `user.name` or `user.email`. Do not pass those values on a command line, in an environment variable, or in a commit. Do not invent a name or an address.

Resolve the remote: the remote the current branch tracks, otherwise `origin`. Read it with `git remote get-url`.

Ask once and wait when any of these is true:

- either command fails, or either name or email is missing
- the author and committer names or emails differ
- the email has no domain
- the remote host is not a public forge and the email domain is a public mailbox
- the remote host is a public forge and the email domain is neither a public mailbox nor that forge's noreply domain
- the repository has another remote on a different host, and the email domain matches that other host but not the remote used for this branch

Matching a host means the host equals the email domain, or the host ends with `.` plus the email domain.

Public forge hosts, compared as lowercase hostnames without a port: `github.com`, `gitlab.com`, `bitbucket.org`, `codeberg.org`.

Noreply domains: `users.noreply.github.com` for `github.com`, `users.noreply.gitlab.com` for `gitlab.com`. `bitbucket.org` and `codeberg.org` have none recorded here, so a non-mailbox address on those hosts is asked.

Public mailbox domains: `gmail.com`, `googlemail.com`, `outlook.com`, `hotmail.com`, `live.com`, `yahoo.com`, `icloud.com`, `me.com`, `proton.me`, `protonmail.com`, `gmx.com`, `gmx.de`, `web.de`, `aol.com`.

Parse the host from the remote URL. For `scheme://...`, take the host after `://`, drop userinfo, and stop at `/` or `:`. For `user@host:path`, take the host between `@` and `:`.

After the user confirms an identity, continue. Still do not write the config. Do not copy the name or the address into the implementation log.

## Branch name

`dev/<KEY>-<short-kebab-title>`

`KEY` is chosen in this order:

1. The task's **Ticket** line, when it is exactly one ticket-shaped key. Use it. Do not ask.
2. A ticket-shaped key in the title or body that is not on the denylist. Show each remaining key and ask once to confirm. Use a key only after the user confirms it.
3. The task ID, when the line is absent and no confirmable key remains. Do not ask only because no ticket exists.

A ticket-shaped key has a project part of 2–10 characters, starting with an uppercase letter, the rest uppercase letters or digits, then a hyphen and a number.

Denylist, title and body only. Do not apply it to a **Ticket** line. Ignore a key whose project part is `TASK`, `REQ`, `REF`, `TEST`, `AC`, `PHP`, `UTF`, `SHA`, `ISO`, `HTTP`, `TLS`, `RFC`, `PSR`, `CVE`, or `MD`.

If the **Ticket** line is exactly this task's own ID, treat the line as absent and continue. If the line exists and is not exactly one ticket-shaped key, ask. Do not scan past it.

Do not invent a key. Do not call a tracker.

The slug is the task title in ASCII lowercase. Drop the key and the task ID. Turn other runs of non-letters and non-digits into one hyphen and trim hyphens. Keep at most six hyphen-separated words. If nothing remains, use `task`.

Keep the key's own casing. `dev/ABC-123-fix-login` and `dev/TASK-001-fix-login` are the shapes.

If that branch already exists, ask. Do not delete it. Resume uses the branch already recorded in the log.

## One task

Use the current worktree. Do not add a worktree.

Create the branch from the current commit with `git switch -c <branch>` when `git status --porcelain` is empty.

When the tree is dirty, list the paths from `git status --short` and ask once whether to carry them onto the new branch. Yes: `git switch -c <branch>`. No: stop. Do not stash, discard, or commit. A clean detached `HEAD` uses `git switch -c <branch>` from that commit. A dirty detached `HEAD` uses the same question.

When the log already records this branch and `HEAD` is that branch, keep it. That is a resume, including when the tree is dirty with this task's files.

## Several tasks

The base is `git rev-parse HEAD`. A worktree contains only files in that commit.

The task file for each selected task, and every test plan that task names, must already be in that commit. Check with `git cat-file -e <base>:<path>` and `git diff <base> -- <path>`. If a path is missing from the commit or differs from it, stop and ask the user to commit those files first. Do not commit them. Do not guess another base.

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
