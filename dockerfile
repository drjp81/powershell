FROM ubuntu:latest

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    COMPlus_EnableDiagnostics=0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    echo "Installing PowerShell for TARGETARCH=${TARGETARCH}"; \
    apt-get update; \
    ICU_PKG="$(apt-cache search '^libicu[0-9]+$' | awk '{print $1}' | sort -V | tail -1)"; \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        apt-transport-https \
        "${ICU_PKG}"; 
    RUN . /etc/os-release; \
    wget "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/packages-microsoft-prod.deb"; 
    RUN dpkg -i packages-microsoft-prod.deb; \
    rm -f packages-microsoft-prod.deb; \
    apt-get update; \
    apt-get install -y powershell; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*