#!/bin/bash
git pull
systemctl stop encodeSalto.service
cp encodeSalto.service /lib/systemd/system/
cp encodeSalto.sh /usr/bin/
systemctl daemon-reload
systemctl enable encodeSalto.service
systemctl start encodeSalto.service