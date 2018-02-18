#!/usr/bin/env bash
# Commands
# nodem <command> <version> <options>
# Commands:
#   - install <version>
#   - use <version> [--npm]
#   - remove <version>
#   - help
#   - available
#
# Usage:
#   nodem install v4.4.2

set -e

function distribution() {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=linux;;
        Darwin*)    machine=darwin;;
        *)          machine="INCOMPATIBLE DISTRIBUTION: ${unameOut}"
    esac
    echo -e ${machine}
}

TMP_DIR=~/.nodem/tmp
VERSIONS_DIR=~/.nodem/versions
NODEM_DIR=$HOME/.nodem
NODE_DIST_URL='https://nodejs.org/dist'
DISTRIBUTION=$(distribution)

function main() {
    local version=$2
    local option=$3
    case $1 in
        install)
            install $version;;
        use)
            use_version $version $option;;
        remove)
            remove_version $version;;
        list)
            list_installed_versions;;
        available)
            list_versions;;
        *)
            show_help;;
    esac
}

#
# Add files and folders to path
#
function setup_files() {
    # Setup npm's global prefix
    if has_npm; then npm --global config set prefix $NODEM_DIR; fi
    # Setup files
    setup_file "$HOME/.zshrc"
    setup_file "$HOME/.bashrc"
}

#
# Append configurations to a file
#
function setup_file() {
    local file=$1
    local nodem_config='$PATH:$HOME/.nodem'
    if [ -f "$file" ]; then
        if ! file_contains $file $nodem_config; then
            echo 'export PATH=$PATH:$HOME/.nodem' >> $file
        fi
    fi
}

#
# Installs the version <version> specified
#
function install() {
    local version=$1
    exit_if_empty "$version" "version"

    local targz="node-v${version}-${DISTRIBUTION}-x64.tar.gz"

    # Download targz to folder $version
    if [ ! -f ~/.nodem/tmp/$targz ]; then
        yellow "Downloading node-v${version} files"
        download $version
        green "Download successfully completed"
    fi

    echo "Extracting files..."
    tar -xf $TMP_DIR/$targz -C $TMP_DIR
    rm -f $TMP_DIR/$targz

    # move dir to proper location with version
    echo "Installing files..."
    local node_dir=$(ls $TMP_DIR)
    rm -rf $VERSIONS_DIR/$version
    mkdir -p $VERSIONS_DIR/$version
    mv -f $TMP_DIR/$node_dir/* $VERSIONS_DIR/$version
    echo "Node version stored in $VERSIONS_DIR/$version"

    # clean tmp dir
    rm -rf $TMP_DIR
    if ! has_npm; then
        use_version $version --npm
    else
        use_version $version
    fi
    green "Node Version $version successfully installed"
}

function download() {
    local version=$1
    wget $NODE_DIST_URL/v${version}/node-v${version}-${DISTRIBUTION}-x64.tar.gz -P $TMP_DIR
}

function use_version() {
    local version=$1
    local option=$2
    if [[ -z "$version" ]]; then
        yellow "No version informed. Type: 'nodem use <version>'"
        list_installed_versions
        exit 1
    fi
    mkdir -p $NODEM_DIR/bin
    must_have_version $version
    yellow "Creating symbolic links. This requires root access."
    # creates /usr/local/bin/node-vX.X.X
    sudo ln -sf $VERSIONS_DIR/$version/bin/node /usr/local/bin/node-v$version
    # creates $HOME/.nodem/bin/node-vX.X.X
    sudo ln -sf $VERSIONS_DIR/$version/bin/node $NODEM_DIR/bin/node
    # creates /usr/local/bin/node
    sudo ln -sf /usr/local/bin/node-v$version /usr/local/bin/node

    green "Default version changed to $version"

    export PATH=$NODEM_DIR/bin:$PATH
    if [[ ! -z $option ]]; then
        sudo ln -sf $VERSIONS_DIR/$version/bin/npm $NODEM_DIR/bin/npm
        sudo ln -sf $NODEM_DIR/bin/npm /usr/local/bin/npm
        green "Using npm version "`npm -v`
    fi
    setup_files
}

function must_have_version() {
    local version=$1
    if [[ ! -d $VERSIONS_DIR/$version ]]; then
        yellow "Version $version not installed."
        list_installed_versions
        exit 1
    fi
}

#
# List installed versions
#
function list_installed_versions() {
    if [[ ! -d $VERSIONS_DIR/$version ]]; then
        yellow "No version installed yet"
        echo "Use nodem install <version> to install some version"
        exit 0
    fi

    echo "Current installed versions:"
    local versions=$(ls $VERSIONS_DIR)
    for version in $versions; do
        echo_bold_if_current $version
    done
    echo
    echo "Type 'nodem use <version>' to use the specified version."
    echo "Type 'nodem remove <version>' to remove the specified version."
}

#
# List available versions from dist dir
#
function list_versions() {
    echo "Listing available versions"
    dist_versions=`wget --no-check-certificate -O- $NODE_DIST_URL 2> /dev/null | egrep "</a>" \
        | egrep -o '[0-9]+\.[0-9]+\.[0-9]+'\
        | egrep -v '^0\.[0-7]\.'\
        | egrep -v '^0\.8\.[0-5]$'\
        | sort -u -k 1,1n -k 2,2n -k 3,3n -t .`
    if [[ -z "$dist_versions" ]]; then
        red "Could not establish connection with $NODE_DIST_URL. Please check your internet connection."
    fi
    for version in $dist_versions; do
        if is_installed $version; then
            if is_current $version; then
                list_selected `bold_green $version`
            else
                list `bold $version`
            fi
        else
            list $version
        fi
    done
}

function list() {
    echo "    $1"
}
function list_selected() {
    echo "  o $1"
}

#
# Removes the specified version
#
function remove_version() {
    local version=$1
    exit_if_empty $version '<version>'
    must_have_version $version
    if [[ -d $VERSIONS_DIR/$version ]]; then
        rm -rf $VERSIONS_DIR/$version
        green "Version $version removed"
    fi
    if [[ -f "/usr/local/bin/node-v$version" ]]; then
        rm -rf /usr/local/bin/node-v$version
    fi
}

#
# Shows help command
#
function show_help() {
    bold "Usage: "
    echo "    nodem <command> <version> <option>"
    echo
    bold "Available commands:"
    echo "  - install <version>     Installs the node <version>."
    echo "  - use <version> <--npm> Creates symbolic links for the <version> installed."
    echo "  - remove <version>      Removes the node installed <version>."
    echo "  - available             Lists all available node versions in https://nodejs.org/dist."
    echo "  - list                  Lists all installed node versions."
    echo "  - help                  Shows this help."
}

#
# Echoes string in bold if it is the current node version
#
function echo_bold_if_current() {
    local version=$1
    local current_version=`node -v 2> /dev/null`
    if [[ $version == ${current_version//v} ]]; then
        blue "    $version"
    else
        echo "    $version"
    fi
}

function is_current() {
    local version=$1
    local current_version=`node -v 2> /dev/null`
    if [[ $version == ${current_version//v} ]]; then
        return 0
    fi
    return 1
}

function has_npm() {
    command -v npm > /dev/null 2>&1
    return $?
}

function file_contains() {
    local file=$1
    local str=$2
    if grep -q $str "$file"; then
        return 0
    fi
    return 1
}

function is_installed() {
    if [[ -d $VERSIONS_DIR/$1 ]]; then
        return 0
    fi
    return 1
}

#
# Exit script if param is empty
#
function exit_if_empty() {
    if [[ -z $1 ]]; then
        echo "Missing argument <$2>"
        exit 1
    fi
}

function bold() {
    echo -e "\033[1m$1\033[0m"
}
function blue() {
    echo -e "\033[34m${1}\033[0m"
}
function bold_blue() {
    echo -e "\033[1;34m${1}\033[0m"
}
function green() {
    echo -e "\033[32m${1}\033[0m"
}
function bold_green() {
    echo -e "\033[1;32m${1}\033[0m"
}
function yellow() {
    echo -e "\033[33m${1}\033[0m"
}
function bold_yellow() {
    echo -e "\033[1;33m${1}\033[0m"
}
function red() {
    echo -e "\033[31m${1}\033[0m"
}

main "$@"
