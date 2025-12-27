---
layout: post
title: "Disposable Dev Environments"
excerpt: "Three-layer isolation: dotfiles + kodemachine + testman"
---

Development environments accumulate cruft. Package conflicts, stale configs,
orphaned dependencies. Docker helps but isn't always enough. Full VMs are clean
but slow to provision.

This is my solution: three projects that create disposable, reproducible
environments at every layer.

## The Stack

```
┌───────────────────────────────────────────────────────┐
│ macOS Host                                            │
│                                                       │
│  kodemachine start myproject                          │
│        │                                              │
│        ▼                                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Linux VM (APFS clone, boots in seconds)         │  │
│  │                                                 │  │
│  │  testman run kodeman ~/code/myproject           │  │
│  │        │                                        │  │
│  │        ▼                                        │  │
│  │  ┌───────────────────────────────────────────┐  │  │
│  │  │ Ephemeral Container                       │  │  │
│  │  │   └── Claude Code, neovim, your code      │  │  │
│  │  └───────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┘
```

Three layers of isolation. Each disposable. Each reproducible.

## The Projects

| Project | Purpose | Layer |
|---------|---------|-------|
| [dotfiles](https://github.com/jikkujose/dotfiles) | Universal config (zsh, fish, nvim, tmux) | All |
| [kodemachine](https://github.com/jikkuatwork/kodemachine) | VM orchestration via UTM | Host → VM |
| [testman](https://github.com/jikkuatwork/testman) | Container orchestration via Podman | VM → Container |

## Why Three Layers?

**VMs alone aren't enough.** Running AI coding assistants (Claude Code, Aider,
etc.) with full filesystem access inside my development VM felt risky. What if
they install malicious packages? Exfiltrate code?

**Containers alone aren't enough.** I wanted GUI apps (browsers, desktop) with
native ARM performance. Podman on macOS uses emulation. A Linux VM with Podman
gives native speed.

**Both together:** VM provides the OS and GUI. Container provides syscall-level
isolation for untrusted tools.

## Workflow

### One-Time Setup (per Mac)

```bash
cd ~/Projects/kodemachine
./setup-host.rb    # Installs UTM, qemu-img, symlinks
```

### Build Golden Image (every ~6 months)

```bash
# Minimal - SSH key auto-detected from ~/.ssh/id_ed25519.pub
./create-base.rb

# With dotfiles
./create-base.rb --dotfiles git@github.com:you/dotfiles.git
```

This provisions Ubuntu with XFCE, browsers, fonts, and optionally runs your
dotfiles bootstrap. The result is a golden image ready for instant cloning.

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

## Key Design Decisions

**Stateless by default.** No shell history, no REPL history, no editor state.
VMs and containers are disposable. Only the LUKS-encrypted shared disk persists
code and credentials.

**No gem dependencies.** All Ruby scripts use stdlib only (`json`, `fileutils`,
`optparse`). Works with macOS system Ruby.

**APFS copy-on-write.** Cloning a 64GB VM takes <1 second and uses zero
additional disk until files change.

**Ephemeral containers.** Every `testman run` creates a fresh container with
`--rm`. State is discarded. Config and logs persist via volume mounts.

## Why Now: AI Agents Are a Security Risk

This setup isn't paranoia - it's timely. In December 2025, Anthropic documented
the [first large-scale AI-orchestrated cyberattack][anthropic]. Threat actors
used Claude Code to compromise thirty organizations, accomplishing 80-90% of
the campaign through AI automation with minimal human involvement.

The attack exploited three AI capabilities: **intelligence** (following complex
instructions), **agency** (autonomous operation in loops), and **tools**
(filesystem and network access via MCP). The same capabilities that make AI
coding assistants useful make them dangerous when compromised.

Researchers like [Dr. Anish Mohammed][anish] warn about broader risks: LLMs
with access to lab equipment, sequencers, or critical infrastructure. Unlike
humans, LLMs aren't "suicidal" - they'll execute whatever instructions they're
given without self-preservation instincts limiting their actions.

The solution isn't to stop using AI tools - they're too useful. The solution is
**defense in depth**: isolate them so a compromised agent can't access your SSH
keys, cloud credentials, or other projects.

[anthropic]: https://www.anthropic.com/news/disrupting-AI-espionage
[anish]: https://www.youtube.com/watch?v=3bMsWeWR7hI

## Security Model

```
┌─────────────────────────────────────────┐
│ Host (macOS)                            │
│   - SSH keys for git                    │
│   - Kodemachine only                    │
└─────────────────────────────────────────┘
         │ SSH
         ▼
┌─────────────────────────────────────────┐
│ VM (Ubuntu)                             │
│   - Dotfiles, dev tools                 │
│   - Can browse, run GUI apps            │
│   - Testman orchestrates containers     │
└─────────────────────────────────────────┘
         │ Podman
         ▼
┌─────────────────────────────────────────┐
│ Container (ephemeral)                   │
│   - AI assistants run here              │
│   - Syscall auditing via strace         │
│   - Network isolated (optional)         │
│   - Filesystem limited to workspace     │
└─────────────────────────────────────────┘
```

AI tools get filesystem access only to the project directory. They can't read
`~/.ssh`, `~/.aws`, or other projects. Syscall logs capture everything they do.

## Practical Benefits

- **Host access:** Dev servers inside the VM are accessible from macOS at the
  VM's IP (bind to `0.0.0.0`, not localhost).

- **Fresh starts:** `kodemachine delete work && kodemachine start work` gives a
  pristine environment in seconds.

- **Parallel projects:** Run multiple VMs concurrently, each with isolated
  containers.

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

## Implementation Notes

- UTM provides the hypervisor, `utmctl` provides CLI control
- QEMU guest agent enables dynamic IP discovery
- Podman runs rootless inside VMs
- LUKS disk shared across VMs for persistent data
- All scripts are idempotent and safe to re-run

The goal: development environments that boot fast, stay clean, and leave no
trace when deleted.
