#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

BASIC_DIR=BASIC
SQLPLUS_DIR=SQLPLUS
TOOLS_DIR=TOOLS

link_libs () {
    local TARGET_DIR=$1
    local sav_dir=$(pwd)

    cd $TARGET_DIR 

    #Avoid "no matches found" error
    setopt NO_NOMATCH
    for f in lib/*dylib*; do
        [ -e "$f" ] || exit # Exit script if no dylib files are found
        ln -s ../$f bin/
    done
    setopt NOMATCH

    cd "$sav_dir"
}

link_libs $BASIC_DIR
link_libs $SQLPLUS_DIR
link_libs $TOOLS_DIR

