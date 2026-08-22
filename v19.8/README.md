[![](https://img.shields.io/static/v1.svg?label=Made%20with&message=ZSH&color=red)](http://zsh.sourceforge.net)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# mac-oic-install
Scripts for installing Oracle Instant Client on MacOS using traditional folder structure

### Overview
This has been tested on MacOS Catalina v10.15.7
The script is made to work with Oracle Instant Client 9.8 but an effort has been made so it can (and will probably) be easily modified to work with other versions.

# Easy Installation
```
./download_oic.sh
sudo ./install_oic.sh
```

# Manual Installation
If you preffer to download and setup the install files yourself, follow this procedure:

### Prepare
Please download the following Oracle Instant Client Packages from: [Oracle InstantClient for macOS (Intel x86)](https://www.oracle.com/database/technologies/instant-client/macos-intel-x86-downloads.html)

Only Basic Package is required, others are optional:

- Basic Package: https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-basic-macos.x64-19.8.0.0.0dbru.dmg

- SQL Plus: https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-sqlplus-macos.x64-19.8.0.0.0dbru.dmg

- SDK: https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-sdk-macos.x64-19.8.0.0.0dbru.dmg

- TOOLS: https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-tools-macos.x64-19.8.0.0.0dbru.dmg

After download:

- Create the following folders on the repository root (the same folder where the install script is located), 
  * BASIC
  * SQLPLUS
  * SDK
  * TOOLS

- Mount the DMG files on your Mac and copy the files into the corresponding folders.

### Install
Run the following scripts in the specified order.

```
./prepare_lib.sh
./prepare_bin.sh
sudo ./install_oic.sh
```
