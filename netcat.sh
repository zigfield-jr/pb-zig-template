#!/ebrmain/bin/run_script -clear_screen -bitmap=e3_black_round

for pid in $(pgrep -f $0); do
  if [ $pid -ne $$ ]; then
    kill -9 $pid
  fi
done

nagtpid="$(/ebrmain/bin/netagent status | grep '^nagtpid=' | sed -e 's/^..*=//')"
if [ $nagtpid -eq 0 ]; then
  /ebrmain/bin/dialog 5 '' @NeedWiFiForService @Cancel @TurnOnWiFi
  if [ $? -eq 2 ]; then
    /ebrmain/bin/netagent net on
    if [ $? -eq 0 ]; then
      /ebrmain/bin/dialog 5 '' @WiFiOn @OK
    else
      /ebrmain/bin/dialog 5 '' @WiFiOff @OK
      exit 0
    fi
  else
    exit 0
  fi
fi

/ebrmain/bin/netagent connect
if [ $? -ne 0 ]; then
  /ebrmain/bin/dialog 5 '' @WiFiNetworkIsNotWorking @OK
  exit 0
fi

pkill -9 nc

nc -l -p 10003 -w 60 | tar -xz -C /mnt/ext1
