FROM ubuntu:18.04
LABEL version="Velociraptor v0.6.1"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="Wes Lambert, @therealwlambert"
ENV VERSION="0.6.1"
COPY ./entrypoint .
RUN chmod +x entrypoint && \
    apt-get update && \
    apt-get install -y curl wget jq rsync && \
    # Create dirs for Velo binaries
    mkdir -p /opt/velociraptor && \
    for i in linux mac windows; do mkdir -p /opt/velociraptor/$i; done && \
    # Get Velox binaries
    WINDOWS_EXE=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("windows-amd64.exe") )))')  && \
    WINDOWS_MSI=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("windows-amd64.msi") )))') && \
    LINUX_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("linux-amd64") )))') && \
    MAC_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("darwin-amd64") )))') && \
    wget -O /opt/velociraptor/linux/velociraptor "$LINUX_BIN" && \
    wget -O /opt/velociraptor/mac/velociraptor_client "$MAC_BIN" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.exe "$WINDOWS_EXE" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.msi "$WINDOWS_MSI" && \

  # Clean up
    apt-get remove -y --purge curl wget jq && \
    apt-get clean
WORKDIR /velociraptor

# Move binaries into place
RUN cp /opt/velociraptor/linux/velociraptor . && chmod +x velociraptor && \
    mkdir -p /velociraptor/clients/linux && rsync -a /opt/velociraptor/linux/velociraptor /velociraptor/clients/linux/velociraptor_client

# Configmap details
ENTRYPOINT ["./velociraptor config generate > server.config.yaml --merge '{"Frontend":{"public_path":"'public'", "hostname":"'VelociraptorServer'"},"API":{"bind_address":"'0.0.0.0'"},"GUI":{"bind_address":"'0.0.0.0'"},"Monitoring":{"bind_address":"'0.0.0.0'"},"Logging":{"output_directory":"'./'","separate_logs_per_component":true},"Client":{"server_urls":["'VelociraptorServer'"],"use_self_signed_ssl":true}, "Datastore":{"location":"'./'", "filestore_directory":"'./'"}}' &&\
      sed -i 's#/tmp/velociraptor#.#'g server.config.yaml &&\
      ./velociraptor --config server.config.yaml user add $VELOX_USER $VELOX_PASSWORD --role $VELOX_ROLE &&\
      ./velociraptor --config server.config.yaml config client > client.config.yaml &&\
      ./velociraptor config repack --exe clients/linux/velociraptor_client client.config.yaml clients/linux/velociraptor_client_repacked &&\
      ./velociraptor config repack --exe clients/mac/velociraptor_client client.config.yaml clients/mac/velociraptor_client_repacked &&\
      ./velociraptor config repack --exe clients/windows/velociraptor_client.exe client.config.yaml clients/windows/velociraptor_client_repacked.exe &&\
      ./velociraptor --config server.config.yaml frontend -v"]