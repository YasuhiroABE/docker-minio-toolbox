#!/bin/bash
##
## Usage: ./gen-template.sh [username ...]
##
##    e.g ./gen-template.sh $(cat member.list)
##     or ./gen-template.sh user01 user02
##

BASEDIR=$(dirname $(readlink -f $0))
OUTPUT_DIRNAME="$(date +%Y%m%d.%H%M%S)"
OUTPUTDIR="${DATADIR:-/root}/${OUTPUT_DIRNAME}"

OPENSSL_CMD="openssl"
MC_CMD=${BASEDIR}/mc
MINIO_BUCKET=${MINIO_BUCKET:-my-minio-local}

## template filepath from ${OUTPUTDIR}
TEMPLPATH1="${BASEDIR}/user-bucket-policy-_USER_ID_.json"

## prepare outputdir and cd to it.
mkdir -p "${OUTPUTDIR}"
cd "${OUTPUTDIR}"

for username in $@
do
    OUTPUT_FILENAME=$(basename "${TEMPLPATH1}" | sed -e "s/_USER_ID_/${username}/g")
    sed -e "s/_USER_ID_/${username}/g" "${TEMPLPATH1}" > "${OUTPUT_FILENAME}"

    ACCESS_KEY="$(${OPENSSL_CMD} rand -hex 8)"
    SECRET_KEY="$(${OPENSSL_CMD} rand -hex 16)"
    ${MC_CMD} admin policy add "${MINIO_BUCKET}" "readwrite-${username}" "${OUTPUT_FILENAME}"
    test "$?" == "0" && ${MC_CMD} admin user add "${MINIO_BUCKET}" "${ACCESS_KEY}" "${SECRET_KEY}"
    test "$?" == "0" && ${MC_CMD} admin policy set "${MINIO_BUCKET}" "readwrite-${username}" user="${ACCESS_KEY}"
    echo "${username},${ACCESS_KEY},${SECRET_KEY}" >> "../${OUTPUT_DIRNAME}.txt"

    ${MC_CMD} mb "${MINIO_BUCKET}/${username}-bucket"
done
