#!/bin/bash

set -euo pipefail

USER_ID="${LOCAL_USER_ID:-9001}"
GRP_ID="${LOCAL_GRP_ID:-9001}"
LD_PRELOAD="${LD_PRELOAD:-}"

if [ "$USER_ID" != "0"  ]; then
    getent group "$GRP_ID" &> /dev/null || groupadd -g "$GRP_ID" user
    id -u user &> /dev/null || useradd --shell /bin/bash -u "$USER_ID" -g "$GRP_ID" -o -c "" -m user
    CURRENT_UID="$(id -u user)"
    CURRENT_GID="$(id -g user)"
    if [ "$USER_ID" != "$CURRENT_UID" ] || [ "$GRP_ID" != "$CURRENT_GID" ]; then
        echo -e "WARNING: User with differing UID $CURRENT_UID/GID $CURRENT_GID already exists, most likely this container was started before with a different UID/GID. Re-create it to change UID/GID.\n"
    fi
else
    CURRENT_UID="$USER_ID"
    CURRENT_GID="$GRP_ID"
    echo -e "WARNING: Starting container processes as root. This has some security implications and goes against docker best practice.\n"
fi

# set $HOME
if [ "$CURRENT_UID" != "0" ]; then
    export USERNAME=user
    export HOME=/home/"$USERNAME"
else
    export USERNAME=root
    export HOME=/root
fi

# detect external IPv4 address
SCNODE_NET_DECLAREDADDRESS="$(dig -4 +short +time=2 @resolver1.opendns.com A myip.opendns.com | grep -v ";" || true)"

# Using diff resolver
if [ -z "${SCNODE_NET_DECLAREDADDRESS}" ]; then
  SCNODE_NET_DECLAREDADDRESS="$(curl -s ifconfig.me/ip || true)"
fi

# Falling over to internal IP
if [ -z "${SCNODE_NET_DECLAREDADDRESS}" ]; then
  echo "Error: Failed to detect external IPv4 address, using internal address."
  SCNODE_NET_DECLAREDADDRESS="$(hostname -I | cut -d ' ' -f1)"
  SCNODE_NET_DECLAREDADDRESS="${SCNODE_NET_DECLAREDADDRESS%% }"
fi
export SCNODE_NET_DECLAREDADDRESS

to_check=(
  "SCNODE_CERT_SIGNERS_MAXPKS"
  "SCNODE_CERT_SIGNERS_PUBKEYS"
  "SCNODE_CERT_SIGNERS_THRESHOLD"
  "SCNODE_CERT_MASTERS_PUBKEYS"
  "SCNODE_FORGER_RESTRICT"
  "SCNODE_GENESIS_BLOCKHEX"
  "SCNODE_GENESIS_SCID"
  "SCNODE_GENESIS_POWDATA"
  "SCNODE_GENESIS_MCBLOCKHEIGHT"
  "SCNODE_GENESIS_MCNETWORK"
  "SCNODE_GENESIS_WITHDRAWALEPOCHLENGTH"
  "SCNODE_GENESIS_COMMTREEHASH"
  "SCNODE_GENESIS_ISNONCEASING"
  "SCNODE_NET_DECLAREDADDRESS"
  "SCNODE_NET_KNOWNPEERS"
  "SCNODE_NET_MAGICBYTES"
  "SCNODE_NET_NODENAME"
  "SCNODE_NET_P2P_PORT"
  "SCNODE_REST_PORT"
  "SCNODE_WALLET_SEED"
  "SCNODE_WALLET_MAXTX_FEE"
  "SCNODE_WS_SERVER_PORT"
  "SCNODE_WS_SERVER_ENABLED"
)
for var in "${to_check[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable ${var} required."
    sleep 5
    exit 1
  fi
done

if [ "${SCNODE_FORGER_RESTRICT:-}" = "true" ]; then
  if [ -z "${SCNODE_ALLOWED_FORGERS:-}" ]; then
    echo "Error: Environment variable SCNODE_ALLOWED_FORGERS required when SCNODE_FORGER_RESTRICT=true."
    sleep 5
    exit 1
  fi
fi


# set REST API password hash
SCNODE_REST_APIKEYHASH=""
if [ -n "${SCNODE_REST_PASSWORD:-}" ]; then
  SCNODE_REST_APIKEYHASH="$(echo -en "\n        apiKeyHash = \"$(htpasswd -nbBC 10 "" "${SCNODE_REST_PASSWORD}" | tr -d ':\n')\"")"
fi
export SCNODE_REST_APIKEYHASH

# download and extract backup for import
backupdir="/sidechain/datadir/backupStorage"
if [ -n "${SCNODE_BACKUP_TAR_GZ_URL:-}" ] && ! [ -f "${backupdir}/.import_done" ]; then
  echo "Importing backup from '${SCNODE_BACKUP_TAR_GZ_URL}' to '${backupdir}'."
  mkdir -p "${backupdir}"
  curl -L "${SCNODE_BACKUP_TAR_GZ_URL}" | tar -xzf - -C "${backupdir}"
  touch "${backupdir}/.import_done"
fi

# convert literal '\n' to newlines
SCNODE_CERT_SIGNERS_PUBKEYS="$(echo -e "${SCNODE_CERT_SIGNERS_PUBKEYS:-}")"
SCNODE_CERT_SIGNERS_SECRETS="$(echo -e "${SCNODE_CERT_SIGNERS_SECRETS:-}")"
SCNODE_CERT_MASTERS_PUBKEYS="$(echo -e "${SCNODE_CERT_MASTERS_PUBKEYS:-}")"
SCNODE_ALLOWED_FORGERS="$(echo -e "${SCNODE_ALLOWED_FORGERS:-}")"
SCNODE_NET_KNOWNPEERS="$(echo -e "${SCNODE_NET_KNOWNPEERS:-}")"
export SCNODE_CERT_SIGNERS_PUBKEYS
export SCNODE_CERT_SIGNERS_SECRETS
export SCNODE_CERT_MASTERS_PUBKEYS
export SCNODE_ALLOWED_FORGERS
export SCNODE_NET_KNOWNPEERS

# substitute env vars in scnode config file
# shellcheck disable=SC2016,SC2026
SUBST='$SCNODE_CERT_MASTERS_PUBKEYS:$SCNODE_CERT_SIGNERS_MAXPKS:$SCNODE_CERT_SIGNERS_PUBKEYS:$SCNODE_CERT_SIGNERS_SECRETS:$SCNODE_CERT_SIGNERS_THRESHOLD:'\
'$SCNODE_GENESIS_BLOCKHEX:$SCNODE_GENESIS_SCID:$SCNODE_GENESIS_POWDATA:$SCNODE_GENESIS_MCBLOCKHEIGHT:$SCNODE_GENESIS_MCNETWORK:'\
'$SCNODE_GENESIS_WITHDRAWALEPOCHLENGTH:$SCNODE_GENESIS_COMMTREEHASH:$SCNODE_GENESIS_ISNONCEASING:$SCNODE_ALLOWED_FORGERS:$SCNODE_FORGER_RESTRICT:'\
'$SCNODE_NET_DECLAREDADDRESS:$SCNODE_NET_KNOWNPEERS:$SCNODE_NET_MAGICBYTES:$SCNODE_NET_NODENAME:$SCNODE_NET_P2P_PORT:$SCNODE_REST_APIKEYHASH:'\
'$SCNODE_WALLET_GENESIS_SECRETS:$SCNODE_WALLET_MAXTX_FEE:$SCNODE_WALLET_SEED:$WS_ADDRESS:$SCNODE_REST_PORT:$SCNODE_WS_SERVER_PORT:$SCNODE_WS_SERVER_ENABLED'
export SUBST
envsubst "${SUBST}" < /sidechain/config/sc_settings.conf.tmpl > /sidechain/config/sc_settings.conf
unset SUBST

# set file ownership
find /sidechain -writable -print0 | xargs -0 -I{} -P64 -n1 chown -f "${CURRENT_UID}":"${CURRENT_GID}" "{}"

# preload libjemalloc2
path_to_jemalloc="$(ldconfig -p | grep "$(arch)" | grep 'libjemalloc\.so\.2$' | tr -d ' ' | cut -d '>' -f 2)"
export LD_PRELOAD="${path_to_jemalloc}:${LD_PRELOAD}"

if [ "${1}" = "/usr/bin/true" ]; then
  set -- java -cp '/sidechain/'"${SC_JAR_NAME}"'-'"${SC_VERSION}"'.jar:/sidechain/lib/*' "${SC_MAIN_CLASS}" "${SC_CONF_PATH}"
fi

echo "Username: ${USERNAME}, UID: ${CURRENT_UID}, GID: ${CURRENT_GID}"
echo "LD_PRELOAD: ${LD_PRELOAD}"
echo "Starting sidechain node."
echo "Command: '$@'"

if [ "${USERNAME}" = "user" ]; then
    exec /usr/local/bin/gosu user "$@"
else
    exec "$@"
fi