# LAUNCHER.SH

## Overview
This Bash script is a simple launcher that uses [jq](https://stedolan.github.io/jq/) for JSON processing and [fzf](https://github.com/junegunn/fzf) for fuzzy finding.
It allows you to select and launch the scripts defined in the `apps.json` file interactively.

## Dependencies
Make sure you have the following dependencies installed before running the script:
- [jq](https://stedolan.github.io/jq/): JSON processor
- [fzf](https://github.com/junegunn/fzf): Fuzzy finder

## How to Use
1. Clone the repository or download the script, and make it executable.
2. Ensure the dependencies are installed.
3. Run the script in a terminal:

```
chmod +x launcher.sh && bash launcher.sh
```

## Notes
- Each app entry in the JSON file should have a name, path, and command.
- If any dependencies are missing, the script will prompt you to install them before execution.
