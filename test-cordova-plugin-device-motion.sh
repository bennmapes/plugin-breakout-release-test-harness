set -e
version=2.6.0
release="cordova-$version"
release_artifact="$release-src.zip"
release_url="https://www.apache.org/dist/cordova/$release_artifact"
plugin="https://git-wip-us.apache.org/repos/asf/cordova-plugin-device-motion.git"

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

# downloads cordova
download() {
    if [ -e $release_artifact ]
    then
        info "Skipping Cordova download."
    else
        echo
        info "Downloading Cordova" $release_url
        echo
        curl -O $release_url
        echo
    fi
}

# unzips cordova, then ios, and android
unpack() {
    info "Unzipping $release_artifact"
    unzip -qqo $release_artifact
    cd ./$release
    unzip -qqo "cordova-ios.zip" -d cordova-ios
    unzip -qqo "cordova-android.zip" -d cordova-android
    cd ..
}

# creates an ios project called FooBar
# creates an android project called FooBaz
native_create() {
    if [ -e ./FooBar ]
    then
        info "Skipping iOS project creation."
    else
        info "Creating iOS project FooBar."
        ./$release/cordova-ios/bin/create FooBar org.apache.cordova.FooBar FooBar
    fi
    if [ -e ./FooBaz ]
    then
        info "Skipping Android project creation."
    else
        info "Creating Android project FooBaz."
        ./$release/cordova-android/bin/create FooBaz org.apache.cordova.FooBar FooBaz
    fi
}

# attempts to install plugin into ios project called FooBar
plugman_install() {
    which plugman &>/dev/null
    if [ $? -eq 0 ]
    then
        
        info "Installing iOS"
        warn "plugman --platform ios --project ./FooBar --plugin $plugin"
        plugman --platform ios --project ./FooBar --plugin $plugin
        if [ "$?" = "0" ]
        then
            ok "Plugman successfully installed $plugin into iOS project FooBar."
        else
            error "Plugman did not install $plugin into iOS project FooBar."
        fi
        echo
        
        info "Installing Android" 
        warn "plugman --platform android --project ./FooBaz --plugin $plugin"        
        plugman --platform android --project ./FooBaz --plugin $plugin
        if [ "$?" = "0" ]
        then
            ok "Plugman successfully installed $plugin into Android project FooBaz."
        else
            error "Plugman did not install $plugin into Android project FooBaz."
        fi
        echo
    else
        warn "Missing Plugman?" "npm install -g plugman"
    fi
}

<<COMMENT
copy_plugin_tests() {
    copy ./cordova/plugins/cordova-plugin-device-motion/tests into ./www
}
COMMENT

# removes test artifacts
cleanup() {
    info "Cleanup"
    rm -rf $release
}


download
unpack
native_create
plugman_install
cleanup

echo
error "Tests above should fail in current case."
error "Installing iOS, and Android should work!"
warn "TODO" "Copy tests from mobile-spec into $plugin ./test dir."
echo
