#!/bin/zsh

BASIC_DIR=BASIC
SQLPLUS_DIR=SQLPLUS
FILES="adrci genezi uidrvci sqlplus"

movelib () {
    local TARGET_DIR=$1

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

    for file in $FILES
    do
        [[ -x $file ]] && mv $file bin && echo "Moved $file to bin"
    done

    cd "$sav_dir" 
} 

movelib $BASIC_DIR
movelib $SQLPLUS_DIR
