#!/usr/bin/env bash

# This script assumes the current working directory is the root of the workspace

command=$0

display_usage () {
    echo Run common post-create commands for a VS Code devcontainer
    echo "usage: $command [-h]"
    echo "   -h: Display help/usage"
    exit 1
}

while getopts h flag
do
    case "${flag}" in
        h) display_usage;
    esac
done

echo Running devcontainer post-create commands

echo Copying dev certificates to ./src to make available in docker build contexts, and adding to .gitignore if necessary
cp -v /aspnet/https/* ./src/
for ext in pfx crt; do
    if  [ -z $(grep "\*\*\/\*\.${ext}" ./.gitignore) ]; then
        echo "**/*.${ext}" >> ./.gitignore
        echo "**/*.${ext}" added to .gitignore
    fi
done

exit 0
