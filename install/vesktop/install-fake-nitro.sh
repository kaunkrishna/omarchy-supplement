#!/bin/sh

sed -i '/"FakeNitro": {/,/}/ s/"enabled": false/"enabled": true/' ~/.config/vesktop/settings/settings.json
