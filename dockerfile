FROM  --platform=$BUILDPLATFORM drjp81/powershell AS dloader
# ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV DEBIAN_FRONTEND=noninteractive
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETPLATFORM
ENV COMPlus_EnableDiagnostics=0

RUN echo "I'm building for $TARGETARCH"

COPY ./get-powershell.ps1 ./get-powershell.ps1
RUN mkdir /dload
SHELL ["/usr/bin/pwsh", "-c"]
RUN ./get-powershell.ps1

FROM --platform=$TARGETPLATFORM ubuntu:latest AS builder
ARG TARGETARCH
RUN echo "I'm building for $TARGETARCH"
COPY --from=dloader /dload/powershellurl.txt ./powershellurl.txt
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPlus_EnableDiagnostics=0

RUN apt update -y ;apt install -y unrar wget libicu74 
RUN wget $(cat ./powershellurl.txt) -O /tmp/powershell.tar.gz
# Create the target folder where powershell will be placed
RUN mkdir -p /opt/microsoft/powershell/7
# Expand powershell to the target folder
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
&& rm /tmp/powershell.tar.gz
# Set execute permissions
RUN chmod +x /opt/microsoft/powershell/7/pwsh

# Create the symbolic link that points to pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh 
RUN chmod +x /usr/bin/pwsh
RUN apt upgrade -y && apt autoremove && apt clean
