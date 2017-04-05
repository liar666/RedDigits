#!/usr/bin/env bash

mkdir -p full/ splitted/

megacopy -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' --download --local=BlackAndWhite/ --remote=/Root/RedDigitsTrainSets/BlackAndWhite/
megacopy -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' --download --local=BlackAndRed/ --remote=/Root/RedDigitsTrainSets/BlackAndRed/
