#!/usr/bin/env bash

megamkdir -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' /Root/RedDigitsTrainSets/BlackAndWhite/
megamkdir -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' /Root/RedDigitsTrainSets/BackAndRed/

megacopy -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' --local=BlackAndWhite/ --remote=/Root/RedDigitsTrainSets/BlackAndWhite/
megacopy -u 'TempSharing@yopmail.com' -p 'Temp?Sharing!' --local=BlackAndRed/ --remote=/Root/RedDigitsTrainSets/BlackAndRed/
