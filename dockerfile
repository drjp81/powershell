FROM ubuntu:24.04

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    COMPlus_EnableDiagnostics=0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install prerequisites and PowerShell matching TARGETARCH (supports arm64)
RUN set -eux; \
    echo "Installing PowerShell for TARGETARCH=${TARGETARCH}"; \
    apt-get update; \
    ICU_PKG="$(apt-cache search '^libicu[0-9]+$' | awk '{print $1}' | sort -V | tail -1)"; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        tar \
        gzip \
        "${ICU_PKG}"; \
    apt-get clean; rm -rf /var/lib/apt/lists/*; 
    # Map Docker TARGETARCH to PowerShell asset naming
    RUN if [ "${TARGETARCH}" = "amd64" ]; then arch="x64"; \
    elif [ "${TARGETARCH}" = "arm" ]; then arch="arm32"; \
    else arch="${TARGETARCH}"; fi; \
    echo "Resolved PowerShell asset arch: ${arch}"; \
    \
    # Query latest GitHub release and pick the linux-${arch}.tar.gz asset
    PWS_JSON="$(wget -qO- https://api.github.com/repos/PowerShell/PowerShell/releases/latest)"; \
    PWS_URL="$(echo "$PWS_JSON" | grep 'browser_download_url' | grep "linux-${arch}.tar.gz" | head -n1 | cut -d '"' -f4)"; \
    if [ -z "${PWS_URL}" ]; then echo "No PowerShell release asset found for arch: ${arch}" >&2; exit 1; fi; \
    echo "Downloading PowerShell from ${PWS_URL}"; \
    wget -qO /tmp/powershell.tar.gz "${PWS_URL}"; \
    mkdir -p /opt; \
    tar -xzf /tmp/powershell.tar.gz -C /opt; \
    # normalize extracted directory (powershell-<ver>-linux-<arch>) to /opt/powershell
    mv /opt/powershell-* /opt/powershell || true; \
    ln -s /opt/pwsh /usr/bin/pwsh; \
    rm -f /tmp/powershell.tar.gz
