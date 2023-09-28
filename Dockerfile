FROM alpine:3.18.3

ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache tzdata bash ca-certificates busybox openssl git

## Download the "mc" command
RUN wget -O /usr/bin/mc https://dl.min.io/client/mc/release/${TARGETOS:-linux}-${TARGETARCH:-amd64}/mc
RUN chmod a+x /usr/bin/mc

## Download the "restic" command
RUN wget -O /usr/bin/restic.bz2 https://github.com/restic/restic/releases/download/v0.16.0/restic_0.16.0_${TARGETOS:-linux}_${TARGETARCH:-amd64}.bz2
RUN bunzip2 /usr/bin/restic.bz2
RUN chmod a+x /usr/bin/restic

COPY ./app /app
WORKDIR /app
RUN chmod +x gen-template.sh
RUN cp /usr/bin/mc .
RUN cp /usr/bin/restic .

ENV DATADIR /root

VOLUME ["/root"]

CMD ["sh"]
