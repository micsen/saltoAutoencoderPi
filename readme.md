##Salto MFC encoder

This repo is meant to be run on a raspberry pi and has been tested with the ACR122u card reader
Requires wiringpi (For buzzer)
uses LIB NFC 

installation instructions
sudo cp encodeSalto.service /lib/systemd/system/
sudo cp encodeSalto.sh /usr/bin/
sudo systemctl daemon-reload
sudo systemctl enable encodeSalto.service
sudo systemctl start encodeSalto.service

Get the keys and make dump files from your salto REP