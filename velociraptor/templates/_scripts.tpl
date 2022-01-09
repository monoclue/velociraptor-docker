{{- define "service.containerSetup" }}
- >-
    ./velociraptor config generate > server.config.yaml --merge '{"Frontend":{"public_path":"'{{int .Values.extraArgs.PUBLIC_PATH}}'", "hostname":"'{{int .Values.extraArgs.VELOX_FRONTEND_HOSTNAME}}'"}, "API":{"bind_address":"'{{int .Values.extraArgs.BIND_ADDRESS}}'"}, "GUI":{"bind_address":"'{{int .Values.extraArgs.BIND_ADDRESS}}'"}, "Monitoring":{"bind_address":"'{{int .Values.extraArgs.BIND_ADDRESS}}'"}, "Logging":{"output_directory":"'{{int .Values.extraArgs.LOG_DIR}}'", "separate_logs_per_component":"'{{int .Values.extraArgs.LOG_PER_COMPONENT}}'"}, "Client":{"server_urls":["'{{int .Values.extraArgs.VELOX_SERVER_URL}}'"], "use_self_signed_ssl":"'{{int .Values.extraArgs.SELF_SIGNED_CERT}}'"}, "Datastore":{"location":"'{{int .Values.extraArgs.DATASTORE_LOCATION}}'", "filestore_directory":"'{{int .Values.extraArgs.FILESTORE_DIRECTORY}}'"}}' &&\
    sed -i 's#/tmp/velociraptor#.#'g server.config.yaml &&\
    ./velociraptor --config server.config.yaml user add {{int .Values.extraArgs.VELOX_USER}} {{int .Values.extraArgs.VELOX_PASSWORD}} --role administrator &&\
    ./velociraptor --config server.config.yaml config client > client.config.yaml &&\
    ./velociraptor config repack --exe clients/linux/velociraptor_client client.config.yaml clients/linux/velociraptor_client_repacked &&\
    ./velociraptor config repack --exe clients/mac/velociraptor_client client.config.yaml clients/mac/velociraptor_client_repacked &&\
    ./velociraptor config repack --exe clients/windows/velociraptor_client.exe client.config.yaml clients/windows/velociraptor_client_repacked.exe &&\
    ./velociraptor --config server.config.yaml frontend -v
{{- end -}}


        command: ["bash", "-c"]
        args:
            {{- include "pulsar.waitBrokerReady" . | indent 10 }}