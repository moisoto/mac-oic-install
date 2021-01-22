#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

BASIC_DIR=BASIC
SQLPLUS_DIR=SQLPLUS
TOOLS_DIR=TOOLS

movelib () {
    local TARGET_DIR=$1

    if [[ ! -d $TARGET_DIR ]]
    then
        echo "$TARGET_DIR directory not found!"
        exit
    fi

    local sav_dir=$(pwd)

    cd $TARGET_DIR

    #Avoid "no matches found" error
    setopt NO_NOMATCH
    for f in *dylib*; do

        ## Check if the glob gets expanded to existing files.
        ## If not, f here will be exactly the pattern above
        ## and the exists test will evaluate to false.
        ##[ -e "$f" ] && echo "files do exist" || echo "files do not exist"
        [ -e "$f" ] || exit # Exit script if no dylib files are found

        ## This is all we needed to know, so we can break after the first iteration
        break
    done
    setopt NOMATCH

    if [[ ! -d lib ]]
    then
        mkdir lib
    fi 

    # Move the Library Files to the lib directory
    mv *dylib* lib

    cd "$sav_dir"
} 

movelib $BASIC_DIR
movelib $SQLPLUS_DIR
movelib $TOOLS_DIR
