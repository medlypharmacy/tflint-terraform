  
FROM alpine:3 
RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git jq openssh unzip"]
COPY ["src", "/src/"]
USER root
ENTRYPOINT ["/src/main.sh"]