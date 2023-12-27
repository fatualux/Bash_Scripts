# Bash Alarm Script

This is a basic Bash script to set a simple alarm, allowing users to input a time interval. The script uses various dependencies such as bash, dunstify, espeak, and zenity.

## Prerequisites

Make sure you have the following dependencies installed:
- bash
- dunstify
- espeak
- zenity

You can install them using your package manager.

## Usage

1. Run the script in the terminal.
2. If Zenity and Espeak are not found, a terminal version will run, prompting you to enter the time interval in HH:MM:SS format.
3. If Zenity and Espeak are available, a graphical interface will prompt you for the time interval.
4. A progress bar will be displayed, and espeak will announce when the time is up.
5. An info dialog will appear, indicating that it's time to quit.

## Script Structure

- The script checks for the availability of Zenity and Espeak.
- If unavailable, it runs a terminal version to get the time interval.
- A progress bar is displayed based on the entered time interval.
- Espeak announces when it's time to shut down.
- An info dialog appears when the time is up.

## Dependencies

- bash
- dunstify
- espeak
- zenity
