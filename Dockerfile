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
    mkdir -p /opt/velociraptor/$i && \
    curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("linux-amd64") )))' && \
    wget -O /opt/velociraptor/linux/velociraptor "$LINUX_BIN" && \
  # Clean up
    apt-get remove -y --purge curl wget jq && \
    apt-get clean
WORKDIR /velociraptor

# Move binaries into place
RUN cp /opt/velociraptor/linux/velociraptor . && chmod +x velociraptor && \
    mkdir -p /velociraptor/clients/linux && rsync -a /opt/velociraptor/linux/velociraptor /velociraptor/clients/linux/velociraptor_client

# Configmap details
CMD ["./velociraptor config generate > server.config.yaml --merge '{"Frontend":{"public_path":"'$PUBLIC_PATH'", "hostname":"'$VELOX_FRONTEND_HOSTNAME'"},"API":{"bind_address":"'$BIND_ADDRESS'"},"GUI":{"bind_address":"'$BIND_ADDRESS'"},"Monitoring":{"bind_address":"'$BIND_ADDRESS'"},"Logging":{"output_directory":"'$LOG_DIR'","separate_logs_per_component":true},"Client":{"server_urls":["'$VELOX_SERVER_URL'"],"use_self_signed_ssl":true}, "Datastore":{"location":"'$DATASTORE_LOCATION'", "filestore_directory":"'$FILESTORE_DIRECTORY'"}}' &&\
      sed -i "s#https://localhost:8000/#$VELOX_CLIENT_URL#" server.config.yaml &&\
      sed -i 's#/tmp/velociraptor#.#'g server.config.yaml &&\
      ./velociraptor --config server.config.yaml user add $VELOX_USER $VELOX_PASSWORD --role $VELOX_ROLE &&\
      ./velociraptor --config server.config.yaml config client > client.config.yaml &&\
      ./velociraptor config repack --exe clients/linux/velociraptor_client client.config.yaml clients/linux/velociraptor_client_repacked &&\
      ./velociraptor config repack --exe clients/mac/velociraptor_client client.config.yaml clients/mac/velociraptor_client_repacked &&\
      ./velociraptor config repack --exe clients/windows/velociraptor_client.exe client.config.yaml clients/windows/velociraptor_client_repacked.exe &&\
      ./velociraptor --config server.config.yaml frontend -v"]