#!/usr/bin/env bash

BUILDPACK_LOG_FILE="$(mktemp)"
export BUILDPACK_LOG_FILE

mmeasure() {
	:
}

mcount() {
	:
}

mtime() {
	:
}

mnow() {
	date +%s%3N
}

nowms() {
	date +%s%3N
}
