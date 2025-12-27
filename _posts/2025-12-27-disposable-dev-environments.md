---
layout: post
title: "Disposable Dev Environments"
excerpt: "A three-layer isolation architecture for AI coding assistants"
---

In November 2025, Anthropic published [Disrupting AI-Enabled
Espionage][anthropic]—a detailed account of the first documented large-scale
cyberattack executed primarily through AI automation. Threat actors weaponized
Claude Code to compromise approximately thirty organizations across technology,
finance, chemical manufacturing, and government sectors. The attacks were
80-90% automated. Humans intervened at roughly 4-6 decision points per
operation while the AI handled reconnaissance, exploit development, credential
harvesting, and data exfiltration.

The attack surface wasn't a vulnerability in the model itself. It was the
capabilities that make AI assistants useful: the ability to follow complex
multi-step instructions, operate autonomously in execution loops, and interact
with filesystems and networks through tool integrations.

This presents a fundamental tension. AI coding assistants offer substantial
productivity gains—automated refactoring, test generation, dependency
management. But granting these tools unrestricted filesystem access creates
exposure that extends well beyond the immediate project.

[Dr. Anish Mohammed][@anish] frames a broader version of this problem in
[Security on Synthetic Biology][anish]. His analysis examines what happens when
AI systems gain access to physical infrastructure—laboratory equipment, DNA
sequencers, industrial controls. The same pattern emerges: capabilities that
enable legitimate use cases simultaneously enable misuse. And unlike human
operators, AI agents lack the self-preservation instincts that might cause them
to question dangerous instructions.

The question isn't whether to use AI coding tools. The productivity differential
is too significant. The question is how to contain the blast radius when
something goes wrong.

## Architecture

The approach is defense in depth: three layers of isolation, each limiting what
the next layer can access.

```
┌───────────────────────────────────────────────────────┐
│ macOS Host                                            │
│   - Credentials and SSH keys remain here              │
│   - Runs only the VM orchestration layer              │
│                                                       │
│  kodemachine start project                            │
│        │                                              │
│        ▼                                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Linux VM                                        │  │
│  │   - Development tools, GUI applications         │  │
│  │   - No access to host filesystem                │  │
│  │                                                 │  │
│  │  testman run agentman ~/code/project            │  │
│  │        │                                        │  │
│  │        ▼                                        │  │
│  │  ┌───────────────────────────────────────────┐  │  │
│  │  │ Ephemeral Container                       │  │  │
│  │  │   - AI assistants execute here            │  │  │
│  │  │   - Filesystem limited to project dir     │  │  │
│  │  │   - Syscall auditing enabled              │  │  │
│  │  └───────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┘
```

**Layer 1: Host.** The macOS host holds sensitive credentials—SSH keys, cloud
tokens, API secrets. It runs only [kodemachine][kodemachine], a VM orchestration
tool. No AI assistants execute here.

**Layer 2: Virtual Machine.** A Linux VM provides the development environment:
editors, browsers, GUI applications. It can access the network but not the host
filesystem. The VM runs [testman][testman] to manage containers.

**Layer 3: Container.** AI assistants run inside ephemeral containers with
filesystem access restricted to a single mounted project directory. Syscall
logging via strace provides an audit trail. Containers are destroyed after each
session.

An AI assistant operating in this environment cannot access `~/.ssh`, `~/.aws`,
or other projects. A compromised agent's blast radius is limited to one project
directory in one ephemeral container.

## Implementation

Three projects implement this architecture:

| Project | Function |
|---------|----------|
| [kodemachine][kodemachine] | VM lifecycle management via UTM |
| [testman][testman] | Container orchestration via Podman |
| [dotfiles][dotfiles] | Consistent configuration across all layers |

[dotfiles]: https://github.com/jikkujose/dotfiles
[kodemachine]: https://github.com/jikkuatwork/kodemachine
[testman]: https://github.com/jikkuatwork/testman

### VM Layer

Kodemachine manages Ubuntu VMs on macOS through UTM. Key characteristics:

- **APFS copy-on-write cloning.** Creating a new VM from the golden image takes
  under one second and consumes zero additional disk space until files change.

- **Headless operation.** VMs run as background processes without display
  overhead, enabling multiple concurrent instances.

- **QEMU guest agent integration.** Dynamic IP discovery eliminates static
  network configuration.

```bash
# One-time host setup
./setup-host.rb

# Create golden image (every ~6 months)
./create-base.rb --dotfiles git@github.com:user/dotfiles.git

# Daily workflow
kodemachine start project    # Clone, boot, SSH in
kodemachine suspend project  # Instant pause
kodemachine delete project   # Remove entirely
```

### Container Layer

Testman orchestrates Podman containers within the VM:

- **Ephemeral by default.** Every invocation creates a fresh container with
  `--rm`. No state accumulation.

- **Project isolation.** Each container mounts only its designated project
  directory.

- **Syscall auditing.** Optional strace logging captures all system calls for
  post-hoc analysis.

- **Multiple AI assistants.** Pre-configured sandboxes for Claude Code, Aider,
  Copilot, and others.

```bash
# Inside VM
cd ~/Projects/testman/sandboxes/agentman
./run.zsh --name project --workspace ~/code/project
```

## Design Constraints

**Stateless operation.** Shell history, REPL state, and editor sessions do not
persist. VMs and containers are disposable. Only the LUKS-encrypted shared disk
maintains code and credentials across sessions.

**Zero external dependencies.** All orchestration scripts use Ruby standard
library only—`json`, `fileutils`, `optparse`. No gem installation required.
Compatible with macOS system Ruby.

**Platform specificity.** This implementation targets macOS on Apple Silicon.
The architecture depends on APFS copy-on-write semantics and UTM's ARM64
virtualization. Linux hosts would require different tooling.

## Operational Considerations

**Network access.** Development servers inside the VM bind to `0.0.0.0` and are
accessible from the host at the VM's IP address.

**Parallel workloads.** Multiple VMs can run concurrently, each with isolated
containers. No dependency conflicts between projects.

**Recovery.** Serial console access via `kodemachine attach` provides debugging
capability when SSH fails.

**Iteration speed.** Destroying and recreating a VM takes seconds. There is no
cost to starting fresh.

## Conclusion

The capabilities that make AI coding assistants valuable—autonomous operation,
filesystem access, code execution—are precisely what make them dangerous when
compromised. Anthropic's documentation of AI-enabled attacks demonstrates this
is not a theoretical concern.

This three-layer architecture provides a practical response: use AI tools for
their productivity benefits while containing them to environments where a
worst-case compromise affects only a single project directory. The overhead is
minimal—VM cloning is instant, container startup takes seconds. The security
posture is substantially improved.

Development environments should boot fast, stay clean, and leave no trace when
deleted. They should also assume that any tool with code execution capability
is a potential attack vector and isolate accordingly.

[anthropic]: https://www.anthropic.com/news/disrupting-AI-espionage
[anish]: https://www.youtube.com/watch?v=3bMsWeWR7hI
[@anish]: https://x.com/anishmohammed
