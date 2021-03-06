#!/bin/bash
usage="$0 start|stop|rm"
if [ $# -ne 1  ]; then
    echo USAGE: $usage
    exit 1
fi

case $1 in
start)

    rm -f /tmp/volsupervisor-fifo

    set -e
    echo starting volsupervisor
    /usr/bin/contiv-vol-run.sh volsupervisor

    # now just sleep to keep the service up
    mkfifo "/tmp/volsupervisor-fifo"
    < "/tmp/volsupervisor-fifo"
    ;;

stop)
    echo stopping volsupervisor
    rm -f /tmp/volsupervisor-fifo
    docker stop volsupervisor
    ;;

rm)
    echo removing volsupervisor container
    rm -f /tmp/volsupervisor-fifo
    docker stop volsupervisor
    docker rm -v volsupervisor
    ;;

*)
    echo USAGE: $usage
    exit 1
    ;;

esac
