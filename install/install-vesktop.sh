#!/bin/sh

yay -S --noconfirm --needed vesktop-bin

./install/vesktop/install-fake-nitro.sh
./install/vesktop/install-theme.sh
./install/vesktop/install-ios-emojis.sh

pkill -x vesktop 2>/dev/null
vesktop &
