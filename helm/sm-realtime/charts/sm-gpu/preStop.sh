#!/bin/bash

log_info() {
    printf '{"time":"%s","level":"INFO","source":"k8s-preStop-hook","msg":"%s"}\n' "$(date +"%Y-%m-%dT%H:%M:%S.%3N")" "$1";
};

wait_connections() {
    timeout_sec=20;
    last_connection_time="$(date -u +%s)";
    # main loop: check for active connections
    # if there were no connections in the last <timeout> secs, exit
    while true; do
        current_time="$(date -u +%s)";
        elapsed_sec=$(($current_time-$last_connection_time));
        if [ $elapsed_sec -gt $timeout_sec ]; then
            log_info "No active connections found for last $timeout_sec seconds";
            break;
        fi
        log_info "Checking for active connections";
        # inner loop: wait for active connections to close
        # if there are no connections, break inner loop
        # if there are connections, wait until they close
        while true; do
            c=$(timeout 10 netstat -tna | grep ":8001.*ESTABLISHED" | wc -l);

            if [ $? -ne 0 ]; then
                log_info "Error: netstat command returned $?"
                sleep 2
                continue
            fi

            if [ $c -eq 0 ]; then
                log_info "No active connections found";
                break;
            fi;
            log_info "$c active connections found, waiting";
            last_connection_time="$(date -u +%s)";
            sleep 2;
        done
        sleep 2;
    done
};

# when deleting triton server pod before it finished its startup, in some cases
# it just seem to ignore the SIGTERM send by kubelet, so keep checking if
# triton server is live, waiting up to <timeout_sec>.
# If the server is live or after the timeout expired, send a SIGTERM to process 1
# to gracefully stop the container
sigterm() {
    timeout_sec=600
    start_time="$(date -u +%s)";
    log_info "Checking for liveness...";
    while true; do
        # when triton startup is complete, it starts TCP server on port 8000
        c=$(timeout 10 netstat -tna | grep ":8000.*LISTEN" | wc -l);

        if [ $? -ne 0 ]; then
            log_info "Error: netstat command returned $?"
            sleep 10
            continue
        fi

        if [ $c -eq 1 ]; then
            log_info "Server live so we can send SIGTERM";
            break;
        fi;
        current_time="$(date -u +%s)";
        elapsed_sec=$(($current_time-$start_time));
        if [ $elapsed_sec -gt $timeout_sec ]; then
            log_info "Server not live after $timeout_sec seconds";
            break;
        fi
        log_info "Server not live, sleeping and retrying"
        sleep 10;
    done
    log_info "Sending SIGTERM and exiting"
    kill -s SIGTERM 1;
    exit 0
}

# > /proc/1/fd/1 redirects the logs to the main container process stdout
# which make them visible in the container logs
wait_connections > /proc/1/fd/1;

sigterm > /proc/1/fd/1;
