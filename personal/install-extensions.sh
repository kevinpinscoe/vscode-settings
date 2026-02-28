#!/usr/bin/env bash

while IFS= read -r line; do
    echo "Installing : $line"
	code --install-extension "${line}"
done < extensions.txt

