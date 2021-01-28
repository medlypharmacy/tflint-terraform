FROM alpine:3
RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git jq openssh unzip"]
COPY ["src", "/src/"]
RUN ["chmod", "+x", "-R", "/src"]
ENTRYPOINT ["/src/main.sh"]