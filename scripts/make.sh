#!/bin/bash

if [ ! -f "Makefile" ]; then
	exit 0
fi

for i in "$@"; do
	if grep -qE "^${i}:" Makefile; then
		make "$i" && exit 0 || exit 1
	fi
done
