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
            list_versions;;
        *)
            show_help;;
    esac
}

function install {
    command=$1
    exit_if_empty "$command" "install"

    # Parse version
    local version=$(extract_version_from $command)
    local targz="node-${version}-linux-x64.tar.gz"

    # Download targz to folder $version
    if [ ! -f ~/.nodem/tmp/$targz ]; then
        warning "Downloading node-${version} files"
        wget https://nodejs.org/dist/${version}/node-${version}-linux-x64.tar.gz -P $TMP_DIR
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
    success "Node Version $version successfully installed"
}

function use_version {
    local version=$1
    local option=$2
    if [[ -z "$version" ]]; then
        warning "No version informed. Type: 'nodem use <version>'"
        list_versions
        exit 1
    fi
    must_have_version $version
    warning "Creating symbolic links. This requires root access."
    if [[ ! -z $option ]]; then
        sudo ln -sf $VERSIONS_DIR/$version/bin/npm /usr/local/bin/npm
        success "Using npm version "`npm -v`
    fi
    sudo ln -sf $VERSIONS_DIR/$version/bin/node /usr/local/bin/node-$version
    sudo ln -sf /usr/local/bin/node-$version /usr/local/bin/node
    success "Default version changed to $version"
    export PATH=$PREFIX/bin:$PATH
}

function must_have_version {
    local version=$1
    if [[ ! -d $VERSIONS_DIR/$version ]]; then
        warning "Version $version not installed."
        list_versions
        exit 1
    fi
}

# Lista versões instaladas
function list_versions {
    if [[ ! -d $VERSIONS_DIR/$version ]]; then
        warning "No version installed yet"
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

function remove_version {
    local version=$1
    exit_if_empty $version '<version>'
    must_have_version $version
    if [[ -d $VERSIONS_DIR/$version ]]; then
        rm -rf $VERSIONS_DIR/$version
        success "Version $version removed"
    fi
    if [[ -f "/usr/local/bin/node-$version" ]]; then
        rm -rf /usr/local/bin/node-$version
    fi
}

# Shows help command
function show_help {
    bold "Usage: "
    echo "    nodem <command> <version> <option>"
    echo
    bold "Available commands:"
    echo "  - install <version>     Installs the node <version>."
    echo "  - use <version> <--npm> Creates symbolic links for the <version> installed."
    echo "  - remove <version>      Removes the node installed <version>."
    echo "  - list                  Lists all installed node versions."
    echo "  - help                  Shows this help."
}

# Escreve a versao em negrito se for a versao em uso
function echo_bold_if_current {
    local version=$1
    local current_version=`node -v 2> /dev/null`
    if [[ $version == $current_version ]]; then
        bold "    \e[1m$version\e[21m"
    else
        echo "    $version"
    fi
}

function bold {
    echo -e "\e[1m$1\e[21m"
}

# Exit script if param is empty
function exit_if_empty {
    if [[ -z $1 ]]; then
        echo "Missing argument <$2>"
        exit 1
    fi
}

function extract_version_from {
    echo $1 | sed 's/.*dist\/\(v.*\)\/.*/\1/'
}

function success {
    echo -e "\e[32m${1}\e[0m"
}
function warning {
    echo -e "\e[33m${1}\e[0m"
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
