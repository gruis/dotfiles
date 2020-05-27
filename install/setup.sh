#!/usr/bin/env bash
# https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh

set -e

declare -r GITHUB_REPOSITORY="gruis/dotfiles"
declare -r GITHUB_BRANCH=${GITHUB_BRANCH:=master}

declare -r DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"
declare -r DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/$GITHUB_BRANCH"
declare -r DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/$GITHUB_BRANCH/install/utils.sh"

declare dotfilesDirectory="$HOME/dotfiles"
declare skipQuestions=false


download() {
    local url="$1"
    local output="$2"
    if command -v "curl" &> /dev/null; then
        curl -LsSo "$output" "$url" &> /dev/null
        #     │││└─ write output to file
        #     ││└─ show error messages
        #     │└─ don't show the progress meter
        #     └─ follow redirects
        return $?
    elif command -v "wget" &> /dev/null; then
        wget -qO "$output" "$url" &> /dev/null
        #     │└─ write output to file
        #     └─ don't show output
        return $?
    fi
    return 1
}

download_dotfiles() {
    local tmpFile=""
    print_in_purple "\n • Download and extract archive\n\n"
    tmpFile="$(mktemp /tmp/XXXXX)"
    download "$DOTFILES_TARBALL_URL" "$tmpFile"
    print_result $? "Download archive" "true"
    printf "\n"

    if ! $skipQuestions; then
        ask_for_confirmation "Do you want to store the dotfiles in '$dotfilesDirectory'?"
        if ! answer_is_yes; then
            dotfilesDirectory=""
            while [ -z "$dotfilesDirectory" ]; do
                ask "Please specify another location for the dotfiles (path): "
                dotfilesDirectory="$(get_answer)"
            done
        fi
        # Ensure the `dotfiles` directory is available
        while [ -e "$dotfilesDirectory" ]; do
            ask_for_confirmation "'$dotfilesDirectory' already exists, do you want to overwrite it?"
            if answer_is_yes; then
                rm -rf "$dotfilesDirectory"
                break
            else
                dotfilesDirectory=""
                while [ -z "$dotfilesDirectory" ]; do
                    ask "Please specify another location for the dotfiles (path): "
                    dotfilesDirectory="$(get_answer)"
                done
            fi
        done
        printf "\n"
    else
        rm -rf "$dotfilesDirectory" &> /dev/null
    fi

    mkdir -p "$dotfilesDirectory"
    print_result $? "Create '$dotfilesDirectory'" "true"

    extract "$tmpFile" "$dotfilesDirectory"
    print_result $? "Extract archive" "true"

    rm -rf "$tmpFile"
    print_result $? "Remove archive"

    cd "$dotfilesDirectory" \
        || return 1
}

download_utils() {
    local tmpFile=""
    tmpFile="$(mktemp /tmp/XXXXX)"
    download "$DOTFILES_UTILS_URL" "$tmpFile" \
        && . "$tmpFile" \
        && rm -rf "$tmpFile" \
        && return 0
   return 1
}

extract() {
    local archive="$1"
    local outputDir="$2"
    if command -v "tar" &> /dev/null; then
        tar -zxf "$archive" --strip-components 1 -C "$outputDir"
        return $?
    fi
    return 1
}

verify_os() {
    declare -r MINIMUM_UBUNTU_VERSION="18.04"

    local os_name="$(get_os)"
    local os_version="$(get_os_version)"
    if [ "$os_name" == "ubuntu" ]; then
        if is_supported_version "$os_version" "$MINIMUM_UBUNTU_VERSION"; then
            return 0
        else
            printf "Sorry, this script is intended only for Ubuntu %s+" "$MINIMUM_UBUNTU_VERSION"
        fi
    else
        printf "Sorry, this script is intended only for Ubuntu!"
    fi
    return 1
}


main() {
    cd "$(dirname "${BASH_SOURCE[0]}")" \
        || exit 1
    if [ -x "utils.sh" ]; then
        . "utils.sh" || exit 1
    else
        download_utils || exit 1
    fi

    verify_os \
        || exit 1

    skip_questions "$@" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ask_for_sudo

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if this script was run directly (./<path>/setup.sh),
    # and if not, it most likely means that the dotfiles were not
    # yet set up, and they will need to be downloaded.

    printf "%s" "${BASH_SOURCE[0]}" | grep "setup.sh" &> /dev/null \
        || download_dotfiles

    if $skipQuestions; then
      $dotfilesDirectory/bootstrap.sh --force
    else
      $dotfilesDirectory/bootstrap.sh
    fi
}

{
main "$@"
}  2>&1 | tee ~/dotfiles.log
