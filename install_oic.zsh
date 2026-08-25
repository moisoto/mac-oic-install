#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

typeset CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
typeset DOWNLOAD_FOLDER="instantclient_23_26"
typeset ORACLE_BASE="$HOME/.local/opt/oracle"
typeset ORACLE_VERSION="23.26"
typeset INSTANT_CLIENT_HOME="$ORACLE_BASE/product/instantclient/$ORACLE_VERSION"
typeset TNS_ADMIN="$CONFIG_HOME/oracle/network/admin"
typeset LOCAL_BIN="$HOME/.local/bin"
typeset LOCAL_SHARE="$HOME/.local/share"
typeset ORACLE_SHARE="$INSTANT_CLIENT_HOME/share/instantclient"
typeset ORAENV_ZSH="$ORACLE_SHARE/env.zsh"

abort() {
  if (( $# > 0 )); then
    print -u2 -r -- "Aborted: $*"
  else
    print -u2 -r -- "Aborted."
  fi
  exit 1
}

#==================
# SOME VALIDATIONS
#==================

# If downloaded files are not on current folder assume they are on ~/Downloads
[[ ! -d $DOWNLOAD_FOLDER ]] && DOWNLOAD_FOLDER="$HOME/Downloads/instantclient_23_26"

# Check downloaded folder is present
if [[ ! -d $DOWNLOAD_FOLDER ]]; then
  echo "Oracle Instant Client Files not Found!"
  echo "Use script download_oic.sh"
  echo
  echo "Or follow the procedure described in: "
  echo "    https://www.oracle.com/database/technologies/instant-client/macos-arm64-downloads.html"
  exit 1
fi

# Validate Not Already Installed
if [[ -d $INSTANT_CLIENT_HOME ]]
then
  echo "There's a previous installation at $INSTANT_CLIENT_HOME"
  if [[ $1 != "--merge" ]] ; then
    echo "Please verify and if not valid then delete folder"
    echo "You may use --merge if the folder was created by this script and you are running again"
    exit 1
  else
    echo
    echo "--merge was specified... continuing"
    echo
  fi
fi
#==== END VALIDATIONS =====

#===============#
# INSTALL FILES #
#============== #

echo "This will install to $INSTANT_CLIENT_HOME"

printf "Press Y to continue: "
read REPLY
[[ $REPLY == "y" ]] && echo "Please use Capital Y if you wish to continue"
if [[ $REPLY != "Y" ]] ; then
  echo "Script Cancelled!"
  exit
fi

# Make sure the folder exists
mkdir -p "$TNS_ADMIN" ||
  abort "Failed to create $TNS_ADMIN"

# Creates $ORACLE_BASE and $INSTANT_CLIENT_HOME if doesn't exists along with share/instantclient
mkdir -p "$INSTANT_CLIENT_HOME/share/instantclient" ||
  abort "Failed to create $INSTANT_CLIENT_HOME/share/instantclient"

# Copy files from Download folder
cp -R -P -f -- "$DOWNLOAD_FOLDER"/. "$INSTANT_CLIENT_HOME"/ ||
  abort "Could not copy downloaded files from $DOWNLOAD_FOLDER to $INSTANT_CLIENT_HOME"

# Make sure share and bin folders exists on ~/.local
mkdir -p "$HOME/.local/share" "$HOME/.local/bin" "$ORACLE_SHARE" ||
  abort "Could not create share and/or bin folder"

# Create environment script
{
  print -r -- "export ORACLE_VERSION=$ORACLE_VERSION"
  print -r -- 'export ORACLE_BASE="$HOME/.local/opt/oracle"'
  print -r -- 'export INSTANT_CLIENT_HOME=$ORACLE_BASE/product/instantclient/$ORACLE_VERSION'
  print -r -- 'export TNS_ADMIN="${XDG_CONFIG_HOME:-$HOME/.config}/oracle/network/admin"'
} > "$ORAENV_ZSH" || abort "Failed to create environment script $ORAENV_ZSH"

# 644 is fine for a sourced file
chmod 644 "$ORAENV_ZSH" || abort "Failed to change permissions for file $ORAENV_ZSH"
echo "Script env.zsh created at $ORAENV_ZSH"

# Setup a link to $INSTANT_CLIENT_HOME/share/instantclient
SHARE_LINK="$LOCAL_SHARE/instantclient"
LINK_DEST="../opt/oracle/product/instantclient/$ORACLE_VERSION/share/instantclient"
if [[ -h "$SHARE_LINK" ]] ; then
  CUR_SHARE_LINK=$(readlink "$SHARE_LINK")
  echo "Symbolic Link exists in $SHARE_LINK"
  if [[ $CUR_SHARE_LINK == $LINK_DEST  ]] ; then
    echo "Already Pointing to: $CUR_SHARE_LINK"
  else
    echo "Currently Pointing to: $CUR_SHARE_LINK"
    echo "Replacing with $LINK_DEST"
    unlink "$SHARE_LINK" || abort "Failed to unlink $SHARE_LINK"
    ln -s "$LINK_DEST" "$SHARE_LINK" || abort "Failed creating link $SHARE_LINK -> $LINK_DEST"
  fi
else
  if [[ -d $SHARE_LINK ]] ; then
    echo "Found $SHARE_LINK and is a directory. Leaving it untouched."
  else
    if [[ ! -a $SHARE_LINK ]] ; then
      ORAENV_ZSH="$SHARE_LINK/env.zsh"
      echo "Creating link $SHARE_LINK -> $LINK_DEST"
      ln -s "$LINK_DEST" "$SHARE_LINK" || abort "Failed creating link $SHARE_LINK -> $LINK_DEST"
    else
      echo "Found $SHARE_LINK and it seems to be a file. Leaving it untouched."
    fi
  fi
fi
if [[ -h $SHARE_LINK && $(readlink "$SHARE_LINK") == "$LINK_DEST" ]]; then
  ORAENV_ZSH="$SHARE_LINK/env.zsh"
fi
# \\\END///

# Setup a link to $INSTANT_CLIENT_HOME/bin/sqlplus
LINK="$LOCAL_BIN/sqlplus"
if [[ -x $INSTANT_CLIENT_HOME/sqlplus ]] ; then
  LINK_DEST="../opt/oracle/product/instantclient/$ORACLE_VERSION/sqlplus"
  if [[ -h $LINK ]] ; then
    CUR_LINK=$(readlink "$LINK")
    echo "Symbolic Link exists in $LINK"
    if [[ $CUR_LINK == $LINK_DEST  ]] ; then
      echo "Already Pointing to: $CUR_LINK"
    else
      echo "Currently Pointing to: $CUR_LINK"
      echo "Replacing with $LINK_DEST"
      unlink "$LINK" || abort "Failed to unlink $LINK"
      ln -s "$LINK_DEST" "$LINK" || abort "Failed creating link $LINK -> $LINK_DEST"
    fi
  else
    if [[ ! -a $LINK ]] ; then
      echo "Creating link $LINK -> $LINK_DEST"
      ln -s "$LINK_DEST" "$LINK" || abort "Failed creating link $LINK -> $LINK_DEST"
    else
      echo "Found $LINK and it is not a symbolic link. Leaving it untouched."
      exit 1
    fi
  fi
else
  if [[ -x $LINK ]] ; then
    CUR_LINK=$(readlink "$LINK")
    echo
    echo "There is a $LINK -> $CUR_LINK link on your system but SQLPLUS is not present in the install?"
    echo "You can download it now and put it on SQLPLUS folder, then run this again with --merge flag"
  fi
fi
# \\\END///

# Substitute the start of the string with $HOME is path matches
if [[ $ORAENV_ZSH == "$HOME"* ]]; then
  ORAENV_ZSH='$HOME'${ORAENV_ZSH#"$HOME"}
fi

# Show Current ORACLE Variables
echo "Current Environment Config:"
echo "ORACLE_VERSION=$ORACLE_VERSION"
echo "ORACLE_BASE=$ORACLE_BASE"
echo "INSTANT_CLIENT_HOME=$INSTANT_CLIENT_HOME"
echo "TNS_ADMIN=$TNS_ADMIN"
echo

echo "Update your startup script (.zshrc for example)"
echo "Add the following command to set these variables when starting a new terminal session:"
echo
echo "# Set Oracle Environment Variables"
echo "[[ -r \"$ORAENV_ZSH\" ]] && source \"$ORAENV_ZSH\""
