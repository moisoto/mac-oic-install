#!/bin/zsh

# Set Default ZSH Options
emulate -LR zsh

# Save started information
typeset -r BASE_DIR="${PWD:A}"

typeset -g MOUNT_POINT=""
typeset -g DEV_ENTRY=""
typeset basic_mnt_point
typeset basic_dev
typeset sqlplus_dev
typeset tools_dev
typeset sdk_dev
typeset -i PURGE_DMGS=0
typeset -i KEEP_DMGS=0

for option in "$@"; do
  case "$option" in
    --purge-dmgs)
      PURGE_DMGS=1
      ;;
    --keep-dmgs)
      KEEP_DMGS=1
      ;;
    *)
      print -u2 -r -- "Unknown option: $option"
      print -u2 -r -- "Usage: ${0:t} [--purge-dmgs]"
      exit 2
      ;;
  esac
done

if (( PURGE_DMGS && KEEP_DMGS )); then
  print -u2 -r -- "--purge-dmgs and --keep-dmgs cannot be used together."
  print -u2 -r -- "Usage: ${0:t} [--purge-dmgs | --keep-dmgs]"
  exit 2
fi

# Customize this if URLs become broken
BASE_URL=https://download.oracle.com/otn_software/mac/instantclient/2326200
DMG_BASIC=instantclient-basic-macos.arm64-23.26.2.0.0.dmg
DMG_SQLPLUS=instantclient-sqlplus-macos.arm64-23.26.2.0.0.dmg
DMG_TOOLS=instantclient-tools-macos.arm64-23.26.2.0.0.dmg
DMG_SDK=instantclient-sdk-macos.arm64-23.26.2.0.0.dmg
IC_FOLDER_NAME="instantclient_23_26"
DOWNLOAD_FOLDER="$HOME/Downloads/$IC_FOLDER_NAME"

abort() {
  if (( $# > 0 )); then
    print -u2 -r -- "Aborted: $*"
  else
    print -u2 -r -- "Aborted."
  fi
  exit 1
}

# Download and Mount DMG file
dldmg() {
  local DMG_FILE=$1

  if [[ -f $DMG_FILE ]]; then
    echo "File already downloaded."
  else
    echo "Downloading $DMG_FILE"
    if curl -fL#O -- "$BASE_URL/$DMG_FILE"; then
      echo Download complete.
    else
      print -u2 -- "Download failed. Aborting."
      return 1
    fi
  fi

  echo "Verifying $DMG_FILE"
  hdiutil verify -quiet "$DMG_FILE" && echo "Verification successful." || {
    print -u2 -- "DMG verification failed: $DMG_FILE"
    return 1
  }

  if [[ -f $DMG_FILE ]] ; then
      mountdmg "$DMG_FILE" || return 1
  fi
}

mountdmg() {
  local DMG_FILE=$1
  local MNT_STR=${DMG_FILE%.dmg}

  DEV_ENTRY=""
  MOUNT_POINT=""

  echo "Mounting $DMG_FILE..."
  {
    IFS= read -r DEV_ENTRY
    IFS= read -r MOUNT_POINT
  } < <(
    hdiutil attach -readonly "$DMG_FILE" |
      grep -F -- "$MNT_STR" |
      awk '{print $1; print $3}'
  )

  if [[ -z $DEV_ENTRY || -z $MOUNT_POINT || ! -d $MOUNT_POINT ]]; then
    print -u2 -- "Failed to mount $DMG_FILE."
    return 1
  fi

  echo "Mounted in $MOUNT_POINT ($DEV_ENTRY)"
  echo
}

unmountdmg() {
  local DMG_FILE=$1
  local DEV_NAME=$2
  echo "Unmounting $DMG_FILE ($DEV_NAME)..."
  hdiutil detach "$DEV_NAME"
}

cleanup() {
  echo
  [[ -n "$basic_dev" ]]   && unmountdmg "$DMG_BASIC"   "$basic_dev"
  [[ -n "$sqlplus_dev" ]] && unmountdmg "$DMG_SQLPLUS" "$sqlplus_dev"
  [[ -n "$sdk_dev" ]]     && unmountdmg "$DMG_SDK"     "$sdk_dev"
  [[ -n "$tools_dev" ]]   && unmountdmg "$DMG_TOOLS"   "$tools_dev"
}

remove_dmgs() {
  if (( ! PURGE_DMGS && ! KEEP_DMGS )); then
    if [[ ! -t 0 ]]; then
      print "Not an interactive terminal; keeping downloaded DMG files."
      return
    fi

    print -n -- "Remove the downloaded Oracle Instant Client DMG files? [y/N] "

    if read -q; then
      PURGE_DMGS=1
    fi

    print
  fi

  if (( PURGE_DMGS )); then
    rm -f -- \
      "$BASE_DIR/$DMG_BASIC" \
      "$BASE_DIR/$DMG_SQLPLUS" \
      "$BASE_DIR/$DMG_SDK" \
      "$BASE_DIR/$DMG_TOOLS"

    print "Downloaded DMG files removed."
  else
    print "Keeping downloaded DMG files."
  fi
}

###
#Script starts here
###

install_script="install_ic.sh"

#BASIC PACKAGE DOWNLOAD
dldmg "$DMG_BASIC" || { cleanup; abort "Failed to prepare $DMG_BASIC"; }
basic_mnt_point=$MOUNT_POINT
basic_dev=$DEV_ENTRY

#SQLPLUS PACKAGE DOWNLOAD
dldmg "$DMG_SQLPLUS" || { cleanup; abort "Failed to prepare $DMG_SQLPLUS"; }
sqlplus_dev=$DEV_ENTRY

#SDK PACKAGE DOWNLOAD
dldmg "$DMG_SDK" || { cleanup; abort "Failed to prepare $DMG_SDK"; }
sdk_dev=$DEV_ENTRY

#TOOLS PACKAGE DOWNLOAD
dldmg "$DMG_TOOLS" || { cleanup; abort "Failed to prepare $DMG_TOOLS"; }
tools_dev=$DEV_ENTRY

if [[ -d "$basic_mnt_point" ]]; then
  if [[ -d "$DOWNLOAD_FOLDER" ]]; then
    echo "Removing previous files in ~/Downloads/$IC_FOLDER_NAME"
    EXPECTED_PARENT="$HOME/Downloads"

    if [[ ${DOWNLOAD_FOLDER:h} != "$EXPECTED_PARENT" || ${DOWNLOAD_FOLDER:t} != "$IC_FOLDER_NAME" ]]; then
      cleanup
      abort "Refusing to remove unexpected path: $DOWNLOAD_FOLDER"
    fi
    rm -Rf -- "$DOWNLOAD_FOLDER" ||
      { cleanup; abort "Failed to remove previous download: $DOWNLOAD_FOLDER"; }
  fi

  echo "Installing from $basic_mnt_point"
  echo "Using script $install_script..."
  cd -- "$basic_mnt_point" || { cd "$BASE_DIR"; cleanup; exit 1; }
  sh "./$install_script"   || { cd "$BASE_DIR"; cleanup; exit 1; }
  cd -- "$BASE_DIR" || { cleanup; abort "Could not return to the starting directory: $BASE_DIR"; }
  if [[ ! -d "$DOWNLOAD_FOLDER" ]]; then
    print -u2 -- "Something went wrong. Could not find downloaded files!"
    cleanup
    exit 1
  fi
  cleanup
else
  print -u2 -- "Basic package mount point was not found."
  cleanup
  exit 1
fi

echo
remove_dmgs
