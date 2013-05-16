#set -e
plugins=("https://git-wip-us.apache.org/repos/asf/cordova-plugin-device-motion.git" "https://git-wip-us.apache.org/repos/asf/cordova-plugin-device-orientation.git") 
pluginName=("cordova-plugin-device-motion" "cordova-plugin-device-orientation")
projectName=("deviceMotion" "deviceOrientation")
android_url="https://git-wip-us.apache.org/repos/asf/cordova-android.git"
ios_url="https://git-wip-us.apache.org/repos/asf/cordova-ios.git"
ms_url="https://git-wip-us.apache.org/repos/asf/cordova-mobile-spec.git"


# prints an error message
# usage:
# error|ok|warn|info "Error title here" "another message here"
error() {
    local red=${txtbld}$(tput setaf 1)
    local reset=$(tput sgr0) 
    echo "${red}FAIL${reset} $1"
}

ok() {
    local green=${txtbld}$(tput setaf 2)
    local reset=$(tput sgr0) 
    echo " ${green}WIN${reset} $1"
}

warn() {
    local yellow=${txtbld}$(tput setaf 3)
    local reset=$(tput sgr0) 
    echo "${yellow}$1${reset} $2"
}

info() {
    local grey=$(tput setaf 8)
    local blue=$(tput setaf 6)
    local reset=$(tput sgr0) 
    echo "${grey}....${reset} ${blue}$1${reset} $2"
}

# downloads cordova android
clone_android() {
    if [ -e ./cordova-android ]
    then
        info "Skipping Cordova Android download"
    else
        echo
        info "Downloading Cordova Android"
        echo
        git clone $android_url
        cd cordova-android && git fetch && git checkout 3.0.0 && cd ../
        echo
    fi
}

# downloads cordova ios
clone_ios() {
    if [ -e ./cordova-ios ]
    then
        info "Skipping Cordova iOS download"
    else
        echo
        info "Downloading Cordova iOS"
        echo
        git clone $ios_url
        cd cordova-ios && git fetch && git checkout 3.0.0 && cd ../
        echo
    fi
}

# downloads cordova mobilespec
clone_mobilespec() {
    if [ -e ./cordova-mobile-spec ]
    then
        info "Skipping Cordova Mobile-Spec download"
    else
        echo
        info "Downloading Cordova Mobile-Spec"
        echo
        git clone $ms_url
        echo
    fi
}

# creates ios and android projects
native_create() {
    if [ -e ./$1ios ]
    then
        info "Skipping iOS project creation for $1ios."
    else
        info "Creating iOS project $1ios."
        ./cordova-ios/bin/create $1ios org.apache.cordova.$1ios $1ios
    fi

    if [ -e ./$1android ]
    then
        info "Skipping Android project creation for $1android."
    else
        info "Creating Android project $1android."
        ./cordova-android/bin/create $1android org.apache.cordova.$1android $1android
    fi

}

plugman_install() {
    which plugman &>/dev/null
    if [ $? -eq 0 ]
    then
       
        info "Installing Android" 
        warn "plugman --platform android --project ./$2android --plugin $1"   
        plugman --platform android --project ./$2android --plugin $1
        
        if [ "$?" = "0" ]
        then
            ok "Plugman successfully installed $1 into Android project $2android."
        else
            error "Plugman did not install $1 into Android project $2android."
        fi

        echo
        info "Installing iOS"
        warn "plugman --platform ios --project ./$2ios --plugin $1"   
        plugman --platform ios --project ./$2ios --plugin $1

        if [ "$?" = "0" ]
        then
            ok "Plugman successfully installed $1 into iOS project $2ios."
        else
            error "Plugman did not install $1 into iOS project $2ios."
        fi    
        echo

        
    else
        warn "Missing Plugman?" "npm install -g plugman"
    fi
}

copy_tests_ms() {
    info "Copying tests files for mobile spec into $1android's www"
    cp -rf $2/* $1android/assets/www/

    info "Copying tests files for mobile spec into $1ios www"
    mv -f $1ios/www/cordova.js ./cordova.js
    cp -rf $2/* $1ios/www/
    mv -f ./cordova.js $1ios/www/cordova.js

    echo
}

copy_tests() {
    info "Copying tests files for $1 into android www"
    cp -rf $2android/cordova/plugins/$1/test/* $2android/assets/www/

    info "Copying tests files for $1 into ios www"
    mv -f $2ios/www/cordova.js ./cordova.js
    cp -rf $2ios/cordova/plugins/$1/test/* $2ios/www/
    mv -f ./cordova.js $2ios/www/cordova.js

    echo
}


# behold! self documenting code
clone_android
clone_ios

# get Length of plugins array
plen=${#plugins[@]}

# run commands for every plugin
for (( i=0; i<${plen}; i++ ));
do 
    native_create ${projectName[i]}
    plugman_install ${plugins[i]} ${projectName[i]}
    copy_tests ${pluginName[i]} ${projectName[i]}
done

# install all of the plugins in one project
# test with mobile spec
master_test(){
    native_create "mastertest"
    for (( i=0; i<${plen}; i++));
    do
        plugman_install ${plugins[i]} "mastertest"
    done
    clone_mobilespec
    copy_tests_ms "mastertest" "./cordova-mobile-spec"
}

master_test
