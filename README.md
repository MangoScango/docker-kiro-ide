# docker-kiro-ide

[Kiro IDE](https://kiro.dev) running in your browser. This is a fork of [linuxserver/docker-vscode](https://github.com/linuxserver/docker-vscode) that runs Kiro instead of VS Code. It's built on [linuxserver/baseimage-selkies](https://github.com/linuxserver/docker-baseimage-selkies) (Debian trixie), which streams the app to your browser.

Image: `ghcr.io/mangoscango/docker-kiro-ide` (`linux/amd64`, `linux/arm64`)

| Tag | Meaning |
| --- | --- |
| `latest` | Latest build from `master` |
| `<kiro version>` (e.g. `1.1.70`) | Build of that Kiro release |
| `sha-<commit>` | Build of a specific commit |

## Quick start

```bash
docker run -d --name kiro \
  --shm-size=1gb \
  --security-opt seccomp=unconfined \
  -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC \
  -p 3001:3001 \
  -v ./config:/config \
  ghcr.io/mangoscango/docker-kiro-ide:latest
```

Or run `docker compose up -d` with the included [`docker-compose.yml`](docker-compose.yml).

Open **https://yourhost:3001** and accept the self-signed certificate. Use HTTPS: the browser video/audio features the stream relies on only work over a secure connection. Port `3000` (plain HTTP) is only for running behind a reverse proxy.

### Signing in

Choose a sign-in method in Kiro. The login page opens in the Chromium browser inside the container. When you finish, the browser sends you back to Kiro with a `kiro://` link, which the container is set up to hand to Kiro. You stay signed in as long as you keep `/config`.

### What's saved in `/config`

`/config` is the home directory of the user running Kiro. It holds Kiro's settings and login (`/config/.config/Kiro`), extensions and steering (`/config/.kiro`), and whatever projects you clone there.

## Security

> [!WARNING]
> There is **no authentication by default**, and the desktop includes a terminal with passwordless `sudo`.

- Set `CUSTOM_USER` and `PASSWORD` for HTTP basic auth. This is only enough on a trusted local network.
- If it can be reached from the internet, put it behind a reverse proxy with proper authentication.

## Configuration

Everything from the Selkies base image works here: GPU acceleration (`--device /dev/dri`), `LC_ALL` for other languages, reverse proxy and subfolder setup, `proot-apps`, Docker-in-Docker, and all the `SELKIES_*` settings. See the [Selkies docs](https://docs.linuxserver.io/selkies/).

| Variable | Default | Description |
| --- | --- | --- |
| `PUID` / `PGID` | `1000` | User and group that own `/config` |
| `TZ` | `Etc/UTC` | Timezone |
| `CUSTOM_USER` / `PASSWORD` | unset | Turns on HTTP basic auth |
| `PIXELFLUX_WAYLAND` | `true` | Use the Wayland desktop. Set `false` for X11/Openbox. |

## Building locally

```bash
docker build -t docker-kiro-ide .                                  # latest stable Kiro
docker build --build-arg KIRO_VERSION=1.1.70 -t docker-kiro-ide .  # pinned version
```

The build picks the Kiro `.deb` for the target architecture (`TARGETARCH`) from `prod.download.desktop.kiro.dev`.

## CI

[`.github/workflows/build.yml`](.github/workflows/build.yml) builds `amd64` and `arm64` images with Buildx and pushes them to GHCR:

- **Push to `master`**: builds and pushes `latest`, `<kiro version>` and `sha-<commit>`.
- **Pull requests**: builds only, nothing is pushed.
- **Daily schedule**: checks for a new stable Kiro release and builds it if that version tag isn't published yet.
- **Manual run** (`workflow_dispatch`): optionally set `kiro_version` to build a specific release.

The first push creates the GHCR package as **private**. To let people pull without logging in, make it public under *Package settings → Change visibility*.

## License

GPL-3.0, inherited from linuxserver/docker-vscode. See [LICENSE](LICENSE). Kiro itself is covered by the [AWS Customer Agreement](https://aws.amazon.com/agreement/) and Kiro's service terms.
