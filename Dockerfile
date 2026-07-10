# memcached on the crbr Debian base image.
# Built and pushed by .github/workflows/build.yml (native per-arch, OCI +
# provenance + SBOM). BASE_DIGEST records the exact base index the image was
# built from so the rebuild gate can detect a refreshed base.
FROM crbrdocker/debian:stable
ARG IMAGE_VERSION=""
ARG IMAGE_REVISION=""
ARG IMAGE_CREATED=""
ARG IMAGE_SOURCE=""
ARG BASE_DIGEST=""

COPY --chmod=755 install-memcached.sh /usr/local/bin/install-memcached.sh
RUN /usr/local/bin/install-memcached.sh && rm -f /usr/local/bin/install-memcached.sh

LABEL org.opencontainers.image.title="memcached" \
      org.opencontainers.image.description="Memcached on the crbr Debian base image" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.base.name="crbrdocker/debian:stable" \
      org.opencontainers.image.base.digest="${BASE_DIGEST}"

EXPOSE 11211/tcp

# Runtime tuning (override at `docker run` time):
#   MEM     : max memory (MB) for memcached objects
#   MAXCONN : max simultaneous connections
ENV MEM=256
ENV MAXCONN=1000

USER memcache:memcache
STOPSIGNAL SIGKILL
CMD memcached -m ${MEM} -c ${MAXCONN}
