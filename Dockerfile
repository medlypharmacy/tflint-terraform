  
FROM alpine:3 
USER root
RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git jq openssh unzip"]
RUN chmod +x /src/main.sh
COPY ["src", "/src/"]
ENTRYPOINT ["/src/main.sh"]