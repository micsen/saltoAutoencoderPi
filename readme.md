## MFC Mass encoder

This repo is meant to be run on a raspberry pi and has been tested with the ACR122u card reader
Requires wiringpi (For buzzer)
uses libnfc

## Install instructions
First install wiringpi and libnfc

```
sudo apt install libnfc5 libnfc-bin libnfc-examples
```

```
sudo cp encodeSalto.service /lib/systemd/system/
sudo cp encodeSalto.sh /usr/bin/
sudo systemctl daemon-reload
sudo systemctl enable encodeSalto.service
sudo systemctl start encodeSalto.service
```


This repo is meant to mass encode mfc credentials quickly like needed for Salto and other systems that don't support the default transport keys `ff ff ff ff ff ff`