# memcached

Minimal **memcached** image built on top of the crbr Debian base
(`crbrdocker/debian:stable`), multi-arch (`amd64` + `arm64`), published by CI to
**GHCR** (`ghcr.io/crbrdocker/memcached`) and **Docker Hub**
(`crbrdocker/memcached`). Rebuilt weekly, but only when something changed. The
previous manual implementation is archived verbatim under `OLD/`.

## Usage

```
docker run --rm -p 11211:11211 crbrdocker/memcached
```

Two runtime env vars (passed straight to the `memcached` CMD):

| Var | Default | Meaning |
|-----|---------|---------|
| `MEM` | `256` | max memory (MB) for stored objects |
| `MAXCONN` | `1000` | max simultaneous connections |

```
docker run --rm -p 11211:11211 -e MEM=512 -e MAXCONN=2000 crbrdocker/memcached
```

## How it is built

Everything is driven by `.github/workflows/build.yml`:

1. **prep** — lowercases the registry owner (OCI rejects uppercase).
2. **gate** — `need_rebuild.sh` decides whether a rebuild is warranted.
3. **build** — matrix `arch × {amd64→ubuntu-24.04, arm64→ubuntu-24.04-arm}`,
   **native, no QEMU**; `docker buildx build` pushes an OCI `:latest-<arch>`
   image (with provenance + SBOM) to both registries.
4. **manifest** — merges the per-arch tags into `:latest` via
   `docker buildx imagetools create`.
5. **cleanup** — prunes untagged GHCR versions.

Triggers: any push to `main`, weekly `cron 35 8 * * 2`, or manual *Run
workflow*.

`install-memcached.sh` is copied into the image and run once at build time
(`apt-get install memcached` + cleanup); there is nothing else to configure —
all tuning is via `MEM` / `MAXCONN`.

### Rebuild gate

`need_rebuild.sh <image-ref> [vcs-ref] [base-image]` prints `REBUILD=true|false`.
It rebuilds when the published image is missing, its
`org.opencontainers.image.revision` label ≠ HEAD, the base `:stable` digest it
was built on has changed, or a simulated `dist-upgrade` shows pending updates.

## Registries & secrets

- GHCR uses the built-in `GITHUB_TOKEN` (needs `packages: write`) — no secret.
- Docker Hub is conditional on secrets `DOCKERHUB_USERNAME` + `DOCKERHUB_TOKEN`;
  namespace is repo/org var `DOCKERHUB_NAMESPACE` (falls back to the username).
  Absent creds → GHCR-only.
