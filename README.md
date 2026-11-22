# OpenOMEN Tools
Tools for the [OpenOMEN](https://github.com/openomen/openomen) project.

## Debian Compiler
`openomen-deb.sh` > Compile a .deb using a Github Release or Local file.

* `Online Mode` > Creates a Debian Package using a Github Release
    * Example: `openomen-deb.sh CLI_0.5.0`
* `--local <path>` > Creates the release using a local file
    * **IMPORTANT: Requires the `--version` argument**
    * Example: `openomen-deb.sh --local ./dist/openomen`

Arguments:
* `--clean` > Erases Package Directory (Recommended)
* `--version <name>` > Uses a custom version name


## Compiler
`openomen-compile.sh` > Run it on the project's main folder.

Compiles and runs OpenOMEN with Pyinstaller using a venv and then cleans up.

## Installer / Updater
`openomen-installer.sh` > Installs or Updates OpenOMEN to the latest version.

Follows the same structure and functionality as the official, integrated updater.

It has SHA256 Checksum and Binary Execution verification.

* `--no-verify` > Skip Binary Execution
* `--force` > Direct GitHub download from `releases/latest/download`

## LEGACY Installer / Updater
`openomen-installer_legacy.sh` > Installs or Updates OpenOMEN to the latest version.

Legacy installer that evolved into the integrated updater.