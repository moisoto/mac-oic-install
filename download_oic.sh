#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

# Customize this if URLs become broken
BASE_URL=https://download.oracle.com/otn_software/mac/instantclient/198000
DMG_BASIC=instantclient-basic-macos.x64-19.8.0.0.0dbru
DMG_SQLPLUS=instantclient-sqlplus-macos.x64-19.8.0.0.0dbru
DMG_TOOLS=instantclient-tools-macos.x64-19.8.0.0.0dbru
DMG_SDK=instantclient-sdk-macos.x64-19.8.0.0.0dbru

dlpkg () {
    local TARGET_DIR=$1
    local DMG_FILE=$2.dmg

    echo "Downloading $TARGET_DIR Package..."
    curl -Os $BASE_URL/$DMG_FILE 
    if [[ -a $DMG_FILE ]] ; then
        echo Download complete.
        mvpkg $1 $2
    else
        echo "Download Failed. Aborting."
        exit
    fi
    echo
}

mvpkg () {
    local TARGET_DIR=$1
    local DMG_FILE=$2.dmg
    local MNT_STR=$2
    local DEV_ENTRY=""
    local MOUNT_POINT=""

    echo "Mounting $DMG_FILE..."
    IFS=$'\n' read -d'\n' DEV_ENTRY MOUNT_POINT < <(
	hdiutil attach -readonly "$DMG_FILE" | grep $MNT_STR | awk '{print $1; print $3}'
    )

    echo "Creating $TARGET_DIR folder and copying files..."
    mkdir $TARGET_DIR && cp -R $MOUNT_POINT/ $TARGET_DIR    

    echo "Unmounting $DMG_FILE..."
    echo
}


#BASIC PACKAGE DOWNLOAD
[[ ! -d BASIC ]] && dlpkg BASIC $DMG_BASIC || echo "BASIC Package Folder Found. Not Downloading."

#SQLPLUS PACKAGE DOWNLOAD
[[ ! -d SQLPLUS ]] && dlpkg SQLPLUS $DMG_SQLPLUS || echo "SQLPLUS Package Folder Found. Not Downloading."

#SDK PACKAGE DOWNLOAD
[[ ! -d SDK ]] && dlpkg SDK $DMG_SDK || echo "SDK Package Folder Found. Not Downloading."

#TOOLS PACKAGE DOWNLOAD
[[ ! -d TOOLS ]] && dlpkg TOOLS $DMG_TOOLS || echo "TOOLS Package Folder Found. Not Downloading."

# Fix files location on packages
./prepare_lib.sh
./prepare_bin.sh

# DELETE ZIP FILES
[[ -a $DMG_BASIC.dmg ]] && rm $DMG_BASIC.dmg
[[ -a $DMG_SQLPLUS.dmg ]] && rm $DMG_SQLPLUS.dmg
[[ -a $DMG_SDK.dmg ]] && rm $DMG_SDK.dmg
