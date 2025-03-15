---
layout: post
title: "Container volume sharing in podman"
excerpt: "Volume sharing across container/host setup with read/write"
---

> Following are the notes from a Grok session.

Sharing a volume between a Podman container and host with read/write access and
a matching UID took some wrestling. Here’s how I got it working on Ubuntu with a
custom Podman install.

```bash
/usr/local/bin/podman run \
  -it \
  --runtime runc \
  --userns=keep-id \
  -v ~/Projects/anon-kode/playground:/home/playground:rw,Z \
  --user 1000:1000 \
  -w /home/playground \
  -e HOME=/home/playground \
  --entrypoint /bin/zsh \
  localhost/anon-kode-dev:latest
```

# Why It Works

- `--userns=keep-id` maps container UID to host UID (1000 for me)
- `--user 1000:1000` runs container as my host user
- `:rw,Z` on volume enables read/write and SELinux handling
- Custom Podman path respects my setup
- `--entrypoint /bin/zsh` lands me in zsh cleanly

# Technical Requirements

- Host UID/GID: 1000:1000 (verify with `id -u && id -g`)
- Volume: `~/Projects/anon-kode/playground` ↔ `/home/playground`
- Podman: 5.4.1 (custom at `/usr/local/bin/podman`)
- Runtime: runc (crun was flaky)
- Image: Custom-built from Containerfile

# Pre-flight Checks

```bash
# Check Podman binary
which podman  # Expect /usr/local/bin/podman

# Verify UID/GID
id -u && id -g  # Should be 1000:1000

# Confirm volume dir
ls -ld ~/Projects/anon-kode/playground

# Check image
podman images | grep anon-kode-dev
```

# The Containerfile

Building the image was a slog—network timeouts and runtime errors hit hard. Here’s the final version:

```dockerfile
# Stage 1: Builder
FROM docker.io/library/ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y git curl \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libncurses5-dev \
    libncursesw5-dev xz-utils tk-dev libffi-dev \
    liblzma-dev python3-openssl && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 1000 satoshi
USER satoshi
WORKDIR /home/satoshi
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf \
    --branch v0.14.0 && echo ". $HOME/.asdf/asdf.sh" >> \
    ~/.bashrc && bash -c ". $HOME/.asdf/asdf.sh && \
    asdf plugin add nodejs \
    https://github.com/asdf-vm/asdf-nodejs.git && \
    asdf plugin add python && asdf install nodejs 18.19.1 && \
    asdf install nodejs 21.7.1 && asdf install python 3.11.0 && \
    echo 'nodejs 18.19.1' >> ~/.tool-versions && \
    echo 'python 3.11.0' >> ~/.tool-versions && \
    asdf global nodejs 18.19.1"
RUN git clone https://github.com/jikkujose/dotfiles.git \
    ~/dotfiles && cd ~/dotfiles && git checkout v-2023

# Stage 2: Runtime
FROM docker.io/library/ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y curl neovim zsh && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 1000 satoshi
USER satoshi
WORKDIR /home/satoshi
COPY --from=builder /home/satoshi/.asdf /home/satoshi/.asdf
COPY --from=builder /home/satoshi/dotfiles /home/satoshi/dotfiles
RUN echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc && \
    echo ". $HOME/.asdf/asdf.sh" >> ~/.zshrc
RUN mkdir -p ~/.config && ln -s ~/dotfiles/nvim/fresh \
    ~/.config/nvim
RUN mkdir -p ~/.local/share/nvim/site/autoload && \
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim \
    --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN chsh -s /bin/zsh satoshi || true
WORKDIR /home/satoshi/playground
ENTRYPOINT ["zsh", "-c", "source ~/.zshrc && zsh"]
```

Build it:
```bash
/usr/local/bin/podman build --runtime runc -t \
    localhost/anon-kode-dev:latest .
```

# Cleanup If Needed

```bash
# Remove container
podman rm -f anon-kode

# Rebuild image
podman rmi localhost/anon-kode-dev:latest
podman build --runtime runc -t localhost/anon-kode-dev:latest .
```

# Implementation Notes

- UID mapping was a beast—rootless Podman mapped 1000 to 100999
- `--userns=keep-id` saved the day for direct UID matching
- Crun (v0.17) errored out; runc was the fix
- Volume needs `:Z` for SELinux, `:rw` for basic access

# Insights & Nuances

| Issue                | Fix                         | Note                     |
|----------------------|-----------------------------|--------------------------|
| UID 100999           | `--userns=keep-id`          | Maps 1000 to 1000        |
| Crun errors          | `--runtime runc`            | Old crun (0.17) buggy    |
| Volume perms         | Pre-chown or keep-id        | Avoids post-run chown    |
| Zsh entrypoint       | `--entrypoint /bin/zsh`     | Bypasses .zshrc issues   |

- Custom Podman might ignore system `/etc/subuid`—check `podman info`
- Rootless mode offsets UIDs unless overridden
- Test connectivity before builds with heavy downloads

# Verification

```bash
# Check container
podman ps -a | grep anon-kode

# Verify ownership
touch ~/Projects/anon-kode/playground/host.txt
podman run ...  # Full command above
lll ~/Projects/anon-kode/playground/test.txt  # Expect 1000
```

Files stay editable both ways—victory after a UID mapping saga!
