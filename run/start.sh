#!/bin/sh

CMD="mono --server --gc=sgen -O=all ./TerrariaServer.exe -config /config/serverconfig.txt -banlist /config/banlist.txt"

# Create default config files if they don't exist
if [ ! -f "/config/serverconfig.txt" ]; then
    cp ./serverconfig-default.txt /config/serverconfig.txt
fi

if [ ! -f "/config/banlist.txt" ]; then
    touch /config/banlist.txt
fi

# Pass in world if set
if [ "${WORLD:-null}" != null ]; then
    if [ ! -f "/config/$WORLD" ]; then
        echo "World file does not exist! Quitting..."
        exit 1
    fi
    CMD="$CMD -world /config/$WORLD"
fi

CMD="screen -dmS terraria /bin/sh -c '$CMD'"

pid=0

# SIGUSR1-handler
my_handler() {
  echo "my_handler"
}

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    #kill -SIGTERM "$pid"
    ./terrariad.sh exit
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' USR1
trap 'kill ${!}; term_handler' TERM

# run application
$CMD &
pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done