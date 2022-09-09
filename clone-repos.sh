#!/bin/bash

source bin/repos.sh

mkdir -p repos

cd repos
for dir in "${newspack_plugins[@]}"
    do :
        git clone git@github.com:Automattic/${dir}.git
    done

git clone git@github.com:Automattic/newspack-theme.git
