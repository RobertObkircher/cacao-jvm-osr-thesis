#!/bin/sh

set -e

directory="$(dirname "$(realpath "$0")")"

echo "Building docker file in $directory:"
docker build -t cacao "$directory"


echo "Launching CLion:"

# For gdb record btrace:
# https://stackoverflow.com/a/52683564
# --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt apparmor=unconfined
if [ -t 1 ] ; then interactive="-ti"; else interactive=""; fi
docker run \
  --name cacao \
  --rm \
  $interactive \
  --env GDK_SCALE --env GDK_DPI_SCALE --env PLASMA_USE_QT_SCALING \
  --env DISPLAY --volume $XAUTHORITY:/tmp/.XAuthority --env XAUTHORITY=/tmp/.XAuthority --network=host \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  --mount source=cacao_root_volume,target=/root \
  cacao "$@"
