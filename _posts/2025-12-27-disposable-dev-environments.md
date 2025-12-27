---
layout: post
title: "Disposable Dev Environments"
excerpt: "Three-layer isolation for safely running AI coding assistants"
---

AI coding assistants have changed how I work. Claude Code, Aider, Copilot—they
write code, refactor functions, run tests, install packages. The productivity
gains are real. But so are the risks.

In December 2025, Anthropic published a sobering report: [Disrupting
AI-Enabled Espionage][anthropic]. Threat actors had weaponized Claude Code to
compromise thirty organizations. The attacks were 80-90% automated—humans only
intervened at a handful of decision points. The AI handled reconnaissance,
wrote exploits, harvested credentials, and exfiltrated data.

What made this possible? The same capabilities that make AI assistants useful:
the intelligence to follow complex instructions, the agency to operate
autonomously, and the tools to access filesystems and networks.

As [Dr. Anish Mohammed][@anish] explores in his talk [Security on Synthetic
Biology][anish], these risks extend beyond cyber attacks. When AI systems gain
access to physical infrastructure—lab equipment, sequencers, industrial
controls—the attack surface expands dramatically. Unlike humans, AI agents have
no self-preservation instinct. They'll execute whatever instructions they
receive, including instructions from attackers who've found ways to manipulate
them.

The answer isn't to stop using AI tools. They're too valuable. The answer is
**isolation**—defense in depth that limits what a compromised agent can access.

This is my solution: three projects that create disposable, isolated
environments where AI assistants can operate without access to my SSH keys,
cloud credentials, or other projects.

## The Architecture

```
┌───────────────────────────────────────────────────────┐
│ macOS Host                                            │
│   - SSH keys, credentials stay here                   │
│   - Only runs kodemachine                             │
│                                                       │
│  kodemachine start myproject                          │
│        │                                              │
│        ▼                                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Linux VM (APFS clone, boots in seconds)         │  │
│  │   - Development tools, browsers, GUI            │  │
│  │   - No access to host filesystem                │  │
│  │                                                 │  │
│  │  testman run kodeman ~/code/myproject           │  │
│  │        │                                        │  │
│  │        ▼                                        │  │
│  │  ┌───────────────────────────────────────────┐  │  │
│  │  │ Ephemeral Container                       │  │  │
│  │  │   - AI assistants run here                │  │  │
│  │  │   - Filesystem limited to project         │  │  │
│  │  │   - Syscall auditing via strace           │  │  │
│  │  └───────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┘
```

Three layers. Each disposable. Each limiting what the next layer can access.

## The Projects

| Project | Purpose | Layer |
|---------|---------|-------|
| [dotfiles][dotfiles] | Universal config (zsh, fish, nvim, tmux) | All |
| [kodemachine][kodemachine] | VM orchestration via UTM | Host → VM |
| [testman][testman] | Container orchestration via Podman | VM → Container |

[dotfiles]: https://github.com/jikkujose/dotfiles
[kodemachine]: https://github.com/jikkuatwork/kodemachine
[testman]: https://github.com/jikkuatwork/testman

## Why Three Layers?

**VMs alone aren't enough.** Running AI assistants with full filesystem access
inside a development VM still felt risky. A compromised agent could install
malicious packages, exfiltrate code, or pivot to other projects on the same
machine.

**Containers alone aren't enough.** I wanted GUI apps—browsers, desktop
environments—with native ARM performance. Podman on macOS uses emulation. A
Linux VM with Podman gives native speed plus proper isolation.

**Both together:** The VM provides the OS, GUI, and a boundary from the host.
The container provides syscall-level isolation for untrusted tools. Even if an
AI agent is compromised, it can only access the specific project directory
mounted into its container.

## The Workflow

### One-Time Setup

```bash
cd ~/Projects/kodemachine
./setup-host.rb    # Installs UTM, qemu-img, symlinks
```

### Build Golden Image (every ~6 months)

```bash
# SSH key auto-detected from ~/.ssh/id_ed25519.pub
./create-base.rb

# With dotfiles
./create-base.rb --dotfiles git@github.com:you/dotfiles.git
```

This provisions Ubuntu with XFCE, browsers, fonts, and optionally bootstraps
your dotfiles. The result is a golden image ready for instant cloning.

### Daily Use

```bash
# Create/start VM (APFS clone, <5 seconds)
kodemachine start work

# Inside VM: run AI assistant in isolated container
cd ~/Projects/testman/sandboxes/kodeman
./run.zsh --name myproject --workspace ~/code/myproject

# Done for the day
kodemachine suspend work   # Instant pause
```

## Security Model

The isolation is deliberate:

- **Host (macOS):** Holds SSH keys and cloud credentials. Only runs
  kodemachine. Never exposed to AI tools directly.

- **VM (Ubuntu):** Development environment with browsers and GUI apps. Can
  access the network but not the host filesystem. Runs testman to orchestrate
  containers.

- **Container (ephemeral):** Where AI assistants actually execute. Filesystem
  access limited to the mounted project directory. Syscall logging via strace
  captures everything the agent does. Destroyed after each session.

An AI assistant running in this setup cannot read `~/.ssh`, `~/.aws`, or browse
other projects. If it's compromised, the blast radius is limited to one project
directory in one ephemeral container.

## Design Decisions

**Stateless by default.** No shell history, no REPL history, no editor state
persists. VMs and containers are disposable. Only the LUKS-encrypted shared
disk persists code and credentials between sessions.

**No gem dependencies.** All Ruby scripts use stdlib only. Works with macOS
system Ruby out of the box.

**APFS copy-on-write.** Cloning a 64GB VM takes under a second and uses zero
additional disk space until files actually change.

**Ephemeral containers.** Every `testman run` creates a fresh container with
`--rm`. State is discarded. Config and logs persist via volume mounts.

## Practical Benefits

Beyond security, this setup has everyday advantages:

- **Fresh starts:** `kodemachine delete work && kodemachine start work` gives a
  pristine environment in seconds.

- **Parallel projects:** Run multiple VMs concurrently, each with isolated
  containers. No dependency conflicts.

- **Host access:** Dev servers inside the VM are accessible from macOS at the
  VM's IP.

- **Portable config:** Same dotfiles work on Mac, Linux, servers, and inside
  containers.

- **Debuggable:** Serial console via `kodemachine attach` when SSH fails.

## Trade-offs

- **macOS only:** Kodemachine uses UTM and APFS. Linux hosts would need
  different tooling.

- **ARM64 focus:** Optimized for Apple Silicon. Intel Macs work but with less
  testing.

- **Learning curve:** Three projects to understand. But each is single-purpose
  and documented.

## The Goal

Development environments that boot fast, stay clean, isolate AI tools from
sensitive data, and leave no trace when deleted.

The productivity benefits of AI coding assistants are too significant to
ignore. But after reading Anthropic's report on AI-enabled attacks, running
these tools with unrestricted access to my filesystem feels reckless. This
three-layer approach lets me use them confidently—knowing that even in the
worst case, the damage is contained.

[anthropic]: https://www.anthropic.com/news/disrupting-AI-espionage
[anish]: https://www.youtube.com/watch?v=3bMsWeWR7hI
[@anish]: https://x.com/anishmohammed
