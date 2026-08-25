#!/bin/zsh

emulate -LR zsh
setopt errexit

typeset SCRIPT_DIR="${0:A:h}"
typeset DOWNLOAD_FOLDER="instantclient_23_26"

typeset -a DOWNLOAD_OPTIONS=(--purge-dmgs)
typeset -a INSTALL_OPTIONS

for option in "$@"; do
  case "$option" in
    --merge)
      INSTALL_OPTIONS+=(--merge)
      ;;
    --keep-dmgs)
      DOWNLOAD_OPTIONS=(--keep-dmgs)
      ;;
    *)
      print -u2 -r -- "Unknown option: $option"
      print -u2 -r -- "Usage: ${0:t} [--merge] [--keep-dmgs]"
      exit 2
      ;;
  esac
done

chk_prev_install() {
  local ORACLE_BASE="$HOME/.local/opt/oracle"
  local ORACLE_VERSION="23.26"
  local INSTANT_CLIENT_HOME="$ORACLE_BASE/product/instantclient/$ORACLE_VERSION"

  if [[ -d "$INSTANT_CLIENT_HOME" ]]; then
    print -r -- "There's a previous installation at $INSTANT_CLIENT_HOME"

    if (( ${INSTALL_OPTIONS[(I)--merge]} )); then
      print
      print -r -- "--merge was specified... continuing"
      print
    else
      print -r -- "Please verify and, if not valid, delete the folder."
      print -r -- "You may use --merge if the folder was created by this script and you are running it again."
      exit 1
    fi
  fi
}

install() {
  local -r BLUE=$'\e[38;5;117m'
  local -r RESET=$'\e[0m'

  print -r -- "${BLUE}---------------------"
  print -r -- "Downloading OIC Files"
  print -r -- "---------------------${RESET}"
  "$SCRIPT_DIR/download_oic.zsh" "${DOWNLOAD_OPTIONS[@]}"

  print

  print -r -- "${BLUE}--------------------------------"
  print -r -- "Installing Oracle Instant Client"
  print -r -- "--------------------------------${RESET}"
  "$SCRIPT_DIR/install_oic.zsh" "${INSTALL_OPTIONS[@]}"
}

remove_download() {
  local OIC_FOLDER

  if [[ -d "$DOWNLOAD_FOLDER" ]]; then
    OIC_FOLDER="$PWD/$DOWNLOAD_FOLDER"
  elif [[ -d "$HOME/Downloads/$DOWNLOAD_FOLDER" ]]; then
    OIC_FOLDER="$HOME/Downloads/$DOWNLOAD_FOLDER"
  else
    return
  fi

  if [[ "${OIC_FOLDER:t}" != "$DOWNLOAD_FOLDER" ]]; then
    print -u2 -- "Unexpected download path; refusing to remove it."
    return 1
  fi

  rm -Rf -- "$OIC_FOLDER"
  print
  print -r -- "Downloaded OIC files removed from $OIC_FOLDER."
}

chk_prev_install
install
remove_download
