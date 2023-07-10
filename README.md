# Getting Started

This docker image has the latest "mc" command and my "gen-templates.sh" with the template file named "user-bucket-policy-_USER_ID_.json".

The overall explanation is described in the following article.

* [Qiita - Deploy the minio-toolbox on k8s namespace/minio-client](https://qiita.com/YasuhiroABE/items/f6d4628bd747eb4550b1#namespaceminio-client-%E3%81%A7-minio-toolbox-%E3%82%92%E5%8B%95%E3%81%8B%E3%81%99) (Japanese Only)

## 1. Deploy the minio-toolbox (one time operation)

    ## for test
    $ docker run -it --rm -d -v `pwd`/data:/root --name minio-toolbox yasuhiroabe/minio-toolbox:1.0.5
    
    ## for production
    $ kubectl create ns minio-client
    $ kubectl -n mino-client apply -f k8s/pvc-minio-client.yaml
    $ kubectl -n mino-client apply -f k8s/deploy-minio-client.yaml

## 2. Move into the container context

    ## for docker
    $ docker exec -it minio-toolbox bash
    
    ## for k8s
    $ kubectl -n minio-client exec -it $(kubectl -n minio-client get pod -l app=minio-toolbox -o=jsonpath='{.items[0].metadata.name}') -- bash

## 3. Save the server information

Execute following commands in the container context.
When using the docker container, the URL should be "http://localhost:9000"

    > ./mc config host add my-minio-local http://my-minio.minio.svc.cluster.local:9000 <root-access-key> <root-secret-key> --api S3v4
    Added `my-minio-local` successfully.

The <root-access-key> and <root-secret-key> must be replaced with the corresponding minio root's key and secret, respectively.

The configuration file will be stored into the */root/.mc/config.json* file.

When executing the mc command, the /root/.mc/config.json file will be loaded in advance.

## 4. Create additional buckets and access keys

To use minio buckets in the k8s system, all applications should use the different bucket and access key each other.

    $ export MINIO_TARGET=my-minio-local
    $ ./gen-template.sh example-app01

Then, the script creates new user's access-key, secret-key, and bucket "example-app01".
The access-key and secret-key information will be stored into the "/root/YYYYmmdd.HHMMSS.txt" file.

