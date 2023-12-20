# LAUNCHER.SH

## Overview
This Bash script is a script launcher that uses [jq](https://stedolan.github.io/jq/) for JSON processing and [fzf](https://github.com/junegunn/fzf) for fuzzy finding. It allows you to select and launch scripts defined in the `apps.json` file interactively.

## Dependencies
Make sure you have the following dependencies installed before running the script:
- [jq](https://stedolan.github.io/jq/): JSON processor
- [fzf](https://github.com/junegunn/fzf): Fuzzy finder

## How to Use
1. Clone or download the script.
2. Ensure the dependencies are installed.
3. Run the script in a terminal.

## Structure
- The script reads app configurations from the `apps.json` file.
- Each app entry in the JSON file should have a name, path, and command.
- The main loop presents a selection menu using fzf, allowing you to launch your chosen app.

## Usage Example
./launcher.sh

## Note
- If any dependencies are missing, the script will prompt you to install them before execution.
