---
layout: post
title: "Supabase + Podman on macOS"
excerpt: "Local Supabase development without Docker"
---

[Supabase](https://supabase.com) is an open-source Firebase alternative
with Postgres, auth, storage, and edge functions. Local development
typically requires Docker Desktop, but
[Podman](https://podman.io) works as a drop-in replacement. Podman runs
containers without a daemon, supports rootless mode for better security,
and avoids Docker Desktop licensing. This guide covers the full setup on
Apple Silicon Macs.

## Install Podman

```bash
brew install podman

# Create VM with reasonable resources
podman machine init --cpus 4 --memory 8192 --disk-size 50

# Start it
podman machine start
```

The machine runs a lightweight Linux VM (Fedora CoreOS) using Apple's
Virtualization framework.

## Enable Docker Socket

Supabase CLI expects a Docker socket. `podman-mac-helper` creates the
symlink:

```bash
sudo podman-mac-helper install
podman machine stop && podman machine start
```

Verify:

```bash
ls -la /var/run/docker.sock
# Should show symlink to podman socket
```

## Install Supabase CLI

```bash
brew install supabase/tap/supabase
```

## Start a Project

```bash
mkdir my-project && cd my-project
supabase init
supabase start
```

First run pulls ~2GB of images. Subsequent starts are fast.

## Why It Works

- `podman-mac-helper` creates `/var/run/docker.sock` symlink
- Supabase CLI v2.13.6+ respects `DOCKER_HOST` properly
- Rootless mode works - no need for `--rootful`
- Apple Virtualization framework (applehv) handles containers

## Access Points

| Service  | URL                              |
|----------|----------------------------------|
| Studio   | http://127.0.0.1:54323           |
| API      | http://127.0.0.1:54321           |
| Postgres | postgres:postgres@127.0.0.1:54322 |
| Mailpit  | http://127.0.0.1:54324           |

## Pre-flight Checks

```bash
# Verify socket exists
ls -la /var/run/docker.sock

# Check podman machine status
podman machine list

# Test docker API compatibility
docker info 2>&1 | head -3
```

## Common Operations

```bash
# Stop services (preserves data)
supabase stop

# Stop and wipe
supabase stop --no-backup

# Reset database only
supabase db reset

# View running containers
podman ps

# Check service status
supabase status
```

## Cleanup If Needed

```bash
# Remove supabase containers
supabase stop --no-backup

# Nuclear: prune all podman data
podman system prune -a

# Remove project config
rm -rf supabase/
```

## Troubleshooting

### Socket Missing

```bash
sudo podman-mac-helper install
podman machine stop && podman machine start
```

### Storage Service Fails

Switch to rootful mode:

```bash
podman machine set --rootful
podman machine stop && podman machine start
```

Switch back later:

```bash
podman machine set --rootful=false
```

### Port Conflicts

```bash
lsof -nP -iTCP:54321 -iTCP:54322 -iTCP:54323
```

## Shell Aliases

```bash
# Add to ~/.zshrc
alias sb="supabase"
alias sbs="supabase start"
alias sbx="supabase stop"
alias sbl="supabase status"
```

## Implementation Notes

- First `supabase start` pulls ~2GB of images
- 12 containers run the full stack
- Rootless Podman works despite old GitHub issues claiming otherwise
- No `DOCKER_HOST` export needed with `podman-mac-helper`
- Rosetta translation handles x86 images on ARM

## Tested Configuration

- macOS 15.x on Apple Silicon
- Podman 5.6.x (applehv backend)
- Supabase CLI 2.65.x
- Rootless mode

The entire Supabase stack runs without Docker Desktop licensing concerns.
