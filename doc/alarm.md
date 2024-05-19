# Bash Alarm Script

## Overview
This is a basic Bash script to set a simple alarm, allowing users to input a time interval.

The script uses various dependencies such as bash, dunstify, espeak, and zenity.

## Requirements
Make sure you have the following dependencies installed:
- dunstify
- espeak
- zenity

## Usage
Clone the repository or download the script.
Make the script executable:

```
chmod +x alarm.sh
```

Run the script:

```
./alarm.sh
```

## Features
* If Zenity and Espeak are not found, a terminal version will run, prompting you to enter the time interval in HH:MM:SS format.

* If Zenity and Espeak are available, a graphical interface will prompt you for the time interval.

* A progress bar will be displayed, and espeak will announce when the time is up.

* An info dialog will appear, indicating that it's time to quit.
