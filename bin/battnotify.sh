#!/bin/bash

BATTINFO=$(acpi -b)
if [[ $(echo $BATTINFO | ag -i discharging) ]]; then
  PERCENT=$(echo $BATTINFO | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")
  if [[ $PERCENT -lt 30 ]]; then
    DISPLAY=:0.0 notify-send -u normal "Low battery: $PERCENT"
  elif [[ $PERCENT -lt 15 ]]; then
    DISPLAY=:0.0 notify-send -u critical "Critical battery: $PERCENT"
  elif [[ $PERCENT -lt 5 ]]; then
    pm-hibernate
  fi
fi
