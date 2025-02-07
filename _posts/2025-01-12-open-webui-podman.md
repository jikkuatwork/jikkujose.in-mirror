---
layout: post
title: "Open WebUI + Podman"
excerpt: "Installing OpenWeb UI in Ubuntu using podman"
---

Installing [open webui](https://github.com/open-webui/open-webui) using Podman is a bit tricky, it requires different
configs from Docker.

```bash
podman run -d \
  --name open-webui \
  --network host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --restart=always \
  ghcr.io/open-webui/open-webui:main
```

## Why It Works

- Host network mode bypasses container networking complexity
- Direct access to host's network stack
- No port mapping needed - uses native 8080 port
- Ollama connectivity through localhost
- No DNS resolution issues

## Technical Requirements

- Access point: `http://localhost:8080`
- Ollama must be running on host port 11434
- Volume persistence at `/app/backend/data`
- Host network mode mandatory for reliable operation

## Pre-flight Checks

```bash
# Verify image exists
podman images | grep open-webui

# Check existing volumes
podman volume ls

# Verify Ollama is running
curl http://127.0.0.1:11434/api/tags
```

## Cleanup If Needed

```bash
# Remove existing container
podman rm -f open-webui

# Remove volume if reset needed
podman volume rm open-webui
```

## Implementation Notes

- Alternative networking modes (slirp4netns, bridge) fail
- Port forwarding unnecessary with host network
- Container restarts survive host reboots
- Volume persistence prevents data loss on container recreation

## Updating Open WebUI

```bash
# Stop and remove current container
podman stop open-webui
podman rm open-webui

# Pull latest image
podman pull ghcr.io/open-webui/open-webui:main

# Run container with same configuration
podman run -d \
  --name open-webui \
  --network host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --restart=always \
  ghcr.io/open-webui/open-webui:main
```

## Update Verification

```bash
# Check if container is running
podman ps

# Verify image timestamp
podman images | grep open-webui
```

The volume persistence ensures all your settings and data remain intact during updates.
