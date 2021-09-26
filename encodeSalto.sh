#!/bin/bash
#Initial beeps!
beepEn=true
#If a socket hook topic is present we will publish uid and status at the socket hook topic.
SOCKETHOOKTOPIC=demo
gpio mode 4 out
for i in {1..5}
do
   gpio write 4 on
   sleep 0.02
   gpio write 4 off
   sleep 0.02
done

# Declare infinite loop
for (( ; ; ))
do
  KEYFILE="home/pi/dumps/blank.bin"
  DUMPFILE="/home/pi/dumps/salto.bin"
  #2>&1 is to get the result on failures like reader not connected
  RES=$(nfc-mfclassic w a $DUMPFILE $KEYFILE f 2>&1)
  #IF we get 63 of 64 blocks written we are good
  if echo $RES | grep -q 'Done, 63 of 64 blocks written.'; then
    echo "Brikke ferdig"
    statusOk
    sleep 1
  elif echo $RES | grep -q 'Error: authentication failed'; then
    echo "Auth failure, Er brikken allered programert"
    statusFault
  elif echo $RES | grep -q 'ERROR: Error opening NFC reader'; then
    #Reader failure
    statusFault
    sleep 0.5
    gpio write 4 on && sleep 0.1 && gpio write 4 off && sleep 0.2 && gpio write 4 on && sleep 0.4 && gpio write 4 off
    sleep 5
    gpio write 4 on && sleep 0.1 && gpio write 4 off	
  fi
done


statusOk () {
  if [[ "$SOCKETHOOKTOPIC" ]] ; then 
    curl -d "{\"status\": \"ok\"}" -H "Content-Type: application/json" -X POST https://sockethook.ericbetts.dev/hook/$SOCKETHOOKTOPIC
  fi
  if [[ "$beepEn" == true ]] ; then
    gpio write 4 on && sleep 0.1 && gpio write 4 off
  fi
}

statusFault () {
  if [[ "$SOCKETHOOKTOPIC" ]] ; then 
    curl -d "{\"status\": \"fault\", \"output\": \"$RES\"}" -H "Content-Type: application/json" -X POST https://sockethook.ericbetts.dev/hook/$SOCKETHOOKTOPIC
  fi
  if [[ "$beepEn" == true ]] ; then
    gpio write 4 on && sleep 0.1 && gpio write 4 off && sleep 0.2 && gpio write 4 on && sleep 0.4 && gpio write 4 off
  fi

}