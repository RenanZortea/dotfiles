#!/bin/bash

# Detecta o layout atual
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

if [ "$current_layout" = "us" ]; then
    setxkbmap il
else
    setxkbmap us -variant dvp
fi
