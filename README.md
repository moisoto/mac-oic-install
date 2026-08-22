[![](https://img.shields.io/static/v1.svg?label=Made%20with&message=ZSH&color=red)](http://zsh.sourceforge.net)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# mac-oic-install
Scripts for installing Oracle Instant Client on MacOS using traditional folder structure

### Overview
The script is made to work with Oracle Instant Client 23.26 but an effort has been made so it can be easily modified to work with other versions.

# Easy Installation

For a completely automated install, just clone this repository in your machine and run these scripts:

```shell
./download_oic.zsh
./install_oic.zsh
```

# Manual Installation
If you prefer to download and setup the install files yourself, follow this procedure:

### Prepare
Please download the following Oracle Instant Client Packages from: [Oracle InstantClient for macOS (Apple Silicon)](https://www.oracle.com/database/technologies/instant-client/macos-arm64-downloads.html)

After downloading the packages you need and following the instructions in the download page,
you will find a folder in `~/Downloads/instantclient_23_26`.

### Install
To install the files localted on `~/Downloads/instantclient_23_26`
clone this repository and run the following script:

```shell
sudo ./install_oic.zsh
```
