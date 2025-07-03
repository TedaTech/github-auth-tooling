FROM alpine:3.22.0

LABEL org.opencontainers.image.authors="TeDa Tech"
LABEL org.opencontainers.image.description="GitHub Authentication acion for Tekton"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.url="https://github.com/TeDaTech/github-auth-tooling"

COPY --chmod=755 *.sh /

# Create non-root user and group
RUN addgroup -g 65532 appuser && \
    adduser -D -u 65532 -G appuser -s /bin/sh appuser

# Install dependencies: curl, jq, git
RUN apk add --no-cache curl jq git openssl

# Switch to non-root user
USER 65532:65532

ENTRYPOINT [ "/docker-entrypoint.sh" ]