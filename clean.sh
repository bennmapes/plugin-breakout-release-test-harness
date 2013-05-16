#set -e
projectName=("deviceMotion" "deviceOrientation")

# get Length of plugins array
plen=${#projectName[@]}

info() {
    local grey=$(tput setaf 8)
    local blue=$(tput setaf 6)
    local reset=$(tput sgr0) 
    echo "${grey}....${reset} ${blue}$1${reset} $2"
}

#deletes all created projects
clean(){
    info "cleaning up project"
    for (( i=0; i<${plen}; i++));
    do
        rm -rf ${projectName[i]}ios
        rm -rf ${projectName[i]}android
    done
    rm -rf "mastertestios"
    rm -rf "mastertestandroid"
    rm -rf "cordova-android"
    rm -rf "cordova-ios"
    rm -rf "cordova-mobile-spec"
}

clean
