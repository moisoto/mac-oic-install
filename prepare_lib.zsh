#!/bin/zsh

BASIC_DIR=BASIC
SQLPLUS_DIR=SQLPLUS
#BASIC_DIR=instantclient_19_3
#BASIC_DIR=BASIC-WITH-LIB

movelib () {
    TARGET_DIR=$1

    if [[ ! -d $TARGET_DIR ]]
    then
        echo "$TARGET_DIR directory not found!"
        exit
    fi

    cd $TARGET_DIR

    for f in *dylib*; do

        ## Check if the glob gets expanded to existing files.
        ## If not, f here will be exactly the pattern above
        ## and the exists test will evaluate to false.
        ##[ -e "$f" ] && echo "files do exist" || echo "files do not exist"
        [ -e "$f" ] || exit # Exit script if no dylib files are found

        ## This is all we needed to know, so we can break after the first iteration
        break
    done

    if [[ ! -d lib ]]
    then
        mkdir lib
    fi 

    # Move the Library Files to the lib directory
    mv *dylib* lib
} 

movelib $BASIC_DIR
movelib $SQLPLUS_DIR
