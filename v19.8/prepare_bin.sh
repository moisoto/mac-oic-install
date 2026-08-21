#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

BASIC_DIR=BASIC
SQLPLUS_DIR=SQLPLUS
TOOLS_DIR=TOOLS
#FILELIST="adrci genezi uidrvci sqlplus"
#FILES=( ${=FILELIST} )

movebin () {
    local TARGET_DIR=$1
    local FILELIST=$2
    local FILES=( ${=FILELIST} )

    if [[ ! -d $TARGET_DIR ]]
    then
        echo "$TARGET_DIR directory not found!"
        exit
    fi

    local sav_dir=$(pwd)

    cd $TARGET_DIR

    if [[ ! -d bin ]]
    then
        mkdir bin
    fi 

    for FILE in $FILES
    do
        [[ -x $FILE ]] && mv $FILE bin # && echo "Moved $FILE to bin"
    done

    cd "$sav_dir" 
} 

movebin $BASIC_DIR "adrci genezi uidrvci"
movebin $SQLPLUS_DIR "sqlplus"
movebin $TOOLS_DIR "exp expdp imp impdp install_ic.sh sqlldr wrc"
