# Locker
Script that locks directories when a command is ran through it. 
Use it to make sure only one instance of something can be run in a directory at once, and remote kill it if an unwanted version is open somewhere else(requires the script to be used in some kind of networked storage or syncing).

This script is based on what I made for [Firebox](https://github.com/xarinatan/Firebox), with some slight modifications to make command line propagation work properly.

Examples of usage:
 - `./locker.sh firefox --profile localprofile --no-remote` (make sure `localprofile` directory exists), this is basically what [Firebox](https://github.com/xarinatan/Firebox) does.
 - `./locker.sh kwrite somedocument.txt` If everyone runs through Locker you can make sure there's only one person editing the file
