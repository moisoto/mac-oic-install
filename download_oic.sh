#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

# Customize this if URLs become broken
BASE_URL=https://download.oracle.com/otn_software/mac/instantclient/193000
ZIP_BASIC=instantclient-basic-macos.x64-19.3.0.0.0dbru.zip
ZIP_SQLPLUS=instantclient-sqlplus-macos.x64-19.3.0.0.0dbru.zip
ZIP_SDK=instantclient-sdk-macos.x64-19.3.0.0.0dbru.zip


dlpkg () {
    local TARGET_DIR=$1
    local ZIP_FILE=$2

    echo "Downloading $TARGET_DIR Package..."
    curl -Os $BASE_URL/$ZIP_FILE 
    if [[ -a $ZIP_FILE ]] ; then
        echo Download complete. Unzipping...
        unzip -q $ZIP_FILE 
        if [[ ! -d instantclient_19_3 ]] ; then
            echo "Unzip Failed. Aborting."
            exit
        fi
        mv instantclient_19_3 $TARGET_DIR
    else
        echo "Download Failed. Aborting."
        exit
    fi
    echo
}

#BASIC PACKAGE DOWNLOAD
[[ ! -d BASIC ]] && dlpkg BASIC $ZIP_BASIC || echo "BASIC Package Folder Found. Not Downloading."

#SQLPLUS PACKAGE DOWNLOAD
[[ ! -d SQLPLUS ]] && dlpkg SQLPLUS $ZIP_SQLPLUS || echo "SQLPLUS Package Folder Found. Not Downloading."

#SDK PACKAGE DOWNLOAD
[[ ! -d SDK ]] && dlpkg SDK $ZIP_SDK || echo "SDK Package Folder Found. Not Downloading."

# Fix files location on packages
./prepare_lib.sh
./prepare_bin.sh

# DELETE ZIP FILES
[[ -a $ZIP_BASIC ]] && rm $ZIP_BASIC
[[ -a $ZIP_SQLPLUS ]] && rm $ZIP_SQLPLUS
[[ -a $ZIP_SDK ]] && rm $ZIP_SDK

