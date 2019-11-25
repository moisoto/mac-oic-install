#!/bin/zsh

# Performs installation of Oracle Instant Client with traditional folder structure on macOS

# Feel free to change this to your preferred location
INSTALL_ORACLE_BASE=/usr/local/oracle

INSTALL_ORACLE_VERSION=19.3

# Leave this as is for traditional directory structure
INSTALL_ORACLE_HOME=$INSTALL_ORACLE_BASE/product/instantclient/$INSTALL_ORACLE_VERSION

BASIC_DIR=BASIC
SQLPLUS_DIR=SQLPLUS
SDK_DIR=SDK

#==================
# SOME VALIDATIONS
#==================

# Validate Not Already Installed
if [[ -d $INSTALL_ORACLE_HOME ]]
then
    echo "There's a previous installation at $INSTALL_ORACLE_HOME"
    if [[ $1 != "--overwrite" ]] ; then
        echo "Please verify and if not valid then delete folder"
        echo "You may use --overwrite if the folder was created by this script and you are running again"
        exit
    else
        echo 
        echo "--overwrite was specified... continuing"
        echo
    fi
fi

# Validate BASIC Files Directory
if [[ ! -d $BASIC_DIR ]] ; then
    echo "Basic Instant Client Files Not Found."
    echo "Aborting! Nothing Done."
    exit 
fi

# Validate lib folder exist in Basic Install Folders
if [[ ! -d $BASIC_DIR/lib ]]
then
    echo "Library folder not found on BASIC Install Folder."
    echo "Please run prepare_lib.zsh first."
    exit
fi

# Validate bin folder exist in Basic Install Folder
if [[ ! -d $BASIC_DIR/bin ]]
then
    echo "Binary folder not found on BASIC Install Folder."
    echo "Please run prepare_bin.zsh first."
    exit
fi

if [[ -d $SQLPLUS_DIR ]]
then
    # Validate lib folder exist in SqlPlus Install Folders
    if [[ ! -d $SQLPLUS_DIR/lib ]]
    then
        echo "Library folder not found on SQLPLUS Install Folder."
        echo "Please run prepare_lib.zsh first."
        exit
   fi

    # Validate bin folder exist in SqlPlus Install Folder
    if [[ ! -d $SQLPLUS_DIR/bin ]]
    then
        echo "Binary folder not found on SQLPLUS Install Folder."
        echo "Please run prepare_bin.zsh first."
        exit
    fi
fi

for f in "$BASIC_DIR/"*dylib*; do

    ## Check if the glob gets expanded to existing files.
    ## If not, f here will be exactly the pattern above
    ## and the exists test will evaluate to false.
    ##[ -e "$f" ] && echo "files do exist" || echo "files do not exist"
    if [ -e "$f" ] ; then
        echo "There are library files outside the lib file."
        echo "Please run prepare_lib.zsh first."
	exit
    fi 

    ## This is all we needed to know, so we can break after the first iteration
    break
done

# Checks if running as root
if [[ $UID -ne 0 && $EUID -ne 0 ]]; then
    echo "This script modifies and creates files on /usr/local."
    echo "Please run this script with sudo."
    exit
fi
#==== END VALIDATIONS =====

echo "This will install to $INSTALL_ORACLE_HOME"

read -p  'Do you wish to continue (Y/n)?'

if [[ $REPLY != "Y" ]] ; then
    echo "Script Cancelled!"
    exit
fi

#============
# GO INSTALL 
#============

# Create $ORACLE_BASE if doesn't exists along with $ORACLE_BASE/network/admin
TNS_ADMIN="$INSTALL_ORACLE_BASE/network/admin"
[[ ! -d $TNS_ADMIN ]] && mkdir -p $TNS_ADMIN

# Create $ORACLE_HOME if doesn't exists
[[ ! -d $INSTALL_ORACLE_HOME ]] && mkdir -p $INSTALL_ORACLE_HOME

echo 
echo "/=================================================\\"
echo "|  BASIC instantclient files are being installed  |"
cp -R $BASIC_DIR/ $INSTALL_ORACLE_HOME

if [[ -d $SQLPLUS_DIR ]]
then
    echo "| SQLPLUS instantclient files are being installed |"
    cp -R $SQLPLUS_DIR/ $INSTALL_ORACLE_HOME
else
    echo "|       SQLPLUS install files not found           |"
fi

if [[ -d $SDK_DIR ]]
then
    echo "|   SDK instantclient files are being installed   |"
    cp -R $SDK_DIR/ $INSTALL_ORACLE_HOME
else
    echo "|         SDK install files not found             |"
fi

    echo "\\=================================================/"

if [[ ! -d $INSTALL_ORACLE_HOME ]] ; then
    echo "Could Not Create $INSTALL_ORACLE_HOME"
    echo "Aborting!"
    exit
fi
cd $INSTALL_ORACLE_HOME
echo 

# Create Script to Set Variables
[[ ! -d share ]] && mkdir share
[[ ! -d share/instantclient ]] && mkdir share/instantclient

echo 'export ORACLE_VERSION='$INSTALL_ORACLE_VERSION > share/instantclient/instantclient.sh
echo 'export ORACLE_BASE='$INSTALL_ORACLE_BASE >> share/instantclient/instantclient.sh
echo 'export ORACLE_HOME=$ORACLE_BASE/product/instantclient/$ORACLE_VERSION' >> share/instantclient/instantclient.sh
echo 'export DYLD_LIBRARY_PATH=$ORACLE_HOME/lib' >> share/instantclient/instantclient.sh
echo 'export OCI_DIR=$DYLD_LIBRARY_PATH' >> share/instantclient/instantclient.sh
echo 'export TNS_ADMIN=$ORACLE_BASE/network/admin' >> share/instantclient/instantclient.sh
chmod 744 share/instantclient/instantclient.sh
echo "Script instantclient.sh created at $INSTALL_ORACLE_HOME/share/instantclient/instantclient.sh"
# \\\END///

# Setup a link to $ORACLE_HOME/share/instantclient
SHARE_LINK=/usr/local/share/instantclient
LINK_DEST="../oracle/product/instantclient/$INSTALL_ORACLE_VERSION/share/instantclient"
SET_ORAENV_SH="$INSTALL_ORACLE_HOME/share/instantclient/instantclient.sh"
if [[ -h $SHARE_LINK ]] ; then
    CUR_SHARE_LINK=$(readlink $SHARE_LINK)
    echo "Symbolic Link exists in $SHARE_LINK"
    if [[ $CUR_SHARE_LINK == $LINK_DEST  ]] ; then
        echo "Already Pointing to: $CUR_SHARE_LINK"
    else
        echo "Currently Pointing to: $CUR_SHARE_LINK"
        echo "Replacing with $LINK_DEST"
        unlink $SHARE_LINK
        ln -s $LINK_DEST $SHARE_LINK
    fi
    SET_ORAENV_SH="$SHARE_LINK/instantclient.sh"
else
    if [[ -d $SHARE_LINK ]] ; then
        echo "Found $SHARE_LINK and is a directory. Leaving it untouched."
    else
        if [[ ! -a $SHARE_LINK ]] ; then
            SET_ORAENV_SH="$SHARE_LINK/instantclient.sh"
            echo "Creating link $SHARE_LINK -> $LINK_DEST"
            ln -s $LINK_DEST $SHARE_LINK
        else
            echo "Found $SHARE_LINK and it seems to be a file. Leaving it untouched."
        fi
    fi 
fi
# \\\END///

#Setup a link to $ORACLE_HOME/bin/sqlplus
LINK=/usr/local/bin/sqlplus
if [[ -x $INSTALL_ORACLE_HOME/bin/sqlplus ]] ; then
    LINK_DEST="../oracle/product/instantclient/$INSTALL_ORACLE_VERSION/bin/sqlplus"
    if [[ -h $LINK ]] ; then
        CUR_LINK=$(readlink $LINK)
        echo "Symbolic Link exists in $LINK"
        if [[ $CUR_LINK == $LINK_DEST  ]] ; then
            echo "Already Pointing to: $CUR_LINK"
        else
            echo "Currently Pointing to: $CUR_LINK"
            echo "Replacing with $LINK_DEST"
            unlink $LINK
            ln -s $LINK_DEST $LINK
        fi
    else
        if [[ ! -a $LINK ]] ; then
            echo "Creating link $LINK -> $LINK_DEST"
            ln -s $LINK_DEST $LINK
        fi
    fi
else
    if [[ -x $LINK ]] ; then
        CUR_LINK=$(readlink $LINK)
        echo
        echo "There is a $LINK -> $CUR_LINK link on your system but SQLPLUS is not pressent in the install (did you put SQLPLUS folder)?"
        echo "You can download it now and put it on SQLPLUS folder, then run this again with --overwrite flag"
    fi
fi
# \\\END///

# Setting Environment
source $INSTALL_ORACLE_HOME/share/instantclient/instantclient.sh

# Show Current ORACLE Variables
echo "Current Environment Config:"
#set | grep "^ORACLE\|OCI_DIR\|TNS_ADMIN\|^DYLD"
echo "ORACLE_VERSION=$ORACLE_VERSION"
echo "ORACLE_BASE=$ORACLE_BASE"
echo "ORACLE_HOME=$ORACLE_HOME"
echo "DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH"
echo "OCI_DIR=$OCI_DIR"
echo "TNS_ADMIN=$TNS_ADMIN"
echo

echo "Update your rc file (.bashrc or .zshrc) adding the following command to set these variables when starting a new terminal session:"
echo "# Set Oracle Environment Variables"
echo "source $SET_ORAENV_SH"
