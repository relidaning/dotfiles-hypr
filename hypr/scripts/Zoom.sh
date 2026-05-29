#!/bin/bash

factor=$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {print $2}')
factor=${factor:-1}

if [ "$1" = "up" ]; then
  new=$(awk "BEGIN {print $factor * 1.5}")
else
  new=$(awk "BEGIN {print $factor / 1.5}")
fi

hyprctl keyword cursor:zoom_factor "$new"
