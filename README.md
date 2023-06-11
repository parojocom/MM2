## Mouse Mover 2 for MacOS ##

A command-line application that automatically moves your mouse cursor around your primary display.

On launch the application can be told how long to run (-d) or when to end (-e), and automatically pauses itself whenever the user is interacting with keyboard or mouse. After the user's interactions stopped the application will resume its automated movement of the cursor.

Usage screen from the application:

```
** MM - USAGE - START **************************
**
** --help           Shows usage screen.
**
** -d               Number of seconds program will run for.
** --duration
**
** -e               Date and time program should end at.
** --endDate        "2004-02-29 16:21:42", "16:21:42",
**                  or unix timestamp (seconds)
**
** -s               Number of seconds to wait before starting
** --startDelay     program.
**
** -i               Number of seconds to wait between each
** --moveInterval   movement.
**
** -m               Number of pixels per movement.
** --moveStep
**
** -p               Number of seconds to wait before
** --pauseInterval  resuming movement after a real
**                  movement has occurred.
**
** MM - USAGE - END ****************************
```
