#!/bin/sh

yay -S --noconfirm --needed vscodium-bin

cp ./vscodium/settings.json ~/.config/VSCodium/User/settings.json

while read -r extension; do 
  vscodium --install-extension "$extension" 
done < ./vscodium/extensions.txt
