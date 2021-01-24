# Checks if running as root
if [[ $UID -ne 0 && $EUID -ne 0 ]]; then
    echo "Please run this script with sudo."
    exit
fi

# This will clean the folder structure created during the install process
rm -R ../mac-oic-install/BASIC
rm -R ../mac-oic-install/SQLPLUS
rm -R ../mac-oic-install/TOOLS
rm -R ../mac-oic-install/SDK
