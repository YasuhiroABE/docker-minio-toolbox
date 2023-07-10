FROM alpine:3.18.2

ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache tzdata bash ca-certificates busybox openssl git

WORKDIR /app
RUN wget https://dl.min.io/client/mc/release/${TARGETOS:-linux}-${TARGETARCH:-adm64}/mc
RUN chmod +x mc
COPY ./app /app
RUN chmod +x gen-template.sh

ENV DATADIR /root

CMD ["sh"]
