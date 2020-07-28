#!/usr/bin/env bash

set -euo pipefail

export VAULT_FORMAT="json"
CONFIG="${HOME}/.config/caascad"
OS_CONFIG="${CONFIG}/os"
CAASCAD_ZONES_URL="https://git.corp.cloudwatt.com/caascad/caascad-zones/raw/master/zones.json"
CAASCAD_ZONES_FILE="${CONFIG}/caascad-zones.json"
CURRENT_FILE="${OS_CONFIG}/current"

_help() {
    cat <<EOF
NAME
      Thin wrapper around openstack command

SYNOPSIS
      os [os-command] [environment]
      os <openstack subcommand>

DESCRIPTION
      <empty>
            Prints the environment selected

      os_help | ch
            Prints this help

      switch | s
            Change the environment selected to issue openstack commands

      print | p [-u]
            Prints openstack environment variables used.
            Obfuscates password unless -u parameter is used.

      <openstack-subcommand>
            Standard openstack subcommands, token issue, server list

    }
EOF
}

_init() {
    mkdir -p "${OS_CONFIG}"
    touch "${CURRENT_FILE}"
    _refresh
}

_is_local () {
  [[ -f "$1" ]]
}

_refresh() {
    if _is_local "${CAASCAD_ZONES_URL}"; then
      cp "${CAASCAD_ZONES_URL}" "${CAASCAD_ZONES_FILE}"
    else
      curl -s "${CAASCAD_ZONES_URL}" -o "${CAASCAD_ZONES_FILE}"
    fi
}

_switch() {
    echo "${1}" > "${CURRENT_FILE}"
}

_parse() {
    if [[ "$#" -eq 0 ]]; then
        cat "${CURRENT_FILE}";
        exit 0;
    fi
    case "$1" in
        os_help|ch)
            _help
            ;;
        print|p)
            _get_secrets
            _print "${@:2}"
            ;;
        refresh|r)
            _refresh;
            ;;
        switch|s)
            if [[ "$#" -eq 2 ]]; then
                _switch "$2"
            else
                echo "switch subcommand needs 1 argument"
            fi
            ;;
        *)
            _get_secrets
            openstack "$@"
            ;;
    esac
}

_print() {
    OSVARS=$(env | grep -e ^OS_)
    if [[ "$@" != "-u" ]]; then
      OSVARS=$(echo "${OSVARS}"| sed 's/OS_PASSWORD=.*/OS_PASSWORD=XXX/g')
    fi
    echo "${OSVARS}"
}

_get_secrets() {
    ZONE_NAME=$(cat "${CURRENT_FILE}")
    [ -z "${ZONE_NAME}" ] && echo "No environment selected. Use 'os switch <env> first.'" && exit 1
    INFRA_ZONE_NAME="$(cat ${CAASCAD_ZONES_FILE}|jq -r '."'${ZONE_NAME}'".infra_zone_name')"
    DOMAIN_NAME="$(cat ${CAASCAD_ZONES_FILE}|jq -r '."'${ZONE_NAME}'".domain_name')"
    export VAULT_ADDR="https://vault.${INFRA_ZONE_NAME}.${DOMAIN_NAME}"
    >&2 echo "Using ${VAULT_ADDR}"
    >&2 echo "Looking for ${ZONE_NAME} secrets"
    if [[ $ZONE_NAME =~ ^OCB000.* ]]; then
        secret=$(vault read secret/zones/fe/api-${ZONE_NAME})
    else
        secret=$(vault read secret/zones/fe/${ZONE_NAME}/api)
    fi
    export OS_AUTH_URL=https://iam.eu-west-0.prod-cloud-ocb.orange-business.com/v3
    export OS_USERNAME=$(echo $secret| jq -r .data.username)
    export OS_PROJECT_NAME=$(echo $secret| jq -r .data.tenant_name)
    export OS_USER_DOMAIN_NAME=$(echo $secret| jq -r .data.domain_name)
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    export OS_INTERFACE=public
    export NOVA_ENDPOINT_TYPE=publicURL
    export OS_ENDPOINT_TYPE=publicURL
    export CINDER_ENDPOINT_TYPE=publicURL
    export OS_VOLUME_API_VERSION=2
    export OS_PASSWORD=$(echo $secret| jq -r .data.password)
    export OS_REGION_NAME=$(echo $secret| jq -r .data.region)
}

_init
_parse "$@"
