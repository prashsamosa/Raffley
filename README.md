# Raffley

## Getting Started (Dev Mode)

To start your Phoenix server:
1. Run `Docker Compose Up` for Postgres.
2. Run `mix setup` to install and set up dependencies.
3. Start the Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production Deployment

Ready to run in production? Please [check deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### docker-compose.yaml

```yaml
services:
  elixir:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ..:/workspace:cached
      - /var/run/docker.sock:/var/run/docker.sock
    network_mode: service:db
    command: sleep infinity

  db:
    image: postgres:latest
    restart: unless-stopped
    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app

volumes:
  postgres-data:
```

### Dockerfile

```dockerfile
FROM elixir:1.18

# Set build arguments
ARG INSTALL_ZSH="true"
ARG INSTALL_OH_MYS="true"
ARG UPGRADE_PACKAGES="true"
ARG ADDITIONAL_PACKAGES="inotify-tools postgresql-client npm docker.io iputils-ping dnsutils telnet libwxgtk3.2-dev libgtk-3-0 x11-xserver-utils chromium chromium-driver direnv watchman"

# Install additional packages
RUN apt-get update && apt-get install -y $ADDITIONAL_PACKAGES && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and run common-debian.sh script
RUN curl -sSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh -o /tmp/common-debian.sh && \
  chmod +x /tmp/common-debian.sh && \
  /tmp/common-debian.sh "${INSTALL_ZSH}" "vscode" "1000" "1000" "${UPGRADE_PACKAGES}" "${INSTALL_OH_MYS}" && \
  rm /tmp/common-debian.sh

# Docker socket access - handle both docker group and root group cases
RUN groupadd -g 999 docker || true && \
  usermod -aG docker vscode && \
  usermod -aG root vscode

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g npm@latest

# Install Hex, Rebar, and Phoenix as the vscode user
RUN su vscode -c "mix local.hex --force && \
  mix local.rebar --force && \
  mix archive.install --force hex phx_new 1.7.20"

WORKDIR /workspace
```

---

## Application Screenshots

### Ticket
<img src="/readme/ticket.png" alt="Ticket" style="max-width: 100%; height: auto;">

### Admin
<img src="/readme/admin.png" alt="Admin" style="max-width: 100%; height: auto;">

### Edit, Make, Delete
<img src="/readme/edit-make-delete.png" alt="Edit, Make, Delete" style="max-width: 100%; height: auto;">

### Get a Ticket
<img src="/readme/get-a-ticket.png" alt="Get a Ticket" style="max-width: 100%; height: auto;">

### Who's Here (Using PubSub)
<img src="/readme/who-is-here.png" alt="Who's Here" style="max-width: 100%; height: auto;">

### Search and Filter
<img src="/readme/search-and-filter.png" alt="Search and Filter" style="max-width: 100%; height: auto;">

---



## Learn More

- Official website: [Phoenix Framework](https://www.phoenixframework.org/)
- Guides: [Phoenix Overview](https://hexdocs.pm/phoenix/overview.html)
- Documentation: [Phoenix Docs](https://hexdocs.pm/phoenix)
- Forum: [Elixir Forum - Phoenix](https://elixirforum.com/c/phoenix-forum)
- Source Code: [GitHub - Phoenix Framework](https://github.com/phoenixframework/phoenix)
