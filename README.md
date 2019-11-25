# mac-oic-install
Scripts for installing Oracle Instant Client on MacOS using traditional folder structure

### Overview
This has been tested on MacOS Catalina v10.15.1
The script is made to work with Oracle Instant Client 9.3 but an effort has been made so it can (and will probably) be easily modified to work with other versions.

# Easy Installation

On macOS Catalina when downloading the zip files from Safari they will be flagged with Quarantine attribute and fail to run unless you approve them (see [About Catalina Notarization Requirements](#about-catalina-notarization-requirements)).

You can use this easy installation procedure to avoid the quarantine issue:

```
./download_oic.sh
sudo ./install_oic.sh
```

# Manual Installation
If you preffer to download and setup the install files yourself, follow this procedure:

### Prepare
Please download the following Oracle Instant Client Packages from: [Oracle InstantClient](https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-basic-macos.x64-19.3.0.0.0dbru.zip)

Only Basic Package is required, others are optional:

- Basic Package: https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-basic-macos.x64-19.3.0.0.0dbru.zip

- SQL Plus: https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sqlplus-macos.x64-19.3.0.0.0dbru.zip

- SDK: https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sdk-macos.x64-19.3.0.0.0dbru.zip

After download, the .ZIP files will be extracted into folders by safari (otherwise please extract them manually). Please rename the folders with the following names: BASIC, SQLPLUS, and SDK respectively and put them on the same folder as the install script.


### Install
Run the following scripts in the specified order.

```
./prepare_lib.sh
./prepare_bin.sh
sudo ./install_oic.sh
```

### About Catalina Notarization Requirements
When you first try to use any of the binaries supplied by Oracle on a Catalina Installation, you'll probably encounter an error stating the developer can't be verified.

This is due to Catalina not allowing to run binaries with quarantine flags (non-notarized binaries downloaded from the web are saved with the quarantine flag).

To solve this you should open System Preference Panel and select "Security & Privacy". On the bottom you'll find a message letting you know about the blocked process and a button labeled "Open Anyways" that will remove the quarantine flag.

A good way to "fix" most binaries is to run sqlplus with Security & Privacy Panel opened and press the "Open Anyways" button, then try to run sqlplus again. It will then fail opening the libraries that sqlplus uses. Keep doing this process until sqlplus runs successfully.

A Wiki page will be created with more detailed instructions of this process.

