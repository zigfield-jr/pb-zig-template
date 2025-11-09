#!/ebrmain/bin/run_script -clear_screen -bitmap=e3_black_empty_round

for pid in $(pgrep -f $0); do
  if [ $pid -ne $$ ]; then
    kill -9 $pid
  fi
done

pid="$(pidof gdbserver)"
if [ -z $pid ]; then
  /ebrmain/bin/dialog 2 '' 'start gdbserver' @Cancel @TurnOn
  choice="$?"
else
  /ebrmain/bin/dialog 2 '' 'restart gdbserver' @Cancel @TurnOn @TurnOff
  choice="$?"
  if [ $choice -ne 1 ]; then
    kill -9 $pid
  fi
fi

if [ $choice -ne 2 ]; then
  exit 0
fi

/ebrmain/bin/netagent connect
if [ $? -ne 0 ]; then
  /ebrmain/bin/dialog 5 '' @WiFiNetworkIsNotWorking @OK
  exit 0
fi

/ebrmain/bin/gdbserver :10002 /mnt/ext1/applications/hello_world.app &

/ebrmain/bin/iv2sh SetActiveTask "$(pidof bookshelf.app)"
