#!/bin/bash
#note: the 'start' of the script is at the bottom. Main() is ran which checks for lock files and if there are none, the program is executed.

trap ctrl_c INT
weAreRunning=false
interactive=false
ProgramPID=0
inputLine=$@
inputLineArr=($inputLine)

function ctrl_c() {
    if $weAreRunning ;
    then
        echo -n "Ctrl+C Caught. "
        clean_exit
    else
        echo "Ctrl+C Caught. Terminating script (leaving lock files in tact)"
        exit
    fi
    
}

function check_for_lock(){
    if [ -f ./.lock ]; then
        if  ! $interactive ; then
            echo "Cannot get user input. exiting.." 
            exit
        fi
        
        read -r -p "Lock exists. Do you want to issue a remote kill request? (WARNING Remote open data will be lost!)[y/N]" response
        case "$response" in
            [yY][eE][sS]|[yY]) 
            Time=`date`
            echo "Issued by $USER@$HOSTNAME at $Time" > ./.kill
            echo -n "Kill command issued. Please wait a short while to give the sync application and remote machine a chance to terminate the session (Press Ctrl+C at any time to abort and clean up)."
            waiting=true 
            while $waiting; do
                if [ -f ./.lock ]; then 
                    echo -n "."
                else
                    waiting=false
                    echo "!"
                    Main
                fi
            sleep 2; done
            exit
            ;;
        *)
            echo "Please close the remote session and make sure there's no more lock file."
            exit
            ;;
        esac
        
    else
        true
    fi
    
}


function update_lockfile(){
        echo $ProgramPID > .lock
        echo " on machine " >> .lock
        echo $HOSTNAME >> .lock
}


function Main(){
    if check_for_lock ; then
        touch .lock

        weAreRunning=true
        echo "Starting $inputLine and logging to console.log.."
        $inputLine > console.log 2>&1 & #This is where the other program and any arguments gets executed
        ProgramPID=`echo $!`
        RunCheck=true
        echo "${inputLineArr[0]}($ProgramPID) is running. Hit Ctrl+C to kill the program and clean up, or exit the program from within to clean up automatically."
        while $RunCheck; do
            if [ -f ./.kill ]; then
                MSG=`cat ./.kill`
                echo -n "Kill request found with message $MSG. " 
                RunCheck=false
                clean_exit
            fi
            
            if ! ps -p $ProgramPID > /dev/null
             then
                echo "${inputLineArr[0]}($ProgramPID) is no longer running. Did it crash? Tailing console.log for any useful info.."
                echo "----------------------------------------------------------------------------------------------"
                tail console.log
                clean_exit
            fi
            

            
            update_lockfile
            sleep 2;
        done
    fi
}

function clean_exit(){
    echo "Cleaning up and exiting script.."

    if ps -p $ProgramPID > /dev/null
    then
        echo "${inputLineArr[0]}($ProgramPID) is still running. Killing ${inputLineArr[0]}($ProgramPID).."
        kill $ProgramPID #TODO: Is there a cleaner way? Even though just sending sigterm isn't that harsh..
    fi
    rm -f ./.lock
    rm -f ./.kill
    exit
}
if [ -t 1 ] ; then 
    echo "Interactive terminal detected.."
    interactive=true
else 
    echo "WARNING: This shell is not interactive! Will exit if requiring user input.."
fi

Main #Main part of the script starts here, after the function definitions.

echo "Something went wrong.. This part of the script isn't meant to be run. Did spacetime collapse?"
