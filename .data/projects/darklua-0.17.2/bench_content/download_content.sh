#!/bin/sh

BENCH_CONTENT_PATH=$(dirname -- $0)
cd $BENCH_CONTENT_PATH

install_content () {
    DIR_NAME=$1
    REMOTE=$2
    COMMIT=$3

    echo "installing" $DIR_NAME "..."

    rm -rf $DIR_NAME
    mkdir -p $DIR_NAME
    cd $DIR_NAME

    git init
    git remote add origin $REMOTE
    git fetch origin $COMMIT
    git reset --hard FETCH_HEAD

    git submodule init
    git submodule update

    cd ..
}

install_content crosswalk https://gitlab.com/seaofvoices/crosswalk.git 1c558f410d77eec8812172c0910dcca95eb296ad
install_content roact https://github.com/roblox/roact.git 956891b70fdc5410e44e9664719cd0a9f7e6fabd
install_content core-packages https://github.com/grilme99/CorePackages.git 9361306914b67d42891f5ef657ce73943d5b070d
