#!/usr/bin/env bash

# Reads the value of a key from a Java properties file
#
# ```
# java_properties:get "system.properties" "java.runtime.version"
# ```
java_properties::get() {
	local file=${1:?}
	local key=${2:?}

	if [ -f "${file}" ]; then
		local escaped_key
		escaped_key="${key//\./\\.}"

		grep -E "^${escaped_key}[[:space:]=]+" "${file}" |
			sed -E -e "s/${escaped_key}([\ \t]*=[\ \t]*|[\ \t]+)([_A-Za-z0-9\.-]*).*/\2/g"
	else
		echo ""
	fi
}
