#!/usr/bin/env bash

mkdir -p full/ splitted/

megacopy -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' --download --local=full/ --remote=/Root/RedDigitsTrainSets/full/
megacopy -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' --download --local=splitted/ --remote=/Root/RedDigitsTrainSets/splitted/
