#!/bin/bash

if [ ! -f "Makefile" ]; then
	exit 1
fi

for i in "$@"; do
	if grep -qE "^${i}:" Makefile; then
		echo "found: 'make $i', running..."
		make "$i" && exit 0 || exit 1
	fi
done

echo "no make targets found matching: ${*}"
exit 1
