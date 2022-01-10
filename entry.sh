#!/bin/bash
set -e
CLIENT_DIR="/velociraptor/clients"
cp /opt/velociraptor/linux/velociraptor . && chmod +x velociraptor && \
mkdir -p $CLIENT_DIR/linux && rsync -a /opt/velociraptor/linux/velociraptor /velociraptor/clients/linux/velociraptor_client && \
mkdir -p $CLIENT_DIR/mac && rsync -a /opt/velociraptor/mac/velociraptor_client /velociraptor/clients/mac/velociraptor_client && \
mkdir -p $CLIENT_DIR/windows && rsync -a /opt/velociraptor/windows/velociraptor_client* /velociraptor/clients/windows/ && \
./velociraptor config generate > server.config.yaml --merge '{"Frontend":{"public_path":"'$PUBLIC_PATH'", "hostname":"'$VELOX_FRONTEND_HOSTNAME'"}, "API":{"bind_address":"'$BIND_ADDRESS'"}, "GUI":{"bind_address":"'$BIND_ADDRESS'"}, "Monitoring":{"bind_address":"'$BIND_ADDRESS'"}, "Logging":{"output_directory":"'$LOG_DIR'", "separate_logs_per_component":"'$LOG_PER_COMPONENT'"}, "Client":{"server_urls":["'$VELOX_SERVER_URL'"], "use_self_signed_ssl":"'$SELF_SIGNED_CERT'"}, "Datastore":{"location":"'$DATASTORE_LOCATION'", "filestore_directory":"'$FILESTORE_DIRECTORY'"}}' && \
./velociraptor --config server.config.yaml user add $VELOX_USER $VELOX_PASSWORD --role $VELOX_ROLE && \
./velociraptor --config server.config.yaml config client > client.config.yaml && \
echo "client config done" && \
./velociraptor config repack --exe clients/linux/velociraptor_client client.config.yaml clients/linux/velociraptor_client_repacked && \
./velociraptor config repack --exe clients/mac/velociraptor_client client.config.yaml clients/mac/velociraptor_client_repacked && \
./velociraptor config repack --exe clients/windows/velociraptor_client.exe client.config.yaml clients/windows/velociraptor_client_repacked.exe && \
echo "clients repacked" && \
./velociraptor --config server.config.yaml frontend -v