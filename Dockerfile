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
RUN apk add --no-cache curl jq git

# Install GitHub CLI
ENV GH_VERSION=2.74.2
RUN curl -fsSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -o /tmp/gh.tar.gz && \
    tar -xzf /tmp/gh.tar.gz -C /tmp && \
    mv /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/gh && \
    chmod +x /usr/local/bin/gh && \
    rm -rf /tmp/gh.tar.gz /tmp/gh_${GH_VERSION}_linux*

# Install jwt-cli
ENV JWT_CLI_VERSION=6.2.0
RUN curl -fsSL https://github.com/mike-engel/jwt-cli/releases/download/${JWT_CLI_VERSION}/jwt-linux.tar.gz -o /tmp/jwt-linux.tar.gz && \
    tar -xzf /tmp/jwt-linux.tar.gz -C /tmp && \
    mv /tmp/jwt /usr/local/bin/jwt && \
    chown root:root /usr/local/bin/jwt && \
    chmod +x /usr/local/bin/jwt && \
    rm -rf /tmp/jwt*.gz /tmp/jwt

# Switch to non-root user
USER 65532:65532

ENTRYPOINT [ "/docker-entrypoint.sh" ]