#!/bin/bash
# Declare infinite loop
gpio mode 4 out
for i in {1..5}
do
   gpio write 4 on
   sleep 0.02
   gpio write 4 off
   sleep 0.02
done
for (( ; ; ))
do
  #Undo
  #RES=$(nfc-mfclassic w b blank.bin salto.bin f 2>&1)
  #Write
  RES=$(nfc-mfclassic w a /home/pi/dumps/salto.bin /home/pi/dumps/blank.bin f)
  if echo $RES | grep -q 'Done, 63 of 64 blocks written.'; then
    echo "Brikke ferdig"
    gpio write 4 on && sleep 0.1 && gpio write 4 off
    sleep 1
  elif echo $RES | grep -q 'Error: authentication failed'; then
    echo "Auth failure, Er brikken allered programert"
    gpio write 4 on && sleep 0.1 && gpio write 4 off && sleep 0.2 && gpio write 4 on && sleep 0.4 && gpio write 4 off
  elif echo $RES | grep -q 'ERROR: Error opening NFC reader'; then
    #Reader failure
    gpio write 4 on && sleep 0.1 && gpio write 4 off && sleep 0.2 && gpio write 4 on && sleep 0.4 && gpio write 4 off && sleep 0.5
    gpio write 4 on && sleep 0.1 && gpio write 4 off && sleep 0.2 && gpio write 4 on && sleep 0.4 && gpio write 4 off
    sleep 5
    gpio write 4 on && sleep 0.1 && gpio write 4 off	
  fi
  #echo "Hey " $RES
done

