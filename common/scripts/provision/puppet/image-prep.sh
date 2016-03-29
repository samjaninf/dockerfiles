#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------

set -e

# Check if a Puppet folder is set
if [ -z "$PUPPET_HOME" ]; then
    echoError "Puppet home folder could not be found! Set PUPPET_HOME environment variable pointing to local puppet folder."
    exit 1
fi

# $1 product name = esb
# $2 product version = 4.9.0
function validateProductVersion() {
    ver_dir="${PUPPET_HOME}/hieradata/dev/wso2/${1}/${2}"
    if [ ! -d "$ver_dir" ]; then
        echoError "Provided product version ${1}:${2} doesn't exist in PUPPET_HOME: ${PUPPET_HOME}. Available versions are,"
        listFiles "${PUPPET_HOME}/hieradata/dev/wso2/${1}/"
        echo
        exit 1
    fi
}

# $1 product name = esb
# $2 product version = 4.9.0
# $3 product profile list = 'default|worker|manager'
function validateProfile() {
    invalidFound=false
    IFS='|' read -r -a array <<< "${3}"
    for profile in "${array[@]}"
    do
        profile_yaml="${PUPPET_HOME}/hieradata/dev/wso2/${1}/${2}/${profile}.yaml"
        if [ ! -e "${profile_yaml}" ] || [ ! -s "${profile_yaml}" ]
        then
            invalidFound=true
        fi
    done

    if [ "${invalidFound}" == true ]
    then
        echoError "One or more provided product profiles ${1}:${2}-[${3}] do not exist in PUPPET_HOME: ${PUPPET_HOME}. Available profiles are,"
        listFiles "${PUPPET_HOME}/hieradata/dev/wso2/${1}/${2}/"
        echo
         exit 1
    fi
}

# check if provided product version exists in PUPPET_HOME
validateProductVersion "${product_name}" "${product_version}"

# check if provided profile exists in PUPPET_HOME
validateProfile "${product_name}" "${product_version}" "${product_profiles}"

export file_location=${PUPPET_HOME}