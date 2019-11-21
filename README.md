# mac-oic-install
Scripts for installing Oracle Instant Client on MacOS using traditional folder structure

### Overview
This has been tested on MacOS Catalina v10.15.1
The script is made to work with Oracle Instant Client 9.3 but an effort has been made so it can (and will probably) be easily modified to work with other versions.


### Preparation
Please download the following Oracle Instant Client Packages from: [Oracle InstantClient](https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-basic-macos.x64-19.3.0.0.0dbru.zip)

Only Basic Package is required, others are optional:

- Basic Package: https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-basic-macos.x64-19.3.0.0.0dbru.zip

- SQL Plus: https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sqlplus-macos.x64-19.3.0.0.0dbru.zip

- SDK: https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sdk-macos.x64-19.3.0.0.0dbru.zip

After download, the .ZIP files will be extracted into folders by safari (otherwise please extract them manually). Please rename the folders with the following names: BASIC, SQLPLUS, and SDK respectively and put them on the same folder as the install script.


# Installation
Run the following scripts in the specified order.

```
./prepare_lib.zsh
./prepare_bin.zsh
sudo ./install_oic.zsh
```
Please note these scripts are for ZSH shell (they may work in bash but has not been tested).
They will run using the ZSH Shell if you are running Catalina or if you have ZSH Installed.
