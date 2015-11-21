#!/bin/bash

check_unsaved_changes() {
    # Update the index
    git update-index -q --ignore-submodules --refresh

    # unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --
    then
        return 0
    fi

    # uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --
    then
        return 0
    fi

    return 1
}

prev_version_tag=`git describe --tags --abbrev=0 --match "v[0-9]*"` # filter only major version tags
prev_version=`echo $prev_version_tag | cut -c 2-10` # cut off "v" symbol
new_version=$(($prev_version+1))
new_version_tag="v$new_version"

filename=code-racing-$new_version_tag.zip

command -v zip >/dev/null 2>&1
if [ $? -eq 0 ]; then
    mkdir -p ./tmp
    check_unsaved_changes
    had_unsaved_changes=$?
    if [ $had_unsaved_changes -eq 0 ]; then
        echo "You have unstaged changes"
        exit 1
    fi
    zip -j ./tmp/$filename ./app/*
else
    echo "WARNING: 'zip' is not found. Please make '$filename' manually."
fi

git tag $new_version_tag
git push --tags origin master
