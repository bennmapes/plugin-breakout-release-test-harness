#set -e
version=2.6.0
plugin="https://git-wip-us.apache.org/repos/asf/cordova-plugin-device-motion.git"
android_url="https://git-wip-us.apache.org/repos/asf/cordova-android.git"
ios_url="https://git-wip-us.apache.org/repos/asf/cordova-ios.git"

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

# creates an ios project called FooBar
# creates an android project called FooBaz
native_create() {
    if [ -e ./FooBar ]
    then
        info "Skipping iOS project creation."
    else
        info "Creating iOS project FooBar."
        ./cordova-ios/bin/create FooBar org.apache.cordova.FooBar FooBar
    fi
    if [ -e ./FooBaz ]
    then
        info "Skipping Android project creation."
    else
        info "Creating Android project FooBaz."
        ./cordova-android/bin/create FooBaz org.apache.cordova.FooBar FooBaz
    fi
}

#fetches device motion plugin
plugman_fetch(){
    which plugman &>/dev/null
    if [ $? -eq 0 ]
    then
       
	    info "Fetching Plugin" 
        warn "plugman --fetch --plugin $plugin --plugins_dir ./plugins"     
        plugman --fetch --plugin $plugin --plugins_dir ./plugins
        if [ "$?" = "0" ]
        then
            ok "Plugman successfully fetched $plugin into plugins directory."
        else
            error "Plugman did not fetch $plugin into plugins directory."
        fi
        echo

    else
        warn "Missing Plugman?" "npm install -g plugman"
    fi
}

plugman_install() {
    which plugman &>/dev/null
    if [ $? -eq 0 ]
    then
       
	    info "Installing Android" 
        warn "plugman --platform android --project ./FooBaz --plugin cordova-plugin-device-motion --plugins_dir ./plugins"   
        plugman --platform android --project ./FooBaz --plugin cordova-plugin-device-motion --plugins_dir ./plugins 
        
        if [ "$?" = "0" ]
        then
            ok "Plugman successfully installed $plugin into Android project FooBaz."
        else
            error "Plugman did not install $plugin into Android project FooBaz."
        fi

        echo
        info "Installing iOS"
        warn "plugman --platform ios --project ./FooBar --plugin cordova-plugin-device-motion --plugins_dir ./plugins"   
	    plugman --platform ios --project ./FooBar --plugin cordova-plugin-device-motion --plugins_dir ./plugins
 	    
        if [ "$?" = "0" ]
        then
            ok "Plugman successfully installed $plugin into iOS project FooBar."
        else
            error "Plugman did not install $plugin into iOS project FooBar."
        fi    
        echo

        
    else
        warn "Missing Plugman?" "npm install -g plugman"
    fi
}

copy_plugin_tests() {
    info "Copying tests files into www"
    cp -rf plugins/cordova-plugin-device-motion/test/* FooBaz/assets/www/
    cp -rf plugins/cordova-plugin-device-motion/test/* FooBar/www/
}

# behold! self documenting code
clone_android
clone_ios
native_create
plugman_fetch
plugman_install
copy_plugin_tests
