#!/bin/bash

## Usage: ./gen-template.sh $(cat member.list)

BASEDIR=$(dirname $(readlink -f $0))
OUTPUT_DIRNAME="$(date +%Y%m%d.%H%M%S)"
OUTPUTDIR="${DATADIR:-/root}/${OUTPUT_DIRNAME}"

MC_CMD="${BASEDIR}/mc"
MINIO_TARGET=${MINIO_TARGET:-my-minio-local}

## template filepath from ${OUTPUTDIR}
TEMPLPATH1="${BASEDIR}/user-bucket-policy-_USER_ID_.json"

## check the .mc/config file.
if test ! -f ~/.mc/config.json || test $(grep "${MINIO_TARGET}" ~/.mc/config.json >/dev/null) == "1" ; then
  echo "Usage: Please setup the ~/.mc/config file, using the following command line."
  echo "  ./mc config host add my-minio-local http://my-minio.minio:9000 <root-access-key> <root-password> --api S3v4"
fi

## prepare outputdir and cd to it.
mkdir -p "${OUTPUTDIR}"
cd "${OUTPUTDIR}"

for username in $@
do
    ## check existing bucket
    ${MC_CMD} ls "${MINIO_TARGET}/${username}-bucket"
    test "$?" == "0" && echo "[skip] bucket, ${username}-bucket, exists" && continue

    ## prepare the template file
    OUTPUT_FILENAME=$(basename "${TEMPLPATH1}" | sed -e "s/_USER_ID_/${username}/g")
    sed -e "s/_USER_ID_/${username}/g" "${TEMPLPATH1}" > "${OUTPUT_FILENAME}"

    ## adding minio user and policy
    ACCESS_KEY="$(openssl rand -hex 8)"
    SECRET_KEY="$(openssl rand -hex 16)"
    ${MC_CMD} admin policy create "${MINIO_TARGET}" "readwrite-${username}" "${OUTPUT_FILENAME}"
    test "$?" == "0" && ${MC_CMD} admin user add "${MINIO_TARGET}" "${ACCESS_KEY}" "${SECRET_KEY}"
    test "$?" == "0" && ${MC_CMD} admin policy attach "${MINIO_TARGET}" "readwrite-${username}" --user "${ACCESS_KEY}"
    echo "${username},${ACCESS_KEY},${SECRET_KEY}" >> "../${OUTPUT_DIRNAME}.txt"

    ${MC_CMD} mb "${MINIO_TARGET}/${username}-bucket"
done
