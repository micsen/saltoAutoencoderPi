#!/bin/bash
#Initial beeps!
beepEn=false
#If a socket hook topic is present we will publish uid and status at the socket hook topic.
SOCKETHOOKTOPIC=demo
if [[ "$SOCKETHOOKTOPIC" ]] ; then 
echo "Startup sending to socket hook"
  curl -d "{\"status\": \"startup\"}" -H "Content-Type: application/json" -X POST https://sockethook.ericbetts.dev/hook/$SOCKETHOOKTOPIC
fi
if [[ "$beepEn" == true ]] ; then
  gpio mode 4 out
  for i in {1..5}
  do
    gpio write 4 on
    sleep 0.02
    gpio write 4 off
    sleep 0.02
  done
fi
# Declare infinite loop
for (( ; ; ))
do
  KEYFILE="./dumps/blank.bin"
  DUMPFILE="./dumps/salto.bin"
  #2>&1 is to get the result on failures like reader not connected
  RES=$(nfc-mfclassic w a $DUMPFILE $KEYFILE f 2>&1)
  #IF we get 63 of 64 blocks written we are good
  if echo $RES | grep -q 'Done, 63 of 64 blocks written.'; then
    echo "Brikke ferdig"
    statusOk
    sleep 1
  elif echo $RES | grep -q 'Error: authentication failed'; then
    echo "Auth failure, Er brikken allered programert"
    ERROR="Could not auth, The tag might have been personalized allready or have non default keys."
    statusFault
  elif echo $RES | grep -q 'ERROR: Error opening NFC reader'; then
    echo $RES
    ERROR="Could not open nfc reader"
    #Reader failure
    statusFault
    sleep 5
  elif echo $RES | grep -q 'Could not open keys file'; then
    ERROR="Could not open key file, Check path or permissions"
    statusFault
    sleep 15
  elif echo $RES | grep -q 'ERROR:'; then
    echo "Unknown error"
    echo $RES
  fi
  echo $RES
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
    curl -d "{\"status\": \"fault\", \"output\": \"$ERROR\"}" -H "Content-Type: application/json" -X POST https://sockethook.ericbetts.dev/hook/$SOCKETHOOKTOPIC
    ERROR=
  fi
  if [[ "$beepEn" == true ]] ; then
    gpio write 4 on && sleep 0.1 && gpio write 4 off && sleep 0.2 && gpio write 4 on && sleep 0.4 && gpio write 4 off
  fi

}