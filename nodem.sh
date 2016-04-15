#!/usr/bin/env bash
set -e

TMP_DIR=~/.nodem/tmp
VERSIONS_DIR=~/.nodem/versions
nodem_DIR=~/.nodem
PREFIX=$nodem_DIR

function main {
    command=$2
    case $1 in
        install)
            install $command
            npm config set prefix $PREFIX;;
        use)
            use_version $command $3;;
        remove)
            remove_version $command;;
        list)
            list_installed_versions;;
        available)
            list_versions;;
        *)
            show_help;;
    esac
}

#
# Installs the version <version> specified
#
function install {
    version=$1
    exit_if_empty "$version" "version"

    local targz="node-v${version}-linux-x64.tar.gz"

    # Download targz to folder $version
    if [ ! -f ~/.nodem/tmp/$targz ]; then
        yellow "Downloading node-v${version} files"
        wget https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.gz -P $TMP_DIR
        echo "Download successfully completed"
        echo
    fi

    echo "Extracting files..."
    tar -xf $TMP_DIR/$targz -C $TMP_DIR
    rm -f $TMP_DIR/$targz

    # move dir to proper location with version
    echo "Installing files..."
    local node_dir=$(ls $TMP_DIR)
    rm -rf $VERSIONS_DIR/$version
    mkdir -p $VERSIONS_DIR/$version
    mv -uf $TMP_DIR/$node_dir/* $VERSIONS_DIR/$version
    echo "Node version stored in $VERSIONS_DIR/$version"

    # clean tmp dir
    rm -rf $TMP_DIR
    use_version $version
    green "Node Version $version successfully installed"
}

function use_version {
    local version=$1
    local option=$2
    if [[ -z "$version" ]]; then
        yellow "No version informed. Type: 'nodem use <version>'"
        list_installed_versions
        exit 1
    fi
    must_have_version $version
    yellow "Creating symbolic links. This requires root access."
    if [[ ! -z $option ]]; then
        sudo ln -sf $VERSIONS_DIR/$version/bin/npm /usr/local/bin/npm
        green "Using npm version "`npm -v`
    fi
    sudo ln -sf $VERSIONS_DIR/$version/bin/node /usr/local/bin/node-v$version
    sudo ln -sf /usr/local/bin/node-v$version /usr/local/bin/node
    green "Default version changed to $version"
    export PATH=$PREFIX/bin:$PATH
}

function must_have_version {
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
function list_installed_versions {
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
function list_versions {
    echo "listing available versions"
    dist_versions=`wget -O- https://nodejs.org/dist/ 2> /dev/null | egrep "</a>" \
        | egrep -o '[0-9]+\.[0-9]+\.[0-9]+'\
        | egrep -v '^0\.[0-7]\.'\
        | egrep -v '^0\.8\.[0-5]$'\
        | sort -u -k 1,1n -k 2,2n -k 3,3n -t .`
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

function list {
    echo "    $1"
}
function list_selected {
    echo "  o $1"
}

#
# Removes the specified version
#
function remove_version {
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
function show_help {
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
function echo_bold_if_current {
    local version=$1
    local current_version=`node -v 2> /dev/null`
    if [[ $version == ${current_version//v} ]]; then
        bold "    $version"
    else
        echo "    $version"
    fi
}

function is_current {
    local version=$1
    local current_version=`node -v 2> /dev/null`
    if [[ $version == ${current_version//v} ]]; then
        return 0
    else
        return 1
    fi
}

function is_installed {
    if [[ -d $VERSIONS_DIR/$1 ]]; then
        return 0
    else
        return 1
    fi
}

#
# Exit script if param is empty
#
function exit_if_empty {
    if [[ -z $1 ]]; then
        echo "Missing argument <$2>"
        exit 1
    fi
}

function bold {
    echo -e "\e[1m$1\e[21m"
}
function green {
    echo -e "\e[32m${1}\e[0m"
}
function bold_green {
    echo -e "\e[1;32m${1}\e[0m"
}
function yellow {
    echo -e "\e[33m${1}\e[0m"
}
function bold_yellow {
    echo -e "\e[1;33m${1}\e[0m"
}

main "$@"

# Commands
# nodem <command> <version> <options>
# Commands:
#   - install <version>
#   - use <version>
#   - remove <version>
#   - help
#
# Usage:
#   nodem install v4.4.2
