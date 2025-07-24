#!/bin/sh
SAVEDIR="$HOME/Games/"
if [ -d "$HOME/Larian Studios" ]; then
    mv "$HOME/Larian Studios" "$SAVEDIR"
fi
ln -s "$SAVEDIR/Larian Studios" "$HOME/Larian Studios"
LD_LIBRARY_PATH="." ./EoCApp
sleep 1
unlink "$HOME/Larian Studios"

