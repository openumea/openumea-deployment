#!/bin/bash

perl -pi -e 's,^//Unattended-Upgrade::Automatic-Reboot "false";$,Unattended-Upgrade::Automatic-Reboot "true";,' /etc/apt/apt.conf.d/50unattended-upgrades
